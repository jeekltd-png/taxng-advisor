require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const jwt = require('jsonwebtoken');
const { Member, OsusuGroup } = require('./osusu');

const path = require('path');
const app = express();
app.use(express.json());
app.use(morgan('dev'));
app.use(express.static(path.join(__dirname, 'public')));

const bcrypt = require('bcryptjs');
const groups = new Map();
const users = new Map(); // email => { id, email, passwordHash }

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_on_prod';
const JWT_EXPIRES_IN = '2h';

const generateId = () => 'u_' + Math.random().toString(36).slice(2, 12);

const generateToken = (user) => jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

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

// Auth endpoints
app.post('/auth/signup', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });
  if (users.has(email.toLowerCase())) return res.status(409).json({ error: 'Email already registered' });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = { id: generateId(), email: email.toLowerCase(), passwordHash };
  users.set(user.email, user);
  const publicUser = { id: user.id, email: user.email };
  const token = generateToken(publicUser);
  return res.status(201).json({ user: publicUser, token });
});

app.post('/auth/signin', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });
  const user = users.get(email.toLowerCase());
  if (!user) return res.status(401).json({ error: 'Invalid email or password' });
  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return res.status(401).json({ error: 'Invalid email or password' });
  const publicUser = { id: user.id, email: user.email };
  const token = generateToken(publicUser);
  return res.json({ user: publicUser, token });
});

app.post('/auth/forgot', (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email required' });
  if (!users.has(email.toLowerCase())) return res.status(404).json({ error: 'Email not found' });
  // in production, send password reset email via SMTP/service.
  return res.json({ message: 'Password reset link sent (mock)' });
});

app.get('/auth/oauth/:provider', (req, res) => {
  const { provider } = req.params;
  if (!['google','twitter','facebook'].includes(provider)) return res.status(400).json({ error: 'Unsupported provider' });
  // Mock oauth redirect workflow
  const user = { id: generateId(), email: `${provider}-user@example.com`, provider };
  users.set(user.email, { id: user.id, email: user.email, passwordHash: '' });
  const token = generateToken({ id: user.id, email: user.email });
  return res.json({ user: { id: user.id, email: user.email, provider }, token });
});

app.post('/auth/logout', (req, res) => {
  // Stateless JWT: frontend should remove token. this endpoint helps UI though.
  return res.json({ message: 'Logged out' });
});

app.post('/group', authenticateToken, (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: 'Group name is required' });
  if (groups.has(name)) return res.status(409).json({ error: 'Group already exists' });

  groups.set(name, new OsusuGroup(name));
  return res.status(201).json({ name, totalBalance: 0 });
});

app.post('/group/:groupName/member', (req, res) => {
  const { groupName } = req.params;
  const { memberName } = req.body;
  const group = groups.get(groupName);

  if (!group) return res.status(404).json({ error: 'Group not found' });
  if (!memberName) return res.status(400).json({ error: 'memberName is required' });

  const member = new Member(memberName);
  group.addMember(member);
  return res.status(201).json({ group: groupName, member: memberName });
});

app.post('/group/:groupName/member/:memberName/deposit', (req, res) => {
  const { groupName, memberName } = req.params;
  const { amount } = req.body;
  const group = groups.get(groupName);

  if (!group) return res.status(404).json({ error: 'Group not found' });
  const member = group.members.find((m) => m.name === memberName);
  if (!member) return res.status(404).json({ error: 'Member not found' });
  if (!amount || amount <= 0) return res.status(400).json({ error: 'amount must be positive' });

  member.deposit(amount);
  return res.status(200).json({ member: memberName, balance: member.balance });
});

app.get('/group/:groupName', (req, res) => {
  const { groupName } = req.params;
  const group = groups.get(groupName);
  if (!group) return res.status(404).json({ error: 'Group not found' });

  return res.status(200).json({
    name: group.name,
    totalBalance: group.totalBalance,
    members: group.members.map((m) => ({ name: m.name, balance: m.balance }))
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
