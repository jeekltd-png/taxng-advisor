require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const bcrypt = require('bcryptjs');
const path = require('path');
const fs = require('fs');
const sqlite = require('./sqlite');

const app = express();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginResourcePolicy: { policy: 'cross-origin' }
}));

// CORS configuration
const cors = require('cors');
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? (process.env.CORS_ORIGINS || 'http://localhost:3000').split(',')
    : '*',
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};
app.use(cors(corsOptions));

app.use(express.json());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Global rate limiter (100 requests per minute for all routes)
// Skip rate limiting in test mode
const globalLimiter = process.env.NODE_ENV === 'test' ? (req, res, next) => next() : rateLimit({ 
  windowMs: 60 * 1000, 
  max: 100, 
  standardHeaders: true, 
  legacyHeaders: false,
  message: 'Too many requests, please try again later'
});
app.use(globalLimiter);

// Stricter rate limiters for sensitive endpoints (disabled in test mode)
const shouldSkipRateLimiting = process.env.NODE_ENV === 'test';

const authLimiter = shouldSkipRateLimiting ? (req, res, next) => next() : rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 5, // 5 requests per 5 minutes
  message: 'Too many auth attempts, please try again later',
  skipSuccessfulRequests: false
});

const financialLimiter = shouldSkipRateLimiting ? (req, res, next) => next() : rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // 10 requests per hour
  message: 'Too many financial operations, please try again later'
});

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_on_prod';
const JWT_EXPIRES_IN = '2h';
const REFRESH_TOKEN_EXPIRES_IN = '7d';

// Logging setup
const winston = require('winston');
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'osusu-server' },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ level, message, timestamp }) => `${timestamp} [${level}]: ${message}`)
      )
    })
  ]
});

// Add file logging in production
if (process.env.NODE_ENV === 'production') {
  logger.add(new winston.transports.File({ filename: 'error.log', level: 'error' }));
  logger.add(new winston.transports.File({ filename: 'combined.log' }));
}

const generateId = () => 'u_' + Math.random().toString(36).slice(2, 12);

const generateToken = (user) => jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
const generateRefreshToken = (user) => jwt.sign({ id: user.id, email: user.email, type: 'refresh', role: user.role }, JWT_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRES_IN });

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Authorization header missing' });
  const token = authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Bearer token missing' });

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ error: 'Invalid or expired token' });
    req.user = decoded;
    next();
  });
};

const requireRole = (role) => (req, res, next) => {
  if (!req.user || !req.user.role) return res.status(403).json({ error: 'Missing role' });
  const roles = ['user', 'admin', 'superadmin'];
  const authorized = roles.indexOf(req.user.role) >= roles.indexOf(role);
  if (!authorized) return res.status(403).json({ error: 'Forbidden' });
  next();
};

app.get('/health', async (req, res) => {
  try {
    // Check database connectivity
    const dbCheck = await sqlite.get('SELECT COUNT(*) as count FROM users').catch(() => null);
    const dbHealthy = dbCheck !== null;

    // Get memory usage
    const memory = process.memoryUsage();
    const memoryMB = {
      heapUsed: Math.round(memory.heapUsed / 1024 / 1024),
      heapTotal: Math.round(memory.heapTotal / 1024 / 1024),
      external: Math.round(memory.external / 1024 / 1024),
      rss: Math.round(memory.rss / 1024 / 1024)
    };

    const uptime = process.uptime();
    const uptimeHours = Math.round(uptime / 3600);

    res.status(200).json({
      status: dbHealthy ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      database: {
        healthy: dbHealthy,
        message: dbHealthy ? 'Connected' : 'Connection failed'
      },
      memory: memoryMB,
      uptime: {
        seconds: uptime,
        hours: uptimeHours
      },
      environment: process.env.NODE_ENV,
      version: require('../package.json').version || '0.1.0'
    });
  } catch (err) {
    res.status(503).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      message: 'Health check failed',
      error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
    });
  }
});

