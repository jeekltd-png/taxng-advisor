const request = require('supertest');
const app = require('../src/server');

describe('osusu server API', () => {
  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  test('POST /group and GET /group/:groupName', async () => {
    const groupName = 'test-group';
    await request(app).post('/group').send({ name: groupName }).expect(201);

    const res = await request(app).get(`/group/${groupName}`).expect(200);
    expect(res.body.name).toBe(groupName);
    expect(res.body.totalBalance).toBe(0);
  });

  test('member deposit updates group balance', async () => {
    const groupName = 'deposit-group';
    const memberName = 'alice';

    await request(app).post('/group').send({ name: groupName }).expect(201);
    await request(app).post(`/group/${groupName}/member`).send({ memberName }).expect(201);
    await request(app).post(`/group/${groupName}/member/${memberName}/deposit`).send({ amount: 120 }).expect(200);

    const res = await request(app).get(`/group/${groupName}`).expect(200);
    expect(res.body.totalBalance).toBe(120);
    expect(res.body.members[0].balance).toBe(120);
  });
});
