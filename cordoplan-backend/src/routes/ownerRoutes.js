// src/routes/ownerRoutes.js
const express = require('express');
const router = express.Router();
const localController = require('../controllers/localController');
const authMiddleware = require('../middleware/authMiddleware');

const ownerOnly = ['Propietario'];


router.get('/my-local', authMiddleware(ownerOnly), localController.getMyLocal);

module.exports = router;
