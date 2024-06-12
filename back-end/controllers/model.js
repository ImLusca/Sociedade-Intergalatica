const itemModel = require('../models/model');

async function getAllItems(req, res) {
  try {
    const items = await itemModel.getAllItems();
    res.json(items);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

async function getItemById(req, res) {
  try {
    const item = await itemModel.getItemById(req.params.id);
    if (item) {
      res.json(item);
    } else {
      res.status(404).send('Item not found');
    }
  } catch (err) {
    res.status(500).send(err.message);
  }
}

async function createItem(req, res) {
  try {
    const { name, description } = req.body;
    await itemModel.createItem(name, description);
    res.status(201).send('Item created');
  } catch (err) {
    res.status(500).send(err.message);
  }
}

async function updateItem(req, res) {
  try {
    const { name, description } = req.body;
    await itemModel.updateItem(req.params.id, name, description);
    res.send('Item updated');
  } catch (err) {
    res.status(500).send(err.message);
  }
}

async function deleteItem(req, res) {
  try {
    await itemModel.deleteItem(req.params.id);
    res.send('Item deleted');
  } catch (err) {
    res.status(500).send(err.message);
  }
}

module.exports = {
  getAllItems,
  getItemById,
  createItem,
  updateItem,
  deleteItem
};