app.post('/test/clear', async (req, res) => {
  try {
    await sqlite.clearAll();
    return res.status(200).json({ message: 'Test db cleared' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/auth/signup', authLimiter, async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required(), password: Joi.string().min(8).required(), role: Joi.string().valid('user','admin','superadmin').default('user') });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const email = value.email.toLowerCase();
  const existing = await sqlite.findUserByEmail(email);
  if (existing) return res.status(409).json({ error: 'Email already registered' });

  const passwordHash = await bcrypt.hash(value.password, 10);
  const user = { id: generateId(), email, passwordHash, role: value.role, createdAt: new Date().toISOString() };
  await sqlite.createUser(user);

  const publicUser = { id: user.id, email: user.email, role: user.role };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.status(201).json({ user: publicUser, token, refreshToken });
});

app.post('/auth/signin', authLimiter, async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required(), password: Joi.string().min(8).required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const email = value.email.toLowerCase();
  const user = await sqlite.findUserByEmail(email);
  if (!user) return res.status(401).json({ error: 'Invalid email or password' });

  const match = await bcrypt.compare(value.password, user.passwordHash);
  if (!match) return res.status(401).json({ error: 'Invalid email or password' });

  const publicUser = { id: user.id, email: user.email, role: user.role };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.json({ user: publicUser, token, refreshToken });
});

app.post('/auth/forgot', authLimiter, async (req, res, next) => {
  try {
    const schema = Joi.object({ email: Joi.string().email().required() });
    const { error, value } = schema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const user = await sqlite.findUserByEmail(value.email.toLowerCase());
    if (!user) return res.status(404).json({ error: 'Email not found' });

    // Generate reset token (1-hour expiry)
    const resetToken = generateToken({ id: user.id, email: user.email, role: user.role, type: 'reset' });
    
    // Send password reset email
    const emailService = require('./email');
    const emailResult = await emailService.sendPasswordResetEmail(user.email, resetToken);

    if (emailResult.success) {
      logger.info(`[auth/forgot] Password reset email sent to ${user.email}`);
      return res.json({ message: 'Password reset link sent to your email' });
    } else {
      logger.error(`[auth/forgot] Failed to send email to ${user.email}`, { error: emailResult.error });
      return res.status(500).json({ error: 'Failed to send reset email. Please try again later.' });
    }
  } catch (err) {
    next(err);
  }
});

// OAuth endpoints removed in favor of standard email/password authentication
// To integrate OAuth, use passport.js middleware with Google/GitHub/Facebook strategies
// Example: app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

app.post('/auth/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

  jwt.verify(refreshToken, JWT_SECRET, (err, decoded) => {
    if (err || decoded.type !== 'refresh') return res.status(401).json({ error: 'Invalid refresh token' });
    const user = { id: decoded.id, email: decoded.email, role: decoded.role || 'user' };
    const token = generateToken(user);
    const nextRefreshToken = generateRefreshToken(user);
    res.json({ token, refreshToken: nextRefreshToken });
  });
});

app.post('/auth/logout', (req, res) => res.json({ message: 'Logged out' }));

app.post('/group', authenticateToken, async (req, res) => {
  const schema = Joi.object({
    name: Joi.string().min(3).max(100).required(),
    currency: Joi.string().optional().default('GBP'),
    locale: Joi.string().optional().default('en-GB'),
    country: Joi.string().optional().default('UK'),
    contributionAmount: Joi.number().positive().default(100),
    cycleType: Joi.string().valid('weekly','biweekly','monthly').default('weekly'),
    feePercent: Joi.number().positive().default(1)
  });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const existing = await sqlite.findGroupByName(value.name);
  if (existing) return res.status(409).json({ error: 'Group already exists' });

  const group = {
    id: generateId(),
    name: value.name,
    currency: value.currency,
    locale: value.locale,
    country: value.country,
    contributionAmount: value.contributionAmount,
    cycleType: value.cycleType,
    feePercent: value.feePercent,
    creatorId: req.user.id,
    createdAt: new Date().toISOString()
  };

  await sqlite.createGroup(group);

  res.status(201).json({ ...group, totalBalance: 0, members: [] });
});

app.post('/group/:groupName/member', authenticateToken, async (req, res) => {
  const groupName = req.params.groupName;
  const memberName = req.body.memberName;
  if (!memberName) return res.status(400).json({ error: 'memberName is required' });

  const group = await sqlite.findGroupByName(groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const existingMember = await sqlite.findMemberByName(group.id, memberName);
  if (existingMember) return res.status(409).json({ error: 'Member already exists' });

  const member = { id: generateId(), groupId: group.id, name: memberName, joinedAt: new Date().toISOString() };
  await sqlite.addMember(member);

  res.status(201).json({ group: groupName, member: memberName });
});

app.post('/group/:groupName/member/:memberName/deposit', authenticateToken, async (req, res) => {
  const { groupName, memberName } = req.params;
  const amount = Number(req.body.amount);
  if (!amount || amount <= 0) return res.status(400).json({ error: 'amount must be positive' });

  const group = await sqlite.findGroupByName(groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const member = await sqlite.findMemberByName(group.id, memberName);
  if (!member) return res.status(404).json({ error: 'Member not found' });

  const newBalance = Number((member.balance + amount).toFixed(2));
  await sqlite.updateMemberBalance(member.id, newBalance);

  await sqlite.insertContribution({ id: generateId(), groupMemberId: member.id, groupId: group.id, amount, date: new Date().toISOString() });

  res.status(200).json({ member: memberName, balance: newBalance });
});

app.get('/group/:groupName', authenticateToken, async (req, res) => {
  const group = await sqlite.getGroupWithMembers(req.params.groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const totalBalance = group.members.reduce((sum, m) => sum + Number(m.balance || 0), 0);

  res.status(200).json({
    name: group.name,
    currency: group.currency,
    locale: group.locale,
    country: group.country,
    contributionAmount: group.contributionAmount,
    cycleType: group.cycleType,
    totalBalance,
    members: group.members,
    cycles: group.cycles || []
  });
});

app.post('/group/:groupName/collect', financialLimiter, authenticateToken, async (req, res) => {
  try {
    const group = await sqlite.findGroupByName(req.params.groupName);
    if (!group) return res.status(404).json({ error: 'Group not found' });

    const members = await sqlite.all('SELECT * FROM group_members WHERE groupId = ?', [group.id]);
    const activeMembers = members.length;
    if (activeMembers === 0) return res.status(400).json({ error: 'No members in group to collect from' });

    const grossPot = Number((group.contributionAmount * activeMembers).toFixed(2));
    const feePercent = Number(group.feePercent || 1);
    const feeAmount = Number((grossPot * feePercent / 100).toFixed(2));
    const netPot = Number((grossPot - feeAmount).toFixed(2));

    const cycle = {
      id: generateId(),
      groupId: group.id,
      createdAt: new Date().toISOString(),
      paymentDate: new Date().toISOString(),
      status: 'collected',
      grossPot,
      feePercent,
      feeAmount,
      netPot
    };

    // Use atomic transaction to ensure data integrity
    const savedCycle = await sqlite.collectCycleAtomic(group.id, cycle);
    logger.info(`Collection completed for group ${group.name}`, {
      groupId: group.id,
      cycleId: cycle.id,
      grossPot,
      netPot
    });

    res.status(200).json({ message: 'Collection completed', grossPot, feeAmount, netPot, cycle: savedCycle });
  } catch (error) {
    logger.error(`Collection failed for group ${req.params.groupName}`, error);
    res.status(400).json({ error: error.message });
  }
});

app.post('/group/:groupName/payout', financialLimiter, authenticateToken, async (req, res) => {
  try {
    const recipient = req.body.recipient;
    if (!recipient) return res.status(400).json({ error: 'Recipient is required' });

    const group = await sqlite.findGroupByName(req.params.groupName);
    if (!group) return res.status(404).json({ error: 'Group not found' });

    const cycle = await sqlite.findLatestCycleByGroup(group.id);
    if (!cycle || cycle.status === 'paid') return res.status(400).json({ error: 'No cycle available for payout' });

    const member = await sqlite.findMemberByName(group.id, recipient);
    if (!member) return res.status(404).json({ error: 'Recipient member not found' });

    // Use atomic transaction to ensure balance update and cycle status are synchronized
    const result = await sqlite.payoutAtomic(cycle.id, member.id, cycle.netPot, new Date().toISOString());
    
    logger.info(`Payout completed for group ${group.name}`, {
      groupId: group.id,
      cycleId: cycle.id,
      memberId: member.id,
      amount: cycle.netPot
    });

    res.status(200).json({
      message: 'Payout successful',
      recipient,
      netPayout: cycle.netPot,
      grossPot: cycle.grossPot,
      feeAmount: cycle.feeAmount,
      cycleId: cycle.id
    });
  } catch (error) {
    logger.error(`Payout failed for group ${req.params.groupName}`, error);
    res.status(400).json({ error: error.message });
  }
});

app.get('/group/:groupName/status', authenticateToken, async (req, res) => {
  const group = await sqlite.getGroupWithMembers(req.params.groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const mostRecentCycle = group.cycles && group.cycles.length ? group.cycles[group.cycles.length - 1] : null;

  res.status(200).json({
    group: {
      name: group.name,
      currency: group.currency,
      locale: group.locale,
      country: group.country,
      contributionAmount: group.contributionAmount,
      cycleType: group.cycleType,
      memberCount: group.members.length
    },
    stats: {
      totalCollected: mostRecentCycle ? mostRecentCycle.grossPot : 0,
      totalFee: mostRecentCycle ? mostRecentCycle.feeAmount : 0,
      netPayout: mostRecentCycle ? mostRecentCycle.netPot : 0,
      lastCycleStatus: mostRecentCycle ? mostRecentCycle.status : 'none'
    },
    members: group.members,
    cycles: group.cycles
  });
});

app.get('/reports/user', authenticateToken, requireRole('user'), async (req, res) => {
  const membership = await sqlite.all(`
    SELECT g.name AS groupName, gm.balance,
      COALESCE((SELECT SUM(amount) FROM contributions c WHERE c.groupMemberId = gm.id), 0) AS totalContributed
    FROM group_members gm
    JOIN groups g ON gm.groupId = g.id
    WHERE g.creatorId = ?
    ORDER BY g.name
  `, [req.user.id]);

  res.json({ userId: req.user.id, data: membership });
});

app.get('/reports/admin', authenticateToken, requireRole('admin'), async (req, res) => {
  const stats = await sqlite.get('SELECT COUNT(*) AS activeGroups FROM groups');
  const users = await sqlite.get('SELECT COUNT(*) AS totalUsers FROM users');
  const cycles = await sqlite.get('SELECT COUNT(*) AS totalCycles FROM cycles');

  const byMonth = await sqlite.all(`
    SELECT SUBSTR(createdAt,1,7) AS month, SUM(grossPot) AS totalGross, SUM(feeAmount) AS totalFees, SUM(netPot) AS totalNet
    FROM cycles
    GROUP BY month
    ORDER BY month DESC
    LIMIT 12
  `);

  res.json({ stats, byMonth, users, cycles });
});

app.get('/reports/superadmin', authenticateToken, requireRole('superadmin'), async (req, res) => {
  const roleBreakdown = await sqlite.all('SELECT role, COUNT(*) as count FROM users GROUP BY role');
  const volume = await sqlite.all(`
    SELECT SUBSTR(createdAt,1,10) AS day, SUM(grossPot) AS grossVolume, SUM(feeAmount) AS feeVolume, SUM(netPot) AS netVolume, COUNT(*) AS cycles
    FROM cycles
    GROUP BY day
    ORDER BY day DESC
    LIMIT 90
  `);

  const geo = await sqlite.all(`
    SELECT country, currency, COUNT(*) AS groupCount, SUM(grossPot) AS grossByRegion
    FROM groups g
    LEFT JOIN cycles c ON c.groupId = g.id
    GROUP BY country, currency
    ORDER BY grossByRegion DESC
  `);

  res.json({ roleBreakdown, volume, geo });
});

app.post('/migrate-from-json', async (req, res) => {
  const jsonPath = path.join(__dirname, 'db.json');
  if (!fs.existsSync(jsonPath)) {
    return res.status(200).json({ message: 'Migration complete', migrated: 0, note: 'No db.json file found' });
  }

  const raw = fs.readFileSync(jsonPath, 'utf8');
  const parsed = JSON.parse(raw);
  await sqlite.clearAll();

  let migratedCount = 0;
  const users = (parsed.users || []).map((u) => ({ id: u.id || generateId(), email: u.email, passwordHash: u.passwordHash || '', role: u.role || 'user', createdAt: u.createdAt || new Date().toISOString() }));
  for (const u of users) {
    await sqlite.createUser(u);
    migratedCount++;
  }

  const groups = parsed.groups || [];
  for (const g of groups) {
    const group = {
      id: g.id || generateId(),
      name: g.name,
      creatorId: g.creatorId || (users[0] && users[0].id) || 'unknown',
      currency: g.currency || 'GBP',
      locale: g.locale || 'en-GB',
      country: g.country || 'UK',
      contributionAmount: g.contributionAmount || 100,
      cycleType: g.cycleType || 'weekly',
      feePercent: g.feePercent || 1,
      createdAt: g.createdAt || new Date().toISOString()
    };
    await sqlite.createGroup(group);
    migratedCount++;
    if (Array.isArray(g.members)) {
      for (const m of g.members) {
        const member = { id: m.id || generateId(), groupId: group.id, name: m.name, joinedAt: m.joinedAt || new Date().toISOString() };
        await sqlite.addMember(member);
        migratedCount++;
        if (Array.isArray(m.contributions)) {
          for (const c of m.contributions) {
            await sqlite.insertContribution({ id: c.id || generateId(), groupMemberId: member.id, groupId: group.id, amount: c.amount, date: c.date || new Date().toISOString() });
            migratedCount++;
          }
        }
      }
    }
    if (Array.isArray(g.cycles)) {
      for (const c of g.cycles) {
        const cycle = {
          id: c.id || generateId(),
          groupId: group.id,
          createdAt: c.createdAt || new Date().toISOString(),
          paymentDate: c.paymentDate || new Date().toISOString(),
          status: c.status || 'collected',
          grossPot: c.grossPot || 0,
          feePercent: c.feePercent || 1,
          feeAmount: c.feeAmount || 0,
          netPot: c.netPot || 0
        };
        await sqlite.collectCycle(cycle);
        migratedCount++;
        if (c.status === 'paid' && c.recipient) {
          const recipient = await sqlite.findMemberByName(group.id, c.recipient);
          if (recipient) {
            await sqlite.updateMemberBalance(recipient.id, Number((recipient.balance + cycle.netPot).toFixed(2)));
            await sqlite.markCyclePaid(cycle.id, recipient.id, c.paidAt || new Date().toISOString());
          }
        }
      }
    }
  }

  return res.json({ message: 'Migration complete', migrated: migratedCount });
});

// ==================== ADMIN DASHBOARD ====================
app.get('/admin/dashboard', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const userCount = await sqlite.all('SELECT COUNT(*) as count FROM users');
    const groupCount = await sqlite.all('SELECT COUNT(*) as count FROM groups');
    const memberCount = await sqlite.all('SELECT COUNT(*) as count FROM group_members');
    const cycleCount = await sqlite.all('SELECT COUNT(*) as count FROM cycles');
    const totalVolume = await sqlite.all('SELECT SUM(netPot) as total FROM cycles WHERE status = "paid"');
    
    const recentAuditLogs = await sqlite.getAuditLogs({ resource: 'user' });
    const topUsers = await sqlite.all('SELECT email, role, createdAt FROM users ORDER BY createdAt DESC LIMIT 10');
    const topGroups = await sqlite.all(`
      SELECT g.name, g.createdAt, COUNT(gm.id) as memberCount, COUNT(c.id) as cycleCount
      FROM groups g
      LEFT JOIN group_members gm ON g.id = gm.groupId
      LEFT JOIN cycles c ON g.id = c.groupId
      GROUP BY g.id
      ORDER BY g.createdAt DESC
      LIMIT 10
    `);
    
    await sqlite.createAuditLog(req.user.id, 'view', 'admin_dashboard', null, null, req.ip, req.headers['user-agent']);
    
    res.json({
      stats: {
        totalUsers: userCount[0]?.count || 0,
        totalGroups: groupCount[0]?.count || 0,
        totalMembers: memberCount[0]?.count || 0,
        totalCycles: cycleCount[0]?.count || 0,
        totalVolume: totalVolume[0]?.total || 0
      },
      recentAudit: recentAuditLogs?.slice(0, 5),
      topUsers,
      topGroups
    });
  } catch (err) {
    next(err);
  }
});

app.get('/admin/users', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const users = await sqlite.getAllUsers();
    await sqlite.createAuditLog(req.user.id, 'list', 'users', null, null, req.ip, req.headers['user-agent']);
    res.json({ users, total: users.length });
  } catch (err) {
    next(err);
  }
});

app.get('/admin/users/:userId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const stats = await sqlite.getUserStats(req.params.userId);
    if (!stats.user) {
      return res.status(404).json({ error: 'User not found' });
    }
    await sqlite.createAuditLog(req.user.id, 'view', 'user', req.params.userId, null, req.ip, req.headers['user-agent']);
    res.json(stats);
  } catch (err) {
    next(err);
  }
});

