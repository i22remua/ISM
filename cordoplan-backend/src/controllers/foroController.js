const db = require('../db');

const PALABRAS_PROHIBIDAS = [
    'puto', 'puta', 'mierda', 'cabron', 'gilipollas', 'maricon', 
    'zorra', 'joder', 'cono', 'pendejo', 'idiota', 'imbecil',
    'follar', 'polla', 'tonto', 'estupido', 'mamon'
].map(p => p.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""));

// Función mejorada para comprobar palabras prohibidas
const contienePalabrasProhibidas = (texto) => {
    if (!texto) return false;
    
    // 1. Normalizamos el texto: minúsculas y sin acentos
    const textoNormalizado = texto.toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "");
    
    // 2. Quitamos signos de puntuación para que "puta!!!" se convierta en "puta"
    const textoLimpio = textoNormalizado.replace(/[^\w\s]/gi, ' ');

    // 3. Dividimos en palabras y comprobamos
    const palabrasEnMensaje = textoLimpio.split(/\s+/);
    
    return palabrasEnMensaje.some(palabra => PALABRAS_PROHIBIDAS.includes(palabra));
};

// Obtener todos los mensajes del foro de un local
exports.getMessages = async (req, res) => {
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
        res.status(500).json({ message: 'Error al recuperar mensajes.' });
    }
};

// Publicar un nuevo mensaje con filtro mejorado
exports.postMessage = async (req, res) => {
    const { localId } = req.params;
    const { mensaje } = req.body;
    const { id_usuario_peticion } = req.user;

    if (!mensaje || mensaje.trim() === '') {
        return res.status(400).json({ message: 'El mensaje no puede estar vacío.' });
    }

    // Aplicar el filtro robusto
    if (contienePalabrasProhibidas(mensaje)) {
        return res.status(400).json({ 
            message: 'Tu mensaje ha sido bloqueado por contener lenguaje inapropiado.' 
        });
    }

    try {
        const query = 'INSERT INTO Foro_Mensajes (id_local, id_usuario, mensaje) VALUES (?, ?, ?)';
        await db.execute(query, [localId, id_usuario_peticion, mensaje.trim()]);
        res.status(201).json({ message: 'Mensaje publicado con éxito.' });
    } catch (error) {
        console.error('Error al insertar mensaje:', error);
        res.status(500).json({ message: 'Error al publicar el mensaje.' });
    }
};
