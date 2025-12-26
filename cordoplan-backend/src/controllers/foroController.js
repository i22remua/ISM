// cordoplan-backend/src/controllers/foroController.js
const db = require('../db');

// Obtener todos los mensajes del foro de un local
exports.getMessages = async (req, res) => {
    // FIX: El parámetro de la ruta es 'localId' según se definió en el frontend.
    const { localId } = req.params;

    try {
        const query = `
            SELECT
                fm.id_mensaje,
                fm.id_local,
                fm.id_usuario,
                u.nombre as nombre_usuario,
                fm.mensaje,
                fm.fecha_creacion
            FROM Foro_Mensajes fm
            JOIN Usuarios u ON fm.id_usuario = u.id_usuario
            WHERE fm.id_local = ?
            ORDER BY fm.fecha_creacion ASC
        `;
        const [mensajes] = await db.execute(query, [localId]);
        res.status(200).json(mensajes);
    } catch (error) {
        console.error('Error al obtener los mensajes del foro:', error);
        res.status(500).json({
            message: 'Error interno del servidor al recuperar los mensajes.',
            error: error.message
        });
    }
};

// Publicar un nuevo mensaje en el foro de un local
exports.postMessage = async (req, res) => {
    const { localId } = req.params;
    const { mensaje } = req.body;
    // FIX: 'id_usuario_peticion' viene directamente de la propiedad del middleware de autenticación.
    const { id_usuario_peticion } = req.user;

    // Logs para depuración
    console.log(`>> Publicando en foro del local ${localId}`);
    console.log(`   - Usuario ID: ${id_usuario_peticion}`);
    console.log(`   - Mensaje: ${mensaje}`);

    if (!mensaje || mensaje.trim() === '') {
        return res.status(400).json({ message: 'El contenido del mensaje no puede estar vacío.' });
    }
    if (!id_usuario_peticion) {
        return res.status(401).json({ message: 'Error de autenticación: No se encontró el ID de usuario en el token.' });
    }

    try {
        const query = 'INSERT INTO Foro_Mensajes (id_local, id_usuario, mensaje) VALUES (?, ?, ?)';
        await db.execute(query, [localId, id_usuario_peticion, mensaje]);

        res.status(201).json({ message: 'Mensaje publicado en el foro con éxito.' });
    } catch (error) {
        console.error('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        console.error('!!! ERROR DETALLADO AL INSERTAR EL MENSAJE !!!');
        console.error(error);
        console.error('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        res.status(500).json({
            message: 'Error interno del servidor al publicar el mensaje.',
            error: error.message
        });
    }
};