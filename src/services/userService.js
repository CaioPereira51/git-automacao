let users = [
  { id: 1, name: 'Alice Silva', email: 'alice@example.com', createdAt: new Date('2025-01-01').toISOString() },
  { id: 2, name: 'Bob Souza', email: 'bob@example.com', createdAt: new Date('2025-01-15').toISOString() },
];

let nextId = 3;

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
    { id: 1, name: 'Alice Silva', email: 'alice@example.com', createdAt: new Date('2025-01-01').toISOString() },
    { id: 2, name: 'Bob Souza', email: 'bob@example.com', createdAt: new Date('2025-01-15').toISOString() },
  ];
  nextId = 3;
}

module.exports = { getAllUsers, getUserById, createUser, resetUsers };
