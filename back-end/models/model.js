const { oracledb } = require('../config/database');

async function getAllItems() {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute('SELECT * FROM items');
    return result.rows;
  } catch (err) {
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

async function getItemById(id) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute('SELECT * FROM items WHERE id = :id', [id]);
    return result.rows[0];
  } catch (err) {
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

async function createItem(name, description) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      'INSERT INTO items (name, description) VALUES (:name, :description)',
      [name, description],
      { autoCommit: true }
    );
    return result;
  } catch (err) {
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

async function updateItem(id, name, description) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      'UPDATE items SET name = :name, description = :description WHERE id = :id',
      [name, description, id],
      { autoCommit: true }
    );
    return result;
  } catch (err) {
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

async function deleteItem(id) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      'DELETE FROM items WHERE id = :id',
      [id],
      { autoCommit: true }
    );
    return result;
  } catch (err) {
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

module.exports = {
  getAllItems,
  getItemById,
  createItem,
  updateItem,
  deleteItem
};