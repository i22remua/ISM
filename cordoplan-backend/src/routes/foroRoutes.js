// cordoplan-backend/src/routes/foroRoutes.js
const express = require('express');
const router = express.Router();
const foroController = require('../controllers/foroController');
const authMiddleware = require('../middleware/authMiddleware');

// Proteger todas las rutas del foro para que solo usuarios autenticados puedan acceder
const allAuthenticated = ['Usuario', 'Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS DEL FORO DE LOCALES
// ----------------------------------------------------------------------

// FIX: Corregido el parámetro de la ruta a ':localId' y la función a 'getMessages'
router.get('/:localId/messages', authMiddleware(allAuthenticated), foroController.getMessages);

// FIX: Corregido el parámetro de la ruta a ':localId' y la función a 'postMessage'
router.post('/:localId/messages', authMiddleware(allAuthenticated), foroController.postMessage);

module.exports = router;
