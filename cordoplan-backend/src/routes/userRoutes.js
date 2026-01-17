// cordoplan-backend/src/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware'); 

const allAuthenticated = ['Usuario', 'Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS DE AUTENTICACIÓN 
// ----------------------------------------------------------------------

// Maneja la sincronización post-Firebase (Registro o Inicio de Sesión)
// Esta ruta no usa authMiddleware porque *genera* o *recupera* la identidad.
router.post('/sync', userController.sincronizarUsuario);


// ----------------------------------------------------------------------
// RUTAS NFC SOCIAL (USUARIO)
// ----------------------------------------------------------------------

router.post('/friends/add/nfc', authMiddleware(allAuthenticated), userController.agregarAmigoNFC);

router.get('/:id_usuario/friends', authMiddleware(allAuthenticated), userController.getListaAmigos);

module.exports = router;