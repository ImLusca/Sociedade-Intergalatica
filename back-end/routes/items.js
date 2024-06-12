
const express = require('express');
const itemController = require('../controllers/model');
const router = express.Router();

router.get('/items', itemController.getAllItems);
router.get('/items/:id', itemController.getItemById);
router.post('/items', itemController.createItem);
router.put('/items/:id', itemController.updateItem);
router.delete('/items/:id', itemController.deleteItem);

module.exports = router;