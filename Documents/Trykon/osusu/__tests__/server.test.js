const fs = require('fs');
const path = require('path');
const request = require('supertest');
const app = require('../src/server');
const dbPath = path.join(__dirname, '..', 'src', 'db.json');

describe('osusu server API', () => {
  beforeEach(async () => {
    if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
    await request(app).post('/test/clear');
  });
  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status');
    expect(res.body.status).toBe('ok');
    expect(res.body).toHaveProperty('database');
    expect(res.body).toHaveProperty('memory');
    expect(res.body).toHaveProperty('uptime');
    expect(res.body.database.healthy).toBe(true);
  });

  test('POST /group and GET /group/:groupName', async () => {
    const signup = await request(app).post('/auth/signup').send({ email: 'test@example.com', password: 'Password123!' }).expect(201);
    const token = signup.body.token;

    const groupName = 'test-group';
    await request(app).post('/group').set('Authorization', `Bearer ${token}`).send({ name: groupName }).expect(201);

    const res = await request(app).get(`/group/${groupName}`).set('Authorization', `Bearer ${token}`).expect(200);
    expect(res.body.name).toBe(groupName);
    expect(res.body.totalBalance).toBe(0);
  });

  test('member deposit updates group balance', async () => {
    const signup = await request(app).post('/auth/signup').send({ email: 'deposit@example.com', password: 'Password123!' }).expect(201);
    const token = signup.body.token;

    const groupName = 'deposit-group';
    const memberName = 'alice';

    await request(app).post('/group').set('Authorization', `Bearer ${token}`).send({ name: groupName }).expect(201);
    await request(app).post(`/group/${groupName}/member`).set('Authorization', `Bearer ${token}`).send({ memberName }).expect(201);
    await request(app).post(`/group/${groupName}/member/${memberName}/deposit`).set('Authorization', `Bearer ${token}`).send({ amount: 120 }).expect(200);

    const res = await request(app).get(`/group/${groupName}`).set('Authorization', `Bearer ${token}`).expect(200);
    expect(res.body.totalBalance).toBe(120);
    expect(res.body.members[0].balance).toBe(120);
  });

  test('reports end-to-end: user/admin/superadmin', async () => {
    const adminSignup = await request(app).post('/auth/signup').send({ email: 'admin@example.com', password: 'Password123!', role: 'admin' }).expect(201);
    const adminToken = adminSignup.body.token;

    const superSignup = await request(app).post('/auth/signup').send({ email: 'super@example.com', password: 'Password123!', role: 'superadmin' }).expect(201);
    const superToken = superSignup.body.token;

    const userSignup = await request(app).post('/auth/signup').send({ email: 'user@example.com', password: 'Password123!', role: 'user' }).expect(201);
    const userToken = userSignup.body.token;

    await request(app).post('/group').set('Authorization', `Bearer ${userToken}`).send({ name: 'reports-group' }).expect(201);
    await request(app).post('/group/reports-group/member').set('Authorization', `Bearer ${userToken}`).send({ memberName: 'bob' }).expect(201);
    await request(app).post('/group/reports-group/member/bob/deposit').set('Authorization', `Bearer ${userToken}`).send({ amount: 100 }).expect(200);

    const userReport = await request(app).get('/reports/user').set('Authorization', `Bearer ${userToken}`).expect(200);
    expect(userReport.body.data).toBeDefined();

    const adminReport = await request(app).get('/reports/admin').set('Authorization', `Bearer ${adminToken}`).expect(200);
    expect(adminReport.body.stats.activeGroups).toBeGreaterThanOrEqual(1);

    const superReport = await request(app).get('/reports/superadmin').set('Authorization', `Bearer ${superToken}`).expect(200);
    expect(superReport.body.roleBreakdown).toEqual(expect.arrayContaining([expect.objectContaining({ role: 'superadmin' })]));
  });

  test('migrate /migrate-from-json endpoint', async () => {
    const signup = await request(app).post('/auth/signup').send({ email: 'migrate@example.com', password: 'Password123!' }).expect(201);
    const token = signup.body.token;

    const groupName = 'migrate-group';
    await request(app).post('/group').set('Authorization', `Bearer ${token}`).send({ name: groupName }).expect(201);

    const res = await request(app).post('/migrate-from-json').expect(200);
    expect(res.body.message).toBe('Migration complete');
  });
});