app.put('/admin/users/:userId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!role) return res.status(400).json({ error: 'Role is required' });
    
    const oldUser = await sqlite.get('SELECT * FROM users WHERE id = ?', [req.params.userId]);
    if (!oldUser) return res.status(404).json({ error: 'User not found' });
    
    const updated = await sqlite.updateUserRole(req.params.userId, role);
    
    await sqlite.createAuditLog(
      req.user.id,
      'update',
      'user',
      req.params.userId,
      { oldRole: oldUser.role, newRole: role },
      req.ip,
      req.headers['user-agent']
    );
    
    res.json({ message: 'User updated', user: updated });
  } catch (err) {
    next(err);
  }
});

app.delete('/admin/users/:userId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    if (req.user.id === req.params.userId) {
      return res.status(400).json({ error: 'Cannot delete your own account' });
    }
    
    const user = await sqlite.get('SELECT * FROM users WHERE id = ?', [req.params.userId]);
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    await sqlite.run('DELETE FROM users WHERE id = ?', [req.params.userId]);
    
    await sqlite.createAuditLog(
      req.user.id,
      'delete',
      'user',
      req.params.userId,
      { deletedUser: user.email },
      req.ip,
      req.headers['user-agent']
    );
    
    res.json({ message: 'User deleted', userId: req.params.userId });
  } catch (err) {
    next(err);
  }
});

