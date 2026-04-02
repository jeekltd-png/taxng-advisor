const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
const util = require('util');

const dbPath = path.join(__dirname, 'db.sqlite');
const ensureDir = path.dirname(dbPath);
if (!fs.existsSync(ensureDir)) fs.mkdirSync(ensureDir, { recursive: true });

const db = new sqlite3.Database(dbPath);
const run = util.promisify(db.run.bind(db));
const get = util.promisify(db.get.bind(db));
const all = util.promisify(db.all.bind(db));

const init = async () => {
  await run('PRAGMA foreign_keys = ON');

  await run(`CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    passwordHash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    createdAt TEXT NOT NULL
  )`);

  await run(`CREATE TABLE IF NOT EXISTS groups (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    creatorId TEXT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'GBP',
    locale TEXT NOT NULL DEFAULT 'en-GB',
    country TEXT NOT NULL DEFAULT 'UK',
    contributionAmount REAL NOT NULL DEFAULT 100,
    cycleType TEXT NOT NULL DEFAULT 'weekly',
    feePercent REAL NOT NULL DEFAULT 1,
    createdAt TEXT NOT NULL,
    FOREIGN KEY (creatorId) REFERENCES users(id) ON DELETE CASCADE
  )`);

  await run(`CREATE TABLE IF NOT EXISTS group_members (
    id TEXT PRIMARY KEY,
    groupId TEXT NOT NULL,
    name TEXT NOT NULL,
    balance REAL NOT NULL DEFAULT 0,
    joinedAt TEXT NOT NULL,
    FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE,
    UNIQUE(groupId, name)
  )`);

  await run(`CREATE TABLE IF NOT EXISTS contributions (
    id TEXT PRIMARY KEY,
    groupMemberId TEXT NOT NULL,
    groupId TEXT NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    FOREIGN KEY (groupMemberId) REFERENCES group_members(id) ON DELETE CASCADE,
    FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
  )`);

  await run(`CREATE TABLE IF NOT EXISTS cycles (
    id TEXT PRIMARY KEY,
    groupId TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    paymentDate TEXT NOT NULL,
    status TEXT NOT NULL,
    grossPot REAL NOT NULL,
    feePercent REAL NOT NULL,
    feeAmount REAL NOT NULL,
    netPot REAL NOT NULL,
    recipientGroupMemberId TEXT,
    paidAt TEXT,
    FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (recipientGroupMemberId) REFERENCES group_members(id) ON DELETE SET NULL
  )`);

  await run(`CREATE TABLE IF NOT EXISTS audit_logs (
    id TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    action TEXT NOT NULL,
    resource TEXT NOT NULL,
    resourceId TEXT,
    changes TEXT,
    ip TEXT,
    userAgent TEXT,
    status TEXT DEFAULT 'success',
    details TEXT,
    createdAt TEXT NOT NULL,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
  )`);
};

const clearAll = async () => {
  await run('DELETE FROM contributions');
  await run('DELETE FROM cycles');
  await run('DELETE FROM group_members');
  await run('DELETE FROM groups');
  await run('DELETE FROM users');
};

const findUserByEmail = async (email) => get('SELECT * FROM users WHERE email = ?', [email]);
const findUserById = async (id) => get('SELECT * FROM users WHERE id = ?', [id]);
const createUser = async ({ id, email, passwordHash, role='user', createdAt }) => {
  await run(
    'INSERT INTO users (id,email,passwordHash,role,createdAt) VALUES (?,?,?,?,?)',
    [id, email, passwordHash, role, createdAt]
  );
  return findUserById(id);
};

const createGroup = async (group) => {
  await run(
    'INSERT INTO groups (id,name,creatorId,currency,locale,country,contributionAmount,cycleType,feePercent,createdAt) VALUES (?,?,?,?,?,?,?,?,?,?)',
    [
      group.id,
      group.name,
      group.creatorId,
      group.currency,
      group.locale,
      group.country,
      group.contributionAmount,
      group.cycleType,
      group.feePercent || 1,
      group.createdAt
    ]
  );
  return get('SELECT * FROM groups WHERE id = ?', [group.id]);
};

