const express = require('express');
const userRoutes = require('./routes/userRoutes');
const healthRoutes = require('./routes/healthRoutes');

const app = express();

app.use(express.json());

app.use('/health', healthRoutes);
app.use('/users', userRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

module.exports = app;
