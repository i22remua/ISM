// cordoplan-backend/src/routes/adminRoutes.js
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');

const adminOnly = ['Administrador']; // Solo Administrador puede acceder

// ----------------------------------------------------------------------
// RUTAS DE GESTIÓN DE CUENTAS (CU13)
// ----------------------------------------------------------------------

// Obtener una lista de todas las cuentas
router.get('/users', authMiddleware(adminOnly), adminController.getAllCuentas);

// Modificar datos de cualquier usuario
router.put('/users/:id_usuario_objetivo', authMiddleware(adminOnly), adminController.modificarCuenta); 

// Eliminar una cuenta de usuario
router.delete('/users/:id_usuario_objetivo', authMiddleware(adminOnly), adminController.eliminarCuenta);

// ----------------------------------------------------------------------
// RUTAS DE GESTIÓN DE LOCALES (CU14)
// ----------------------------------------------------------------------

// Gestionar (Activar/Desactivar/Eliminar) locales registrados
router.post('/locales/:id_local', authMiddleware(adminOnly), adminController.gestionarLocalAdmin);


// ----------------------------------------------------------------------
// RUTAS DE MONITOREO (RF-A05)
// ----------------------------------------------------------------------

// Monitorear aforo global y estado del sistema
router.get('/monitor/aforo', authMiddleware(adminOnly), adminController.monitorearAforoGlobal);


module.exports = router;
