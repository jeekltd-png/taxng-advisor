require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const fs = require('fs');
const { Member, OsusuGroup } = require('./osusu');

const path = require('path');
const dbFile = path.join(__dirname, 'db.json');

const readDb = () => {
  try {
    if (!fs.existsSync(dbFile)) {
      const initial = { users: [], groups: [] };
      fs.writeFileSync(dbFile, JSON.stringify(initial, null, 2));
      return initial;
    }
    const text = fs.readFileSync(dbFile, 'utf-8');
    const parsed = JSON.parse(text || '{}');
    return { users: parsed.users || [], groups: parsed.groups || [] };
  } catch (err) {
    console.error('Could not read db file', err);
    return { users: [], groups: [] };
  }
};

const writeDb = (data) => {
  fs.writeFileSync(dbFile, JSON.stringify(data, null, 2));
};

let db = readDb();

const app = express();
app.use(helmet());
app.use(express.json());
app.use(morgan('dev'));
app.use(express.static(path.join(__dirname, 'public')));

const limiter = rateLimit({ windowMs: 60 * 1000, max: 100, standardHeaders: true, legacyHeaders: false });
app.use(limiter);

const bcrypt = require('bcryptjs');

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_on_prod';
const JWT_EXPIRES_IN = '2h';
const REFRESH_TOKEN_EXPIRES_IN = '7d';

const generateId = () => 'u_' + Math.random().toString(36).slice(2, 12);

const generateToken = (user) => jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
const generateRefreshToken = (user) => jwt.sign({ id: user.id, email: user.email, type: 'refresh' }, JWT_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRES_IN });

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

app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// Test helper endpoint (clears DB state in current server instance)
app.post('/test/clear', (req, res) => {
  db = { users: [], groups: [] };
  writeDb(db);
  return res.status(200).json({ message: 'Test db cleared' });
});

// Auth endpoints
app.post('/auth/signup', async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required(), password: Joi.string().min(8).required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const email = value.email.toLowerCase();
  const password = value.password;
  const existing = db.users.find((u) => u.email === email);
  if (existing) return res.status(409).json({ error: 'Email already registered' });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = { id: generateId(), email, passwordHash };
  db.users.push(user);
  writeDb(db);

  const publicUser = { id: user.id, email: user.email };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.status(201).json({ user: publicUser, token, refreshToken });
});

app.post('/auth/signin', async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required(), password: Joi.string().min(8).required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const email = value.email.toLowerCase();
  const password = value.password;
  const user = db.users.find((u) => u.email === email);
  if (!user) return res.status(401).json({ error: 'Invalid email or password' });
  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return res.status(401).json({ error: 'Invalid email or password' });
  const publicUser = { id: user.id, email: user.email };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.json({ user: publicUser, token, refreshToken });
});

app.post('/auth/forgot', async (req, res) => {
  const schema = Joi.object({ email: Joi.string().email().required() });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const email = value.email.toLowerCase();
  const user = db.users.find((u) => u.email === email);
  if (!user) return res.status(404).json({ error: 'Email not found' });

  // in production, send password reset email via SMTP/service.
  const resetToken = generateToken(user);
  // Assume email send; store or log for debug
  console.log(`[auth/forgot] reset token for ${email}: ${resetToken}`);
  return res.json({ message: 'Password reset link sent (mock)', resetToken });
});

app.get('/auth/oauth/:provider', (req, res) => {
  const { provider } = req.params;
  if (!['google','twitter','facebook'].includes(provider)) return res.status(400).json({ error: 'Unsupported provider' });
  // Mock oauth redirect workflow
  const user = { id: generateId(), email: `${provider}-user@example.com`, provider };
  if (!db.users.find((u) => u.email === user.email)) {
    db.users.push({ id: user.id, email: user.email, passwordHash: '' });
    writeDb(db);
  }
  const publicUser = { id: user.id, email: user.email };
  const token = generateToken(publicUser);
  const refreshToken = generateRefreshToken(publicUser);
  return res.json({ user: { id: user.id, email: user.email, provider }, token, refreshToken });
});

