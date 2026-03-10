const request = require('supertest');
const app = require('../app');

describe('GET /health', () => {
  it('deve retornar status 200 com status ok', async () => {
    const res = await request(app).get('/health');

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  it('deve retornar timestamp válido', async () => {
    const res = await request(app).get('/health');

    expect(res.body.timestamp).toBeDefined();
    expect(new Date(res.body.timestamp).toString()).not.toBe('Invalid Date');
  });

  it('deve retornar uptime como número positivo', async () => {
    const res = await request(app).get('/health');

    expect(typeof res.body.uptime).toBe('number');
    expect(res.body.uptime).toBeGreaterThan(0);
  });
});
