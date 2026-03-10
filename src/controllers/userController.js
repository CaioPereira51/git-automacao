const userService = require('../services/userService');

function getUsers(req, res) {
  const users = userService.getAllUsers();
  res.status(200).json({ data: users, total: users.length });
}

function createUser(req, res) {
  try {
    const { name, email } = req.body;
    const newUser = userService.createUser({ name, email });
    res.status(201).json({ data: newUser });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

module.exports = { getUsers, createUser };