const findGroupByName = async (name) => get('SELECT * FROM groups WHERE name = ?', [name]);

const addMember = async ({ id, groupId, name, joinedAt }) => {
  await run('INSERT INTO group_members (id,groupId,name,balance,joinedAt) VALUES (?,?,?,?,?)', [id, groupId, name, 0, joinedAt]);
  return get('SELECT * FROM group_members WHERE id = ?', [id]);
};

const findMemberByName = async (groupId, name) => get('SELECT * FROM group_members WHERE groupId = ? AND name = ?', [groupId, name]);

const updateMemberBalance = async (memberId, balance) => {
  await run('UPDATE group_members SET balance = ? WHERE id = ?', [balance, memberId]);
  return get('SELECT * FROM group_members WHERE id = ?', [memberId]);
};

const insertContribution = async ({ id, groupMemberId, groupId, amount, date }) => {
  await run('INSERT INTO contributions (id,groupMemberId,groupId,amount,date) VALUES (?,?,?,?,?)', [id, groupMemberId, groupId, amount, date]);
};

const getGroupWithMembers = async (name) => {
  const group = await findGroupByName(name);
  if (!group) return null;
  const members = await all('SELECT id,name,balance FROM group_members WHERE groupId = ?', [group.id]);
  const cycles = await all('SELECT * FROM cycles WHERE groupId = ? ORDER BY createdAt ASC', [group.id]);
  return { ...group, members, cycles };
};

const collectCycle = async (cycle) => {
  await run(
    'INSERT INTO cycles (id,groupId,createdAt,paymentDate,status,grossPot,feePercent,feeAmount,netPot,recipientGroupMemberId,paidAt) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    [
      cycle.id,
      cycle.groupId,
      cycle.createdAt,
      cycle.paymentDate,
      cycle.status,
      cycle.grossPot,
      cycle.feePercent,
      cycle.feeAmount,
      cycle.netPot,
      null,
      null
    ]
  );
  return get('SELECT * FROM cycles WHERE id = ?', [cycle.id]);
};

const findLatestCycleByGroup = async (groupId) => get('SELECT * FROM cycles WHERE groupId = ? ORDER BY createdAt DESC LIMIT 1', [groupId]);

const markCyclePaid = async (cycleId, recipientGroupMemberId, paidAt) => {
  await run('UPDATE cycles SET status = ?, recipientGroupMemberId = ?, paidAt = ? WHERE id = ?', ['paid', recipientGroupMemberId, paidAt, cycleId]);
  return get('SELECT * FROM cycles WHERE id = ?', [cycleId]);
};

const getUserDashboard = async (userId) => {
  const feeds = await all(`
    SELECT g.groupId, g.name AS groupName, gm.balance, COALESCE(SUM(c.amount),0) AS totalContributed
    FROM group_members gm
    JOIN groups g ON gm.groupId = g.id
    LEFT JOIN contributions c ON c.groupMemberId = gm.id
    WHERE gm.id IN (SELECT id FROM group_members WHERE groupId=g.id AND gm.id IS NOT NULL ) -- preserve logic
      AND gm.id IN (SELECT id FROM group_members WHERE gm.id = gm.id)
      AND gm.groupId IN (SELECT groupId FROM group_members WHERE userId = ?)
    GROUP BY g.groupId, g.name, gm.balance
  `, [userId]);

  // simple fallback: by membership only
  const memberships = await all(`
    SELECT g.id AS groupId, g.name, gm.balance,
      COALESCE((SELECT SUM(amount) FROM contributions WHERE groupMemberId = gm.id),0) AS totalContributed
    FROM group_members gm
    JOIN groups g ON gm.groupId = g.id
    WHERE gm.name = gm.name
  `);

  return { feeds: memberships };
};

