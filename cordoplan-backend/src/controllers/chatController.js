
const db = require('../db');

// Lista de palabras prohibidas para el chat
const PALABRAS_PROHIBIDAS = [
    'puto', 'puta', 'mierda', 'cabron', 'cabrón', 'gilipollas', 'maricon', 'maricón', 
    'zorra', 'joder', 'coño', 'pendejo', 'pendeja', 'idiota', 'imbecil', 'imbécil',
    'follar', 'polla', 'tonto', 'tonta', 'estupido', 'estúpido', 'mamon', 'mamón'
];

// Función para comprobar si un mensaje contiene palabras prohibidas
const contienePalabrasProhibidas = (texto) => {
    if (!texto) return false;
    const textoNormalizado = texto.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    
    return PALABRAS_PROHIBIDAS.some(palabra => {
        const palabraNormalizada = palabra.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
        const regex = new RegExp(`\\b${palabraNormalizada}\\b`, 'i');
        return regex.test(textoNormalizado);
    });
};

// ----------------------------------------------------------------------
// LÓGICA DEL CHAT 
// ----------------------------------------------------------------------

exports.enviarMensaje = async (req, res) => {
    const { id_usuario_peticion: id_emisor } = req.user;
    const { id_receptor, mensaje } = req.body;

    if (!id_receptor || !mensaje) {
        return res.status(400).json({ message: 'Faltan datos (receptor o mensaje).' });
    }

    // --- NUEVO: Filtro de palabras prohibidas para el chat ---
    if (contienePalabrasProhibidas(mensaje)) {
        return res.status(400).json({ 
            message: 'No puedes enviar este mensaje porque contiene lenguaje inapropiado.' 
        });
    }
    // --------------------------------------------------------

    try {
        const query = 'INSERT INTO ChatMensajes (id_emisor, id_receptor, mensaje) VALUES (?, ?, ?)';
        await db.execute(query, [id_emisor, id_receptor, mensaje]);
        
        res.status(201).json({ message: 'Mensaje enviado con éxito.' });
    } catch (error) {
        console.error('Error al enviar mensaje:', error);
        res.status(500).json({ message: 'Error interno del servidor al enviar el mensaje.' });
    }
};

exports.getHistorialChat = async (req, res) => {
    const { id_usuario_peticion: id_usuario_actual } = req.user;
    const { id_amigo } = req.params;

    try {
        const query = `
            SELECT id_mensaje, id_emisor, id_receptor, mensaje, timestamp
            FROM ChatMensajes
            WHERE (id_emisor = ? AND id_receptor = ?) OR (id_emisor = ? AND id_receptor = ?)
            ORDER BY timestamp ASC
        `;
        const [mensajes] = await db.execute(query, [id_usuario_actual, id_amigo, id_amigo, id_usuario_actual]);
        
        res.status(200).json(mensajes);
    } catch (error) {
        console.error('Error al obtener el historial del chat:', error);
        res.status(500).json({ message: 'Error interno del servidor al recuperar los mensajes.' });
    }
};
