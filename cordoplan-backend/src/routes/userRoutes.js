// cordoplan-backend/src/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware'); 

const allAuthenticated = ['Usuario', 'Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS DE AUTENTICACIÓN (RF-U01, RF-P01)
// ----------------------------------------------------------------------

// Maneja la sincronización post-Firebase (Registro o Inicio de Sesión)
// Esta ruta no usa authMiddleware porque *genera* o *recupera* la identidad.
router.post('/sync', userController.sincronizarUsuario);


// ----------------------------------------------------------------------
// RUTAS NFC SOCIAL (USUARIO)
// ----------------------------------------------------------------------

// RF-U08 / CU7: Agregar amigo al escanear la pulsera NFC de otro usuario
router.post('/friends/add/nfc', authMiddleware(allAuthenticated), userController.agregarAmigoNFC);

// Obtener lista de amigos
router.get('/:id_usuario/friends', authMiddleware(allAuthenticated), userController.getListaAmigos);

module.exports = router;