app.get('/admin/groups', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const groups = await sqlite.getAllGroupsAdmin();
    await sqlite.createAuditLog(req.user.id, 'list', 'groups', null, null, req.ip, req.headers['user-agent']);
    res.json({ groups, total: groups.length });
  } catch (err) {
    next(err);
  }
});

app.get('/admin/groups/:groupId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const groupDetails = await sqlite.getGroupDetailsAdmin(req.params.groupId);
    if (!groupDetails) return res.status(404).json({ error: 'Group not found' });
    
    await sqlite.createAuditLog(req.user.id, 'view', 'group', req.params.groupId, null, req.ip, req.headers['user-agent']);
    res.json(groupDetails);
  } catch (err) {
    next(err);
  }
});

app.put('/admin/groups/:groupId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const { name, currency, country, cycleType, contributionAmount } = req.body;
    const group = await sqlite.get('SELECT * FROM groups WHERE id = ?', [req.params.groupId]);
    if (!group) return res.status(404).json({ error: 'Group not found' });
    
    const changes = {};
    if (name && name !== group.name) {
      await sqlite.run('UPDATE groups SET name = ? WHERE id = ?', [name, req.params.groupId]);
      changes.name = { old: group.name, new: name };
    }
    if (currency) {
      await sqlite.run('UPDATE groups SET currency = ? WHERE id = ?', [currency, req.params.groupId]);
      changes.currency = { old: group.currency, new: currency };
    }
    if (country) {
      await sqlite.run('UPDATE groups SET country = ? WHERE id = ?', [country, req.params.groupId]);
      changes.country = { old: group.country, new: country };
    }
    if (cycleType) {
      await sqlite.run('UPDATE groups SET cycleType = ? WHERE id = ?', [cycleType, req.params.groupId]);
      changes.cycleType = { old: group.cycleType, new: cycleType };
    }
    if (contributionAmount) {
      await sqlite.run('UPDATE groups SET contributionAmount = ? WHERE id = ?', [contributionAmount, req.params.groupId]);
      changes.contributionAmount = { old: group.contributionAmount, new: contributionAmount };
    }
    
    await sqlite.createAuditLog(req.user.id, 'update', 'group', req.params.groupId, changes, req.ip, req.headers['user-agent']);
    
    const updated = await sqlite.get('SELECT * FROM groups WHERE id = ?', [req.params.groupId]);
    res.json({ message: 'Group updated', group: updated });
  } catch (err) {
    next(err);
  }
});

