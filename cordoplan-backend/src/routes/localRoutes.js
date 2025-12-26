// cordoplan-backend/src/routes/localRoutes.js
const express = require('express');
const router = express.Router();
const localController = require('../controllers/localController');
const authMiddleware = require('../middleware/authMiddleware');

// --- Roles ---
const ownerOrAdmin = ['Propietario', 'Administrador'];

// ----------------------------------------------------------------------
// RUTAS PÚBLICAS Y DE BÚSQUEDA
// ----------------------------------------------------------------------

// GET /api/locales -> Devuelve todos los locales (con opción de búsqueda)
router.get('/', localController.getLocales);

// GET /api/locales/:id -> Devuelve detalles de un local
router.get('/:id', localController.getLocalDetalle);

// GET /api/locales/:id/eventos -> Devuelve los eventos de un local
router.get('/:id/eventos', localController.verEventosLocal);

// ----------------------------------------------------------------------
// RUTAS DE GESTIÓN (Crear, Modificar, Eliminar)
// ----------------------------------------------------------------------

// POST /api/locales -> Crea un nuevo local
router.post('/', authMiddleware(ownerOrAdmin), localController.crearLocal);

// PUT /api/locales/:id -> Modifica un local
router.put('/:id', authMiddleware(ownerOrAdmin), localController.modificarLocal);

// POST /api/locales/eventos -> Crea un nuevo evento
router.post('/eventos', authMiddleware(ownerOrAdmin), localController.crearEvento);

// PUT /api/locales/eventos/:id -> Modifica un evento específico
router.put('/eventos/:id', authMiddleware(ownerOrAdmin), localController.modificarEvento);

// DELETE /api/locales/eventos/:id -> Cancela un evento específico
router.post('/eventos/:id/cancel', authMiddleware(ownerOrAdmin), localController.cancelarEvento);

module.exports = router;