app.post('/auth/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

  jwt.verify(refreshToken, JWT_SECRET, (err, decoded) => {
    if (err || decoded.type !== 'refresh') return res.status(401).json({ error: 'Invalid refresh token' });
    const user = { id: decoded.id, email: decoded.email };
    const token = generateToken(user);
    const nextRefreshToken = generateRefreshToken(user);
    res.json({ token, refreshToken: nextRefreshToken });
  });
});

app.post('/auth/logout', (req, res) => {
  // Stateless JWT: frontend should remove token. this endpoint helps UI though.
  return res.json({ message: 'Logged out' });
});

app.post('/group', authenticateToken, async (req, res) => {
  const schema = Joi.object({
    name: Joi.string().min(3).max(100).required(),
    currency: Joi.string().optional().default('GBP'),
    locale: Joi.string().optional().default('en-GB'),
    country: Joi.string().optional().default('UK'),
    contributionAmount: Joi.number().positive().default(100),
    cycleType: Joi.string().valid('weekly','biweekly','monthly').default('weekly')
  });
  const { error, value } = schema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const existing = db.groups.find((g) => g.name === value.name);
  if (existing) return res.status(409).json({ error: 'Group already exists' });

  const group = new OsusuGroup(value.name, value);
  const groupData = {
    id: generateId(),
    ...value,
    members: [],
    creatorId: req.user.id,
    createdAt: new Date().toISOString()
  };
  db.groups.push(groupData);
  writeDb(db);


  return res.status(201).json({
    name: groupData.name,
    currency: groupData.currency,
    locale: groupData.locale,
    country: groupData.country,
    contributionAmount: groupData.contributionAmount,
    cycleType: groupData.cycleType,
    totalBalance: 0
  });
});

