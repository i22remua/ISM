// cordoplan-backend/src/controllers/userController.js
const db = require('../db'); 

// Función auxiliar para generar un ID de pulsera NFC (simulación)
const generateNfcTagId = () => {
    return 'NFC-' + Math.random().toString(36).substring(2, 8).toUpperCase();
};

// ----------------------------------------------------------------------
// AUTENTICACIÓN Y REGISTRO 
// ----------------------------------------------------------------------

// Sincroniza el usuario de Firebase con MySQL
exports.sincronizarUsuario = async (req, res) => {
    const { firebase_uid, email, nombre, isNewUser } = req.body;
    let { rol } = req.body; // Se define como let para poder modificarlo

    // Verificación básica para el proceso de sincronización
    if (!firebase_uid || !email) {
        return res.status(400).json({ message: 'Faltan datos esenciales (UID o email).' });
    }

    try {
        if (isNewUser) {
            if (!nombre) { // Ya no se comprueba el rol aquí
                return res.status(400).json({ message: 'Falta el nombre para el nuevo registro.' });
            }

            // Si no se proporciona un rol, se asigna 'Usuario' por defecto
            if (!rol) {
                rol = 'Usuario';
            }

            // Asignar un tag NFC ID simulado al nuevo usuario
            const nfc_tag_id = generateNfcTagId();

            const query = 'INSERT INTO Usuarios (nombre, email, rol, firebase_uid, nfc_tag_id) VALUES (?, ?, ?, ?, ?)';
            const [result] = await db.execute(query, [nombre, email, rol, firebase_uid, nfc_tag_id]);

            return res.status(201).json({
                message: `${rol} registrado y sincronizado.`,
                id_usuario: result.insertId,
                nfc_tag_id: nfc_tag_id,
                rol: rol
            });
        } else {
            // --- INICIO DE SESIÓN ---
            const [user] = await db.execute('SELECT id_usuario, rol, nfc_tag_id FROM Usuarios WHERE firebase_uid = ?', [firebase_uid]);
            if (user.length === 0) {
                 return res.status(404).json({ message: 'Usuario de Firebase no encontrado en MySQL. Intente registrarse.' });
            }

            return res.status(200).json({
                message: 'Inicio de sesión exitoso.',
                id_usuario: user[0].id_usuario,
                nfc_tag_id: user[0].nfc_tag_id,
                rol: user[0].rol
            });
        }
    } catch (error) {
        console.error('Error al sincronizar usuario:', error);
        if (error.code === 'ER_DUP_ENTRY') {
             return res.status(409).json({ message: 'El correo electrónico o UID ya está en uso en MySQL.' });
        }
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


// ----------------------------------------------------------------------
// NFC SOCIAL 
// ----------------------------------------------------------------------

exports.agregarAmigoNFC = async (req, res) => {
    const { id_usuario_peticion } = req.user;
    const { nfc_tag_id_objetivo } = req.body;

    if (!nfc_tag_id_objetivo) {
        return res.status(400).json({ message: 'ID de pulsera NFC objetivo requerido.' });
    }

    try {
        const [targetUser] = await db.execute('SELECT id_usuario, nombre FROM Usuarios WHERE nfc_tag_id = ?', [nfc_tag_id_objetivo]);

        if (targetUser.length === 0) {
            return res.status(404).json({ message: 'Pulsera NFC no reconocida o usuario no encontrado.' });
        }

        const id_usuario_objetivo = targetUser[0].id_usuario;

        if (id_usuario_peticion === id_usuario_objetivo) {
            return res.status(400).json({ message: 'No puedes agregarte a ti mismo como amigo.' });
        }

        const [existingFriendship] = await db.execute(
            'SELECT * FROM Amigos WHERE (id_usuario1 = ? AND id_usuario2 = ?) OR (id_usuario1 = ? AND id_usuario2 = ?)',
            [id_usuario_peticion, id_usuario_objetivo, id_usuario_objetivo, id_usuario_peticion]
        );

        if (existingFriendship.length > 0) {
            return res.status(200).json({ message: `${targetUser[0].nombre} ya es tu amigo.` });
        }

        const query = 'INSERT INTO Amigos (id_usuario1, id_usuario2) VALUES (?, ?)';
        await db.execute(query, [id_usuario_peticion, id_usuario_objetivo]);

        res.status(201).json({ message: `¡${targetUser[0].nombre} agregado como amigo con éxito!` });

    } catch (error) {
        console.error('Error al agregar amigo por NFC:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};


// Obtener la lista de amigos del usuario
exports.getListaAmigos = async (req, res) => {
    const { id_usuario } = req.params;
    
    try {
        const query = `
            SELECT u.id_usuario, u.nombre, u.email
            FROM Amigos a
            JOIN Usuarios u ON 
                (a.id_usuario1 = ? AND a.id_usuario2 = u.id_usuario) OR 
                (a.id_usuario2 = ? AND a.id_usuario1 = u.id_usuario)
        `;
        const [amigos] = await db.execute(query, [id_usuario, id_usuario]);
        
        res.status(200).json(amigos);
    } catch (error) {
        console.error('Error al obtener lista de amigos:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};