app.delete('/admin/groups/:groupId', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const result = await sqlite.deleteGroupCascade(req.params.groupId);
    
    await sqlite.createAuditLog(
      req.user.id,
      'delete',
      'group',
      req.params.groupId,
      { cascadeDeleted: true },
      req.ip,
      req.headers['user-agent']
    );
    
    res.json({ message: 'Group deleted', ...result });
  } catch (err) {
    next(err);
  }
});

app.get('/admin/audit-log', authenticateToken, requireRole('admin'), async (req, res, next) => {
  try {
    const logs = await sqlite.getAuditLogs({
      startDate: req.query.startDate,
      endDate: req.query.endDate,
      action: req.query.action
    });
    
    res.json({ logs, total: logs.length });
  } catch (err) {
    next(err);
  }
});

// ==================== SUPERADMIN DASHBOARD ====================
app.get('/superadmin/dashboard', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const userStats = await sqlite.all(`
      SELECT role, COUNT(*) as count FROM users GROUP BY role
    `);
    
    const systemStats = {
      totalUsers: await sqlite.get('SELECT COUNT(*) as count FROM users'),
      totalGroups: await sqlite.get('SELECT COUNT(*) as count FROM groups'),
      totalCycles: await sqlite.get('SELECT COUNT(*) as count FROM cycles'),
      totalVolume: await sqlite.get('SELECT SUM(netPot) as total FROM cycles WHERE status = "paid"'),
      roleBreakdown: userStats,
      activityTrend: await sqlite.all(`
        SELECT DATE(createdAt) as date, ACTION, COUNT(*) as count FROM audit_logs
        GROUP BY DATE(createdAt), ACTION
        ORDER BY date DESC
        LIMIT 30
      `)
    };
    
    await sqlite.createAuditLog(req.user.id, 'view', 'superadmin_dashboard', null, null, req.ip, req.headers['user-agent']);
    
    res.json(systemStats);
  } catch (err) {
    next(err);
  }
});

