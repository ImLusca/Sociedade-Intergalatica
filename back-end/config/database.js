const oracledb = require('oracledb');

const dbConfig = {
  user: 'your_username',
  password: 'your_password',
  connectString: 'localhost/XEPDB1'
};

async function initialize() {
  try {
    await oracledb.createPool(dbConfig);
    console.log('Connection pool started');
  } catch (err) {
    console.error('Failed to create pool', err);
    throw err;
  }
}

async function close() {
  try {
    await oracledb.getPool().close();
    console.log('Connection pool closed');
  } catch (err) {
    console.error('Failed to close pool', err);
    throw err;
  }
}

module.exports = {
  initialize,
  close,
  oracledb
};