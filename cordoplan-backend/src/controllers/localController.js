// cordoplan-backend/src/controllers/localController.js
const db = require('../db');

// ----------------------------------------------------------------------
// EXPLORACIÓN DE LOCALES
// ----------------------------------------------------------------------

exports.getLocales = async (req, res) => {
    const { query: searchQuery } = req.query;
    try {
        let sql = `
            SELECT
                id_local AS idLocal,
                nombre,
                descripcion,
                ubicacion,
                latitud,
                longitud,
                tipo_ocio AS tipoOcio,
                aforo_actual AS aforoActual,
                aforo_maximo AS aforoMaximo,
                activo
            FROM Locales
            WHERE activo = TRUE
        `;
        const params = [];

        if (searchQuery) {
            sql += ' AND nombre LIKE ?';
            params.push(`%${searchQuery}%`);
        }

        const [locales] = await db.execute(sql, params);
        res.status(200).json(locales);

    } catch (error) {
        console.error('Error al obtener locales:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

exports.getLocalDetalle = async (req, res) => {
    const { id } = req.params;
    try {
        const [local] = await db.execute(`
            SELECT
                id_local AS idLocal,
                id_propietario AS idPropietario,
                nombre,
                descripcion,
                ubicacion,
                latitud,
                longitud,
                aforo_maximo AS aforoMaximo,
                aforo_actual AS aforoActual,
                tipo_ocio AS tipoOcio,
                activo
            FROM Locales
            WHERE id_local = ? AND activo = TRUE`, [id]);
        if (local.length === 0) {
            return res.status(404).json({ message: 'Local no encontrado.' });
        }
        res.status(200).json(local[0]);
    } catch (error) {
        console.error('Error al obtener detalle del local:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


// ----------------------------------------------------------------------
// GESTIÓN DE LOCALES (PROPIETARIO/ADMIN)
// ----------------------------------------------------------------------

exports.getMyLocal = async (req, res) => {
    const { id_usuario_peticion } = req.user;

    try {
        const [locales] = await db.execute(`
            SELECT
                id_local AS idLocal,
                id_propietario AS idPropietario,
                nombre,
                descripcion,
                ubicacion,
                latitud,
                longitud,
                aforo_maximo AS aforoMaximo,
                aforo_actual AS aforoActual,
                tipo_ocio AS tipoOcio,
                activo
            FROM Locales
            WHERE id_propietario = ?`, [id_usuario_peticion]);

        if (locales.length === 0) {
            return res.status(404).json({ message: `No se encontró ningún local para el propietario con ID: ${id_usuario_peticion}` });
        }

        res.status(200).json(locales[0]);

    } catch (error) {
        console.error('Error al obtener el local del propietario:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

exports.crearLocal = async (req, res) => {
    const { id_usuario_peticion } = req.user;
    const { nombre, latitud, longitud, aforo_maximo, descripcion, ubicacion, tipo_ocio, aforo_actual } = req.body;

    if (id_usuario_peticion === undefined) {
        return res.status(500).json({ message: 'Error de autenticación: El ID de usuario no está disponible.' });
    }
    if (!nombre || latitud === undefined || longitud === undefined || !aforo_maximo) {
        return res.status(400).json({ message: 'Faltan campos obligatorios: nombre, latitud, longitud, aforo_maximo.' });
    }
    try {
        const query = 'INSERT INTO Locales (id_propietario, nombre, descripcion, ubicacion, latitud, longitud, aforo_maximo, aforo_actual, tipo_ocio) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
        const params = [ id_usuario_peticion, nombre, descripcion || null, ubicacion || null, latitud, longitud, aforo_maximo, aforo_actual || 0, tipo_ocio || null ];
        const [result] = await db.execute(query, params);
        res.status(201).json({ id_local: result.insertId, message: 'Local creado con éxito.' });
    } catch (error) {
        console.error('Error al crear local:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

exports.modificarLocal = async (req, res) => {
    const { id } = req.params;
    const { id_usuario_peticion, rol } = req.user;
    const nuevosDatos = req.body;

    try {
        // 1. Obtener el local actual para verificar permisos y tener los datos antiguos
        const [localCheck] = await db.execute('SELECT * FROM Locales WHERE id_local = ?', [id]);

        if (localCheck.length === 0) {
            return res.status(404).json({ message: 'Local no encontrado.' });
        }

        const localActual = localCheck[0];

        // 2. Comprobar permisos (solo admin o el propietario pueden modificar)
        if (rol !== 'Administrador' && localActual.id_propietario !== id_usuario_peticion) {
            return res.status(403).json({ message: 'No tienes permiso para modificar este local.' });
        }

        // 3. Fusionar datos: se mantienen los datos antiguos si no vienen nuevos
        const datosAActualizar = {
            nombre: nuevosDatos.nombre || localActual.nombre,
            descripcion: nuevosDatos.descripcion || localActual.descripcion,
            ubicacion: nuevosDatos.ubicacion || localActual.ubicacion,
            latitud: nuevosDatos.latitud || localActual.latitud,
            longitud: nuevosDatos.longitud || localActual.longitud,
            aforo_maximo: nuevosDatos.aforo_maximo || localActual.aforo_maximo,
            aforo_actual: nuevosDatos.aforo_actual !== undefined ? nuevosDatos.aforo_actual : localActual.aforo_actual,
            tipo_ocio: nuevosDatos.tipo_ocio || localActual.tipo_ocio,
        };

        // 4. Construir y ejecutar la consulta UPDATE
        const query = `
            UPDATE Locales SET 
                nombre = ?, 
                descripcion = ?, 
                ubicacion = ?, 
                latitud = ?, 
                longitud = ?, 
                aforo_maximo = ?, 
                aforo_actual = ?, 
                tipo_ocio = ? 
            WHERE id_local = ?
        `;
        
        const params = [
            datosAActualizar.nombre,
            datosAActualizar.descripcion,
            datosAActualizar.ubicacion,
            datosAActualizar.latitud,
            datosAActualizar.longitud,
            datosAActualizar.aforo_maximo,
            datosAActualizar.aforo_actual,
            datosAActualizar.tipo_ocio,
            id
        ];

        await db.execute(query, params);
        res.status(200).json({ message: 'Local modificado con éxito.' });

    } catch (error) {
        console.error('Error al modificar local:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


// ----------------------------------------------------------------------
// GESTIÓN DE EVENTOS
// ----------------------------------------------------------------------

exports.crearEvento = async (req, res) => {
    const { id_usuario_peticion } = req.user;
    const { id_local, nombre, descripcion, fecha_hora } = req.body;
    if (!id_local || !nombre || !fecha_hora) {
        return res.status(400).json({ message: 'Faltan campos obligatorios (id_local, nombre, fecha_hora).' });
    }
    try {
        const [localCheck] = await db.execute('SELECT id_propietario FROM Locales WHERE id_local = ?', [id_local]);
        if (localCheck.length === 0 || (localCheck[0].id_propietario !== id_usuario_peticion && req.user.rol !== 'Administrador')) {
            return res.status(403).json({ message: 'No tienes permiso para crear eventos en este local.' });
        }
        const query = 'INSERT INTO Eventos (id_local, nombre, descripcion, fecha_hora, creado_por) VALUES (?, ?, ?, ?, ?)';
        const [result] = await db.execute(query, [id_local, nombre, descripcion || null, fecha_hora, id_usuario_peticion]);
        res.status(201).json({ idEvento: result.insertId, message: 'Evento creado con éxito.' });
    } catch (error) {
        console.error('Error al crear evento:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};
exports.modificarEvento = async (req, res) => {
    const { id } = req.params;
    const { nombre, descripcion, fecha_hora } = req.body;
    const { id_usuario_peticion, rol } = req.user;
    if (!nombre || !descripcion || !fecha_hora) {
        return res.status(400).json({ message: 'Faltan campos obligatorios (nombre, descripcion, fecha_hora).' });
    }
    try {
        const [eventCheck] = await db.execute('SELECT l.id_propietario FROM Eventos e JOIN Locales l ON e.id_local = l.id_local WHERE e.id_evento = ?', [id]);
        if (eventCheck.length === 0) {
            return res.status(404).json({ message: 'Evento no encontrado.' });
        }
        if (rol !== 'Administrador' && eventCheck[0].id_propietario !== id_usuario_peticion) {
            return res.status(403).json({ message: 'No tienes permiso para modificar este evento.' });
        }
        const query = 'UPDATE Eventos SET nombre = ?, descripcion = ?, fecha_hora = ? WHERE id_evento = ?';
        await db.execute(query, [nombre, descripcion, fecha_hora, id]);
        res.status(200).json({ message: 'Evento modificado con éxito.' });
    } catch (error) {
        console.error('Error al modificar evento:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};
exports.cancelarEvento = async (req, res) => {
    const { id } = req.params;
    const { id_usuario_peticion, rol } = req.user;
    let connection;

    try {
        // 1. Obtener una conexión del pool para manejar la transacción
        connection = await db.getConnection();
        await connection.beginTransaction(); // Iniciar transacción

        // 2. Verificar que el evento existe y que el usuario tiene permisos
        const [eventCheck] = await connection.execute('SELECT l.id_propietario FROM Eventos e JOIN Locales l ON e.id_local = l.id_local WHERE e.id_evento = ?', [id]);
        
        if (eventCheck.length === 0) {
            await connection.rollback(); // Revertir si el evento no existe
            connection.release();
            return res.status(404).json({ message: 'Evento no encontrado.' });
        }
        
        if (rol !== 'Administrador' && eventCheck[0].id_propietario !== id_usuario_peticion) {
            await connection.rollback(); // Revertir si no hay permisos
            connection.release();
            return res.status(403).json({ message: 'No tienes permiso para cancelar este evento.' });
        }

        // 3. Ejecutar el borrado
        await connection.execute('DELETE FROM Eventos WHERE id_evento = ?', [id]);
        
        // 4. Confirmar la transacción para hacer el borrado permanente
        await connection.commit();
        
        res.status(200).json({ message: 'Evento cancelado con éxito.' });

    } catch (error) {
        // Si hay cualquier error, revertir la transacción
        if (connection) {
            await connection.rollback();
        }
        console.error('Error al cancelar evento:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    } finally {
        // 5. Asegurarse de liberar la conexión en cualquier caso
        if (connection) {
            connection.release();
        }
    }
};

exports.verEventosLocal = async (req, res) => {
    const { id } = req.params;
    const { id_usuario_peticion, rol } = req.user || {};

    try {
        const [localCheck] = await db.execute('SELECT id_propietario, activo FROM Locales WHERE id_local = ?', [id]);

        if (localCheck.length === 0) {
            return res.status(404).json({ message: 'Local no encontrado.' });
        }

        const local = localCheck[0];
        const esPropietario = local.id_propietario === id_usuario_peticion;
        const esAdmin = rol === 'Administrador';

        if (!local.activo && !esPropietario && !esAdmin) {
            return res.status(404).json({ message: 'Local no encontrado o no está activo.' });
        }

        const query = `SELECT id_evento AS idEvento, id_local AS idLocal, nombre, descripcion, fecha_hora AS fechaHora, creado_por AS creadoPor FROM Eventos WHERE id_local = ? ORDER BY fecha_hora ASC`;
        const [eventos] = await db.execute(query, [id]);
        res.status(200).json(eventos);
    } catch (error) {
        console.error('Error al ver los eventos del local:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

// ----------------------------------------------------------------------
// CONTROL DE AFORO (NFC)
// ----------------------------------------------------------------------

// Función genérica para gestionar el aforo (entrada/salida)
const gestionarAforo = async (idLocal, idUsuario, tipo) => {
    let connection;
    try {
        connection = await db.getConnection();
        await connection.beginTransaction();

        // 1. Obtener el local y bloquear la fila para evitar concurrencia
        const [localCheck] = await connection.execute('SELECT * FROM Locales WHERE id_local = ? FOR UPDATE', [idLocal]);

        if (localCheck.length === 0) {
            throw { status: 404, message: 'Local no encontrado.' };
        }

        const local = localCheck[0];

        let nuevoAforo = local.aforo_actual;

        if (tipo === 'entrada') {
            if (nuevoAforo >= local.aforo_maximo) {
                throw { status: 409, message: 'El aforo ya está al máximo. No se puede registrar la entrada.' };
            }
            nuevoAforo++;
        } else { // tipo === 'salida'
            if (nuevoAforo <= 0) {
                throw { status: 409, message: 'El aforo ya es cero. No se puede registrar la salida.' };
            }
            nuevoAforo--;
        }

        // 3. Actualizar el aforo en la base de datos
        await connection.execute('UPDATE Locales SET aforo_actual = ? WHERE id_local = ?', [nuevoAforo, idLocal]);

        await connection.commit();

        return {
            message: `Aforo actualizado con éxito. Nuevo aforo: ${nuevoAforo}`,
            aforoActual: nuevoAforo,
            aforoMaximo: local.aforo_maximo,
            nombreLocal: local.nombre
        };

    } catch (error) {
        if (connection) await connection.rollback();
        throw error; // Re-lanzar para que el controlador principal lo capture
    } finally {
        if (connection) connection.release();
    }
};

exports.registrarEntradaNfc = async (req, res) => {
    try {
        const { id } = req.params;
        const { id_usuario_peticion } = req.user;
        const resultado = await gestionarAforo(id, id_usuario_peticion, 'entrada');
        res.status(200).json(resultado);
    } catch (error) {
        console.error('Error al registrar entrada por NFC:', error);
        res.status(error.status || 500).json({ message: error.message || 'Error interno del servidor.' });
    }
};

exports.registrarSalidaNfc = async (req, res) => {
    try {
        const { id } = req.params;
        const { id_usuario_peticion } = req.user;
        const resultado = await gestionarAforo(id, id_usuario_peticion, 'salida');
        res.status(200).json(resultado);
    } catch (error) {
        console.error('Error al registrar salida por NFC:', error);
        res.status(error.status || 500).json({ message: error.message || 'Error interno del servidor.' });
    }
};