app.get('/superadmin/users', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const users = await sqlite.getAllUsers();
    const withStats = await Promise.all(users.map(async (u) => ({
      ...u,
      stats: await sqlite.getUserStats(u.id)
    })));
    
    await sqlite.createAuditLog(req.user.id, 'list', 'all_users', null, null, req.ip, req.headers['user-agent']);
    res.json({ users: withStats, total: withStats.length });
  } catch (err) {
    next(err);
  }
});

app.post('/superadmin/users/:userId/role', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!role) return res.status(400).json({ error: 'Role is required' });
    
    const oldUser = await sqlite.get('SELECT * FROM users WHERE id = ?', [req.params.userId]);
    if (!oldUser) return res.status(404).json({ error: 'User not found' });
    
    const updated = await sqlite.updateUserRole(req.params.userId, role);
    
    await sqlite.createAuditLog(
      req.user.id,
      'change_role',
      'user_role',
      req.params.userId,
      { oldRole: oldUser.role, newRole: role, changedBy: req.user.email },
      req.ip,
      req.headers['user-agent']
    );
    
    res.json({ message: 'User role changed', user: updated });
  } catch (err) {
    next(err);
  }
});

app.get('/superadmin/system/health', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      database: {
        connected: true,
        tables: [
          'users', 'groups', 'group_members', 'contributions', 'cycles', 'audit_logs'
        ]
      },
      uptime: process.uptime(),
      memory: process.memoryUsage()
    };
    
    await sqlite.createAuditLog(req.user.id, 'view', 'system_health', null, null, req.ip, req.headers['user-agent']);
    res.json(health);
  } catch (err) {
    next(err);
  }
});

