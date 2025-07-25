const express = require('express');
const router = express.Router();
const cartController = require('../controllers/CartController');

router.get('/:clientID', cartController.getCart);
router.post('/', cartController.insertItem);
router.put('/', cartController.update);
router.post('/convert', cartController.convertCartToOrder);
router.delete('/:cartID/:productID', cartController.deleteItem);


module.exports = router;