// Transaction support for atomic operations (especially financial operations)
const withTransaction = async (callback) => {
  try {
    await run('BEGIN TRANSACTION');
    const result = await callback();
    await run('COMMIT');
    return result;
  } catch (error) {
    await run('ROLLBACK');
    throw error;
  }
};

// Atomic collection cycle with safety checks
const collectCycleAtomic = async (groupId, cycle) => {
  return withTransaction(async () => {
    // Verify group exists and get current state
    const group = await get('SELECT * FROM groups WHERE id = ?', [groupId]);
    if (!group) throw new Error('Group not found');

    // Get active members
    const members = await all('SELECT id FROM group_members WHERE groupId = ?', [groupId]);
    if (members.length === 0) throw new Error('No members in group');

    // Insert cycle atomically
    await run(
      'INSERT INTO cycles (id,groupId,createdAt,paymentDate,status,grossPot,feePercent,feeAmount,netPot,recipientGroupMemberId,paidAt) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [
        cycle.id,
        groupId,
        cycle.createdAt,
        cycle.paymentDate,
        cycle.status,
        cycle.grossPot,
        cycle.feePercent,
        cycle.feeAmount,
        cycle.netPot,
        null,
        null
      ]
    );

    return get('SELECT * FROM cycles WHERE id = ?', [cycle.id]);
  });
};

// Atomic payout with safety checks
const payoutAtomic = async (cycleId, memberId, amount, paidAt) => {
  return withTransaction(async () => {
    // Verify cycle exists and is in collected state
    const cycle = await get('SELECT * FROM cycles WHERE id = ?', [cycleId]);
    if (!cycle) throw new Error('Cycle not found');
    if (cycle.status === 'paid') throw new Error('Cycle already paid');

    // Verify member exists
    const member = await get('SELECT * FROM group_members WHERE id = ?', [memberId]);
    if (!member) throw new Error('Member not found');

    // Update member balance
    const newBalance = Number((Number(member.balance) + amount).toFixed(2));
    await run('UPDATE group_members SET balance = ? WHERE id = ?', [newBalance, memberId]);

    // Mark cycle as paid atomically
    await run(
      'UPDATE cycles SET status = ?, recipientGroupMemberId = ?, paidAt = ? WHERE id = ?',
      ['paid', memberId, paidAt, cycleId]
    );

    return {
      cycle: await get('SELECT * FROM cycles WHERE id = ?', [cycleId]),
      member: await get('SELECT * FROM group_members WHERE id = ?', [memberId])
    };
  });
};

// ==================== AUDIT LOGGING ====================
const { generateId } = require('./osusu');