app.get('/superadmin/audit-log', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const logs = await sqlite.getAuditLogs({
      userId: req.query.userId,
      resource: req.query.resource,
      action: req.query.action,
      startDate: req.query.startDate,
      endDate: req.query.endDate
    });
    
    res.json({ logs, total: logs.length });
  } catch (err) {
    next(err);
  }
});

app.delete('/superadmin/groups/:groupId/force', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const result = await sqlite.deleteGroupCascade(req.params.groupId);
    
    await sqlite.createAuditLog(
      req.user.id,
      'force_delete',
      'group',
      req.params.groupId,
      { cascadeDeleted: true, forcedBy: req.user.email },
      req.ip,
      req.headers['user-agent']
    );
    
    res.json({ message: 'Group force deleted', ...result });
  } catch (err) {
    next(err);
  }
});

app.get('/superadmin/analytics', authenticateToken, requireRole('superadmin'), async (req, res, next) => {
  try {
    const analytics = {
      userEngagement: await sqlite.all(`
        SELECT DATE(g.createdAt) as date, COUNT(DISTINCT g.creatorId) as activeUsers,
               COUNT(DISTINCT c.id) as activeCycles
        FROM groups g
        LEFT JOIN cycles c ON g.id = c.groupId
        GROUP BY DATE(g.createdAt)
        ORDER BY date DESC
        LIMIT 90
      `),
      volumeByPeriod: await sqlite.all(`
        SELECT DATE(c.createdAt) as date, SUM(c.netPot) as volume,
               COUNT(DISTINCT c.groupId) as groupCount,
               COUNT(DISTINCT c.recipientGroupMemberId) as recipients
        FROM cycles c
        WHERE c.status = 'paid'
        GROUP BY DATE(c.createdAt)
        ORDER BY date DESC
        LIMIT 90
      `),
      topGroups: await sqlite.all(`
        SELECT g.name, COUNT(c.id) as cycleCount, SUM(c.netPot) as totalVolume,
               COUNT(gm.id) as memberCount
        FROM groups g
        LEFT JOIN cycles c ON g.id = c.groupId
        LEFT JOIN group_members gm ON g.id = gm.groupId
        GROUP BY g.id
        ORDER BY totalVolume DESC
        LIMIT 20
      `)
    };
    
    await sqlite.createAuditLog(req.user.id, 'view', 'analytics', null, null, req.ip, req.headers['user-agent']);
    res.json(analytics);
  } catch (err) {
    next(err);
  }
});