app.post('/group/:groupName/member', authenticateToken, async (req, res) => {
  const { groupName } = req.params;
  const { memberName } = req.body;
  if (!memberName) return res.status(400).json({ error: 'memberName is required' });

  const group = db.groups.find((g) => g.name === groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const existingMember = group.members.find((m) => m.name === memberName);
  if (existingMember) return res.status(409).json({ error: 'Member already exists' });

  const member = {
    id: generateId(),
    name: memberName,
    balance: 0,
    contributions: []
  };
  group.members.push(member);
  await db.write();
  return res.status(201).json({ group: groupName, member: memberName });
});

app.post('/group/:groupName/member/:memberName/deposit', authenticateToken, async (req, res) => {
  const { groupName, memberName } = req.params;
  const { amount } = req.body;
  const group = db.groups.find((g) => g.name === groupName);

  if (!group) return res.status(404).json({ error: 'Group not found' });
  const member = group.members.find((m) => m.name === memberName);
  if (!member) return res.status(404).json({ error: 'Member not found' });
  if (!amount || amount <= 0) return res.status(400).json({ error: 'amount must be positive' });

  member.balance += Number(amount);
  member.contributions.push({ amount: Number(amount), date: new Date().toISOString() });
  await db.write();

  return res.status(200).json({ member: memberName, balance: member.balance });
});

app.get('/exchange-rate', (req, res) => {
  const from = (req.query.from || 'GBP').toUpperCase();
  const to = (req.query.to || 'USD').toUpperCase();
  const rates = {
    USD: 1.0,
    GBP: 0.78,
    EUR: 0.93,
    NGN: 1350.0,
    GHS: 11.2,
    JMD: 156.3
  };
  if (!rates[from] || !rates[to]) return res.status(400).json({ error: 'Unsupported currency' });
  const value = rates[to] / rates[from];
  return res.json({ from, to, rate: Number(value.toFixed(6)) });
});

app.get('/group/:groupName', authenticateToken, async (req, res) => {
  const { groupName } = req.params;
  const group = db.groups.find((g) => g.name === groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const totalBalance = group.members.reduce((sum, m) => sum + Number(m.balance || 0), 0);
  return res.status(200).json({
    name: group.name,
    currency: group.currency,
    locale: group.locale,
    country: group.country,
    contributionAmount: group.contributionAmount,
    cycleType: group.cycleType,
    totalBalance,
    members: group.members.map((m) => ({ name: m.name, balance: m.balance })),
    cycles: group.cycles || []
  });
});

// Controller for collecting current cycle contributions and computing pot totals
app.post('/group/:groupName/collect', authenticateToken, async (req, res) => {
  const { groupName } = req.params;
  const group = db.groups.find((g) => g.name === groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const activeMembers = group.members.length;
  if (activeMembers === 0) return res.status(400).json({ error: 'No members in group to collect from' });

  const grossPot = Number(group.contributionAmount) * activeMembers;
  const feePercent = Number(group.feePercent || 1);
  const feeAmount = Number((grossPot * feePercent / 100).toFixed(2));
  const netPot = Number((grossPot - feeAmount).toFixed(2));

  const cycle = {
    id: generateId(),
    createdAt: new Date().toISOString(),
    paymentDate: new Date().toISOString(),
    status: 'collected',
    grossPot,
    feePercent,
    feeAmount,
    netPot,
    recipient: null
  };

  group.cycles = group.cycles || [];
  group.cycles.push(cycle);
  writeDb(db);

  return res.status(200).json({
    message: 'Collection completed',
    grossPot,
    feeAmount,
    netPot,
    cycle
  });
});

// Payout from the collected pot to designated recipient
app.post('/group/:groupName/payout', authenticateToken, async (req, res) => {
  const { groupName } = req.params;
  const { recipient } = req.body;

  if (!recipient) return res.status(400).json({ error: 'Recipient is required' });
  const group = db.groups.find((g) => g.name === groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  if (!group.cycles || group.cycles.length === 0) return res.status(400).json({ error: 'No cycle has been collected' });
  const currentCycle = group.cycles[group.cycles.length -1];
  if (currentCycle.status === 'paid') return res.status(400).json({ error: 'Current cycle already paid' });

  const member = group.members.find((m) => m.name === recipient);
  if (!member) return res.status(404).json({ error: 'Recipient member not found' });

  // credit member net payout to member balance; in real app we'd transfer via Stripe.
  member.balance = Number((member.balance || 0) + currentCycle.netPot).toFixed(2);
  currentCycle.status = 'paid';
  currentCycle.recipient = recipient;
  currentCycle.paidAt = new Date().toISOString();

  writeDb(db);

  return res.status(200).json({
    message: 'Payout successful',
    recipient,
    netPayout: currentCycle.netPot,
    grossPot: currentCycle.grossPot,
    feeAmount: currentCycle.feeAmount,
    cycle: currentCycle
  });
});

// Group status endpoint with full pot details
app.get('/group/:groupName/status', authenticateToken, async (req, res) => {
  const { groupName } = req.params;
  const group = db.groups.find((g) => g.name === groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  const mostRecentCycle = group.cycles ? group.cycles[group.cycles.length - 1] : null;
  const uniqueMembers = group.members.map((m) => m.name);

  return res.status(200).json({
    group: {
      name: group.name,
      currency: group.currency,
      locale: group.locale,
      country: group.country,
      contributionAmount: group.contributionAmount,
      cycleType: group.cycleType,
      memberCount: uniqueMembers.length
    },
    stats: {
      totalCollected: mostRecentCycle ? mostRecentCycle.grossPot : 0,
      totalFee: mostRecentCycle ? mostRecentCycle.feeAmount : 0,
      netPayout: mostRecentCycle ? mostRecentCycle.netPot : 0,
      lastCycleStatus: mostRecentCycle ? mostRecentCycle.status : 'none'
    },
    members: group.members,
    cycles: group.cycles || []
  });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => console.log(`osusu server running on port ${PORT}`));
}

module.exports = app;
