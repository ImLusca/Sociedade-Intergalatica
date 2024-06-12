const express = require('express');
const bodyParser = require('body-parser');
const db = require('./config/database');
const itemRoutes = require('./routes/items');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use('/api', itemRoutes);

async function startServer() {
  try {
    await db.initialize();
    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}/`);
    });
  } catch (err) {
    console.error('Failed to start server', err);
  }
}

process.on('SIGTERM', async () => {
  await db.close();
  process.exit(0);
});

startServer();