let users = [
  { id: 1, name: 'Carlos Backend', email: 'carlos@example.com', createdAt: new Date('2025-01-01').toISOString() },
  { id: 2, name: 'Diana Dev', email: 'diana@example.com', createdAt: new Date('2025-01-15').toISOString() },
  { id: 3, name: 'Eduardo API', email: 'eduardo@example.com', createdAt: new Date('2025-02-01').toISOString() },
];

let nextId = 4;

function getAllUsers() {
  return users;
}

function getUserById(id) {
  return users.find((u) => u.id === id) || null;
}

function createUser({ name, email }) {
  if (!name || !email) {
    throw new Error('Os campos name e email são obrigatórios');
  }

  const emailExists = users.some((u) => u.email === email);
  if (emailExists) {
    throw new Error('E-mail já cadastrado');
  }

  const newUser = {
    id: nextId++,
    name,
    email,
    createdAt: new Date().toISOString(),
  };

  users.push(newUser);
  return newUser;
}

function resetUsers() {
  users = [
    { id: 1, name: 'Carlos Backend', email: 'carlos@example.com', createdAt: new Date('2025-01-01').toISOString() },
    { id: 2, name: 'Diana Dev', email: 'diana@example.com', createdAt: new Date('2025-01-15').toISOString() },
    { id: 3, name: 'Eduardo API', email: 'eduardo@example.com', createdAt: new Date('2025-02-01').toISOString() },
  ];
  nextId = 4;
}

module.exports = { getAllUsers, getUserById, createUser, resetUsers };
