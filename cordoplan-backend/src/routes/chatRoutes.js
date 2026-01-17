// cordoplan-backend/src/routes/chatRoutes.js
const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

// Proteger todas las rutas del chat para que solo usuarios autenticados puedan acceder
const allAuthenticated = ['Usuario', 'Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS DEL CHAT 
// ----------------------------------------------------------------------

router.post('/send', authMiddleware(allAuthenticated), chatController.enviarMensaje);

router.get('/history/:id_amigo', authMiddleware(allAuthenticated), chatController.getHistorialChat);


module.exports = router;