app.use((err, req, res, next) => {
  const statusCode = err.statusCode || err.status || 500;
  const isDev = process.env.NODE_ENV !== 'production';
  
  logger.error(`[${req.method} ${req.path}] ${err.message}`, {
    statusCode,
    stack: err.stack,
    userId: req.user?.id,
    ip: req.ip
  });

  // Don't expose internal error details in production
  const message = isDev ? err.message : 'Internal server error';
  res.status(statusCode).json({ error: message, ...(isDev && { stack: err.stack }) });
});

// Handle 404
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

const startServer = async () => {
  try {
    await sqlite.init();
    const PORT = process.env.PORT || 3000;
    
    const server = app.listen(PORT, () => {
      logger.info(`osusu server running on port ${PORT} (env: ${process.env.NODE_ENV || 'development'})`);
    });

    // Graceful shutdown
    const gracefulShutdown = async () => {
      logger.info('Received shutdown signal, shutting down gracefully...');
      server.close(async () => {
        try {
          await sqlite.close();
          logger.info('Server shut down successfully');
          process.exit(0);
        } catch (err) {
          logger.error('Error during graceful shutdown', err);
          process.exit(1);
        }
      });

      // Force shutdown after 10 seconds
      setTimeout(() => {
        logger.error('Graceful shutdown timeout, forcing exit');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught exception', error);
      process.exit(1);
    });

    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled rejection', { reason, promise });
      process.exit(1);
    });
  } catch (err) {
    logger.error('Failed to start server', err);
    process.exit(1);
  }
};

if (require.main === module) {
  startServer().catch((err) => { console.error(err); process.exit(1); });
}

module.exports = app;
