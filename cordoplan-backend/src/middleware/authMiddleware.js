// cordoplan-backend/src/middleware/authMiddleware.js
const admin = require('firebase-admin');
const db = require('../db');

/**
 * Middleware de Autorización basado en el token de Firebase.
 */
const authMiddleware = (requiredRoles = []) => {
    return async (req, res, next) => {
        const authHeader = req.headers.authorization;
        const token = authHeader?.split(' ')[1];

        if (!token) {
            return res.status(401).json({ message: 'Acceso denegado. Se requiere autenticación.' });
        }

        try {
            const decodedToken = await admin.auth().verifyIdToken(token);
            const firebase_uid = decodedToken.uid;

            const [users] = await db.execute(
                'SELECT id_usuario, rol FROM Usuarios WHERE firebase_uid = ?', 
                [firebase_uid]
            );

            if (users.length === 0) {
                return res.status(404).json({ message: 'Usuario autenticado no sincronizado en la base de datos.' });
            }

            const user = users[0];

            // Se añade una comprobación robusta para asegurar la integridad de los datos.
            if (!user || user.id_usuario === undefined || user.id_usuario === null) {
                console.error(`ERROR CRÍTICO: El usuario con firebase_uid=${firebase_uid} no tiene un id_usuario en la base de datos.`);
                return res.status(500).json({ message: 'Error de integridad de datos: el ID del usuario no se pudo recuperar.' });
            }

            const userRol = user.rol;

            // Adjuntar la información del usuario a la solicitud
            req.user = {
                id_usuario_peticion: user.id_usuario,
                rol: userRol
            };

            // Verificar la Autorización por rol
            if (requiredRoles.length > 0 && !requiredRoles.includes(userRol)) {
                return res.status(403).json({ 
                    message: `Permiso insuficiente. Rol requerido: ${requiredRoles.join(', ')}.`,
                    current_rol: userRol
                });
            }

            next();

        } catch (error) {
            console.error('Error de autenticación/autorización:', error.message);
            return res.status(401).json({ message: 'Token de autenticación inválido o expirado.' });
        }
    };
};

module.exports = authMiddleware;