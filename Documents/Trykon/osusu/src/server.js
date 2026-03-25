require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const bcrypt = require('bcryptjs');
const path = require('path');
const sqlite = require('./sqlite');

const app = express();
app.use(helmet());
app.use(express.json());
app.use(morgan('dev'));

const limiter = rateLimit({ windowMs: 60 * 1000, max: 100, standardHeaders: true, legacyHeaders: false });
app.use(limiter);

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_on_prod';
const JWT_EXPIRES_IN = '2h';
const REFRESH_TOKEN_EXPIRES_IN = '7d';

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

app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

app.post('/test/clear', async (req, res) => {
  try {
    await sqlite.clearAll();
    return res.status(200).json({ message: 'Test db cleared' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/auth/signup', async (req, res) => {
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

app.post('/auth/signin', async (req, res) => {
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

app.post('/auth/forgot', async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const user = await sqlite.findUserByEmail(value.email.toLowerCase());
  if (!user) return res.status(404).json({ error: 'Email not found' });

  const resetToken = generateToken({ id: user.id, email: user.email, role: user.role });
  console.log(`[auth/forgot] reset token for ${user.email}: ${resetToken}`);
  return res.json({ message: 'Password reset link sent (mock)', resetToken });
});

app.post('/auth/oauth/:provider', async (req, res) => {
  const provider = req.params.provider;
  if (!['google', 'twitter', 'facebook'].includes(provider)) return res.status(400).json({ error: 'Unsupported provider' });
  const email = `${provider}-user@example.com`;
  let user = await sqlite.findUserByEmail(email);
  if (!user) {
    user = { id: generateId(), email, passwordHash: '', role: 'user', createdAt: new Date().toISOString() };
    await sqlite.createUser(user);
  }
  const publicUser = { id: user.id, email: user.email, role: user.role };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.json({ user: { id: user.id, email: user.email, provider }, token, refreshToken });
});

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

app.post('/group/:groupName/collect', authenticateToken, async (req, res) => {
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

  await sqlite.collectCycle(cycle);

  res.status(200).json({ message: 'Collection completed', grossPot, feeAmount, netPot, cycle });
});

app.post('/group/:groupName/payout', authenticateToken, async (req, res) => {
  const recipient = req.body.recipient;
  if (!recipient) return res.status(400).json({ error: 'Recipient is required' });

  const group = await sqlite.findGroupByName(req.params.groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const cycle = await sqlite.findLatestCycleByGroup(group.id);
  if (!cycle || cycle.status === 'paid') return res.status(400).json({ error: 'No cycle available for payout' });

  const member = await sqlite.findMemberByName(group.id, recipient);
  if (!member) return res.status(404).json({ error: 'Recipient member not found' });

  const memberNewBalance = Number((member.balance + cycle.netPot).toFixed(2));
  await sqlite.updateMemberBalance(member.id, memberNewBalance);

  await sqlite.markCyclePaid(cycle.id, member.id, new Date().toISOString());

  res.status(200).json({ message: 'Payout successful', recipient, netPayout: cycle.netPot, grossPot: cycle.grossPot, feeAmount: cycle.feeAmount, cycleId: cycle.id });
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

app.get('/reports/user', authenticateToken, async (req, res) => {
  const membership = await sqlite.all(`
    SELECT g.name AS groupName, gm.balance,
      COALESCE((SELECT SUM(amount) FROM contributions c WHERE c.groupMemberId = gm.id), 0) AS totalContributed
    FROM group_members gm
    JOIN groups g ON gm.groupId = g.id
    WHERE g.creatorId = ? OR ? = g.creatorId
    ORDER BY g.name
  `, [req.user.id, req.user.id]);

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
  if (!fs.existsSync(jsonPath)) return res.status(404).json({ error: 'db.json not found' });

  const raw = fs.readFileSync(jsonPath, 'utf8');
  const parsed = JSON.parse(raw);
  await sqlite.clearAll();

  const users = (parsed.users || []).map((u) => ({ id: u.id || generateId(), email: u.email, passwordHash: u.passwordHash || '', role: u.role || 'user', createdAt: u.createdAt || new Date().toISOString() }));
  for (const u of users) await sqlite.createUser(u);

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
    if (Array.isArray(g.members)) {
      for (const m of g.members) {
        const member = { id: m.id || generateId(), groupId: group.id, name: m.name, joinedAt: m.joinedAt || new Date().toISOString() };
        await sqlite.addMember(member);
        if (Array.isArray(m.contributions)) {
          for (const c of m.contributions) {
            await sqlite.insertContribution({ id: c.id || generateId(), groupMemberId: member.id, groupId: group.id, amount: c.amount, date: c.date || new Date().toISOString() });
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

  return res.json({ message: 'Migration complete' });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

const startServer = async () => {
  await sqlite.init();
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`osusu server running on port ${PORT}`));
};

if (require.main === module) {
  startServer().catch((err) => { console.error(err); process.exit(1); });
}

module.exports = app;
