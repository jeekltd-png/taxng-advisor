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
  getUserDashboard
};
