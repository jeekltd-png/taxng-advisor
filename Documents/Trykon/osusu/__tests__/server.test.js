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
    expect(res.body).toEqual({ status: 'ok' });
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
});