const createAuditLog = async (userId, action, resource, resourceId = null, changes = null, ip = null, userAgent = null, status = 'success', details = null) => {
  await run(
    `INSERT INTO audit_logs (id, userId, action, resource, resourceId, changes, ip, userAgent, status, details, createdAt)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      '_' + Math.random().toString(36).substr(2, 9),
      userId,
      action,
      resource,
      resourceId,
      changes ? JSON.stringify(changes) : null,
      ip,
      userAgent,
      status,
      details,
      new Date().toISOString()
    ]
  );
};

const getAuditLogs = async (filters = {}) => {
  let query = 'SELECT * FROM audit_logs WHERE 1=1';
  const params = [];

  if (filters.userId) {
    query += ' AND userId = ?';
    params.push(filters.userId);
  }
  if (filters.resource) {
    query += ' AND resource = ?';
    params.push(filters.resource);
  }
  if (filters.action) {
    query += ' AND action = ?';
    params.push(filters.action);
  }
  if (filters.startDate) {
    query += ' AND createdAt >= ?';
    params.push(filters.startDate);
  }
  if (filters.endDate) {
    query += ' AND createdAt <= ?';
    params.push(filters.endDate);
  }

  query += ' ORDER BY createdAt DESC LIMIT 1000';

  return all(query, params);
};

// ==================== ADMIN FUNCTIONS ====================
const getAllUsers = async () => {
  return all('SELECT id, email, role, createdAt FROM users ORDER BY createdAt DESC');
};

const updateUserRole = async (userId, newRole) => {
  if (!['user', 'admin', 'superadmin'].includes(newRole)) {
    throw new Error('Invalid role');
  }
  await run('UPDATE users SET role = ? WHERE id = ?', [newRole, userId]);
  return get('SELECT * FROM users WHERE id = ?', [userId]);
};

const getUserStats = async (userId) => {
  const user = await get('SELECT * FROM users WHERE id = ?', [userId]);
  const groupCount = await get('SELECT COUNT(*) as count FROM groups WHERE creatorId = ?', [userId]);
  const contributions = await get('SELECT SUM(amount) as total FROM contributions WHERE groupMemberId IN (SELECT id FROM group_members WHERE groupId IN (SELECT id FROM groups WHERE creatorId = ?))', [userId]);
  
  return {
    user,
    groupCount: groupCount?.count || 0,
    totalContributions: contributions?.total || 0
  };
};

const getAllGroupsAdmin = async () => {
  const groups = await all(`
    SELECT 
      g.id, g.name, g.currency, g.country, g.cycleType, g.createdAt,
      u.email as creatorEmail,
      COUNT(DISTINCT gm.id) as memberCount,
      COUNT(DISTINCT c.id) as cycleCount,
      SUM(c.grossPot) as totalGrossVolume
    FROM groups g
    LEFT JOIN users u ON g.creatorId = u.id
    LEFT JOIN group_members gm ON g.id = gm.groupId
    LEFT JOIN cycles c ON g.id = c.groupId
    GROUP BY g.id
    ORDER BY g.createdAt DESC
  `);
  return groups;
};

const getGroupDetailsAdmin = async (groupId) => {
  const group = await get(`
    SELECT 
      g.id, g.name, g.currency, g.country, g.cycleType, g.createdAt,
      u.email as creatorEmail,
      COUNT(DISTINCT gm.id) as memberCount
    FROM groups g
    LEFT JOIN users u ON g.creatorId = u.id
    LEFT JOIN group_members gm ON g.id = gm.groupId
    WHERE g.id = ?
    GROUP BY g.id
  `, [groupId]);
  
  if (!group) return null;
  
  const members = await all('SELECT * FROM group_members WHERE groupId = ?', [groupId]);
  const cycles = await all('SELECT * FROM cycles WHERE groupId = ?', [groupId]);
  
  return { ...group, members, cycles };
};

const deleteGroupCascade = async (groupId) => {
  return withTransaction(async () => {
    const group = await get('SELECT * FROM groups WHERE id = ?', [groupId]);
    if (!group) throw new Error('Group not found');
    
    // Delete in cascade order
    await run('DELETE FROM cycles WHERE groupId = ?', [groupId]);
    await run('DELETE FROM contributions WHERE groupId = ?', [groupId]);
    await run('DELETE FROM group_members WHERE groupId = ?', [groupId]);
    await run('DELETE FROM groups WHERE id = ?', [groupId]);
    
    return { deleted: true, groupId };
  });
};

module.exports = {
  init,
  clearAll,
  findUserByEmail,
  createUser,
  findUserById,
  createGroup,
  findGroupByName,
  addMember,
  findMemberByName,
  updateMemberBalance,
  insertContribution,
  getGroupWithMembers,
  collectCycle,
  findLatestCycleByGroup,
  markCyclePaid,
  getUserDashboard,
  // Utility methods for custom queries (used by reports endpoints)
  all,
  run,
  get,
  db,
  close: () => new Promise((resolve, reject) => db.close(err => err ? reject(err) : resolve())),
  // Transaction support
  withTransaction,
  collectCycleAtomic,
  payoutAtomic,
  // Audit logging
  createAuditLog,
  getAuditLogs,
  // Admin functions
  getAllUsers,
  updateUserRole,
  getUserStats,
  getAllGroupsAdmin,
  getGroupDetailsAdmin,
  deleteGroupCascade
};
