// cordoplan-backend/src/controllers/adminController.js
const db = require('../db');

// ----------------------------------------------------------------------
// GESTIÓN DE CUENTAS 
// ----------------------------------------------------------------------

exports.getAllCuentas = async (req, res) => {
    try {
        const [users] = await db.execute('SELECT id_usuario, nombre, email, rol, firebase_uid, nfc_tag_id FROM Usuarios ORDER BY id_usuario DESC');
        res.status(200).json(users);
    } catch (error) {
        console.error('Error al obtener todas las cuentas:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

exports.modificarCuenta = async (req, res) => {
    const { id_usuario_objetivo } = req.params;
    const { nombre, email, rol } = req.body;

    // Campos que el administrador puede modificar
    const updatableFields = { nombre, email, rol };
    const fieldsToUpdate = [];
    const values = [];

    // Construir la consulta dinámicamente para evitar sobreescribir con `undefined`
    for (const [key, value] of Object.entries(updatableFields)) {
        if (value !== undefined) {
            fieldsToUpdate.push(`${key} = ?`);
            values.push(value);
        }
    }

    if (fieldsToUpdate.length === 0) {
        return res.status(400).json({ message: 'No se proporcionaron datos para modificar.' });
    }
    
    values.push(id_usuario_objetivo); // Añadir el ID del usuario al final para el WHERE

    try {
        const query = `UPDATE Usuarios SET ${fieldsToUpdate.join(', ')} WHERE id_usuario = ?`;
        const [result] = await db.execute(query, values);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Usuario no encontrado.' });
        }
        
        res.status(200).json({ message: 'Cuenta modificada con éxito.' });
    } catch (error) {
        console.error('Error al modificar cuenta:', error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: 'El correo electrónico ya está en uso.' });
        }
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


exports.eliminarCuenta = async (req, res) => {
    const { id_usuario_objetivo } = req.params;

    try {
        const [result] = await db.execute('DELETE FROM Usuarios WHERE id_usuario = ?', [id_usuario_objetivo]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Usuario no encontrado.' });
        }

        res.status(200).json({ message: 'Cuenta eliminada con éxito.' });
    } catch (error) {
        console.error('Error al eliminar cuenta:', error);
        // Error de clave foránea: el usuario es propietario de un local u otra dependencia.
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
             return res.status(409).json({ message: 'Conflicto: No se puede eliminar el usuario porque es propietario de un local o tiene otras dependencias en el sistema.' });
        }
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


// ----------------------------------------------------------------------
// GESTIÓN DE LOCALES 
// ----------------------------------------------------------------------

exports.gestionarLocalAdmin = async (req, res) => {
    const { id_local } = req.params;
    const { accion } = req.body; 

    let query, params;
    
    try {
        if (accion === 'eliminar') {
            query = 'DELETE FROM Locales WHERE id_local = ?';
            params = [id_local];
        } else if (accion === 'activar' || accion === 'desactivar') {
            const activo = accion === 'activar';
            query = 'UPDATE Locales SET activo = ? WHERE id_local = ?';
            params = [activo, id_local];
        } else {
            return res.status(400).json({ message: 'Acción no válida. Use "activar", "desactivar" o "eliminar".' });
        }

        const [result] = await db.execute(query, params);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Local no encontrado.' });
        }

        res.status(200).json({ message: `Local ${id_local} ${accion === 'eliminar' ? 'eliminado' : (accion + 'do')} con éxito.` });
    } catch (error) {
        console.error('Error al gestionar local (Admin):', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

// ----------------------------------------------------------------------
// MONITOREO 
// ----------------------------------------------------------------------

exports.monitorearAforoGlobal = async (req, res) => {
    try {
        const [monitoreo] = await db.execute(`
            SELECT 
                id_local,
                nombre, 
                aforo_actual, 
                aforo_maximo, 
                (aforo_actual / aforo_maximo) * 100 as porcentaje_aforo 
            FROM Locales 
            WHERE aforo_maximo > 0
            ORDER BY porcentaje_aforo DESC
        `);

        res.status(200).json(monitoreo);
    } catch (error) {
        console.error('Error al obtener monitoreo de aforo:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};
