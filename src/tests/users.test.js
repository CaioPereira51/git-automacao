const request = require('supertest');
const app = require('../app');
const { resetUsers } = require('../services/userService');

beforeEach(() => {
  resetUsers();
});

describe('GET /users', () => {
  it('deve retornar status 200', async () => {
    const res = await request(app).get('/users');

    expect(res.statusCode).toBe(200);
  });

  it('deve retornar lista de usuários com total', async () => {
    const res = await request(app).get('/users');

    expect(res.body).toHaveProperty('data');
    expect(res.body).toHaveProperty('total');
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('deve retornar os usuários padrão do seed', async () => {
    const res = await request(app).get('/users');

    expect(res.body.total).toBe(2);
    expect(res.body.data[0].name).toBe('Alice Silva');
    expect(res.body.data[1].name).toBe('Bob Souza');
  });
});

describe('POST /users', () => {
  it('deve criar um novo usuário com dados válidos', async () => {
    const novoUsuario = { name: 'Carlos Lima', email: 'carlos@example.com' };
    const res = await request(app).post('/users').send(novoUsuario);

    expect(res.statusCode).toBe(201);
    expect(res.body.data).toMatchObject(novoUsuario);
    expect(res.body.data.id).toBeDefined();
    expect(res.body.data.createdAt).toBeDefined();
  });

  it('deve refletir o novo usuário na listagem', async () => {
    await request(app)
      .post('/users')
      .send({ name: 'Carlos Lima', email: 'carlos@example.com' });

    const res = await request(app).get('/users');

    expect(res.body.total).toBe(3);
    expect(res.body.data.find((u) => u.email === 'carlos@example.com')).toBeTruthy();
  });

  it('deve retornar 400 quando o nome estiver ausente', async () => {
    const res = await request(app)
      .post('/users')
      .send({ email: 'semNome@example.com' });

    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBeDefined();
  });

  it('deve retornar 400 quando o email estiver ausente', async () => {
    const res = await request(app)
      .post('/users')
      .send({ name: 'Sem Email' });

    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBeDefined();
  });

  it('deve retornar 400 para email duplicado', async () => {
    const usuario = { name: 'Alice Duplicada', email: 'alice@example.com' };
    const res = await request(app).post('/users').send(usuario);

    expect(res.statusCode).toBe(400);
    expect(res.body.error).toMatch(/e-mail já cadastrado/i);
  });
});
