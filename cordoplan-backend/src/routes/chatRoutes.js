// cordoplan-backend/src/routes/chatRoutes.js
const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

// Proteger todas las rutas del chat para que solo usuarios autenticados puedan acceder
const allAuthenticated = ['Usuario', 'Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS DEL CHAT (CU6)
// ----------------------------------------------------------------------

// CU6: Enviar un mensaje a un amigo
router.post('/send', authMiddleware(allAuthenticated), chatController.enviarMensaje);

// CU6: Obtener el historial de chat con un amigo
router.get('/history/:id_amigo', authMiddleware(allAuthenticated), chatController.getHistorialChat);


module.exports = router;
