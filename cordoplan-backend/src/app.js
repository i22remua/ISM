// cordoplan-backend/src/app.js

const express = require('express');
const dotenv = require('dotenv');
const firebaseAdmin = require('firebase-admin');
const dbPool = require('./db'); // Importar el pool de DB [cite: 150]
const cors = require('cors'); // Recomendado para evitar bloqueos de red

// 1. CARGA DE CONFIGURACIÓN Y SERVICIOS
// =====================================

dotenv.config(); // Carga DB_HOST, DB_USER, etc. [cite: 144, 145]

// Importación de Rutas [cite: 162]
const userRoutes = require('./routes/userRoutes');   // [cite: 165, 168]
const ownerRoutes = require('./routes/ownerRoutes');
const adminRoutes = require('./routes/adminRoutes'); // [cite: 163, 166]
const localRoutes = require('./routes/localRoutes'); // [cite: 164, 167]
const foroRoutes = require('./routes/foroRoutes');

// Inicialización de Express [cite: 148, 149]
const app = express();
const PORT = process.env.PORT || 3000;

// 2. CONFIGURACIÓN DE FIREBASE ADMIN (RNF-06: Seguridad [cite: 41, 42])
// ====================================================================

try {
    const serviceAccount = require('../cordoplan-uco-service-account.json');
    firebaseAdmin.initializeApp({
        credential: firebaseAdmin.credential.cert(serviceAccount)
    });
    console.log('✅ Firebase Admin SDK inicializado.');
} catch (error) {
    console.error('❌ Error al inicializar Firebase Admin SDK:', error.message);
    process.exit(1);
}

// 3. MIDDLEWARE Y MONTAJE DE RUTAS
// ====================================================================

app.use(cors()); // Permite peticiones desde dispositivos externos en la red local
app.use(express.json()); // Middleware para parsear JSON [cite: 147]

// Rutas específicas para roles y funcionalidades [cite: 4, 154]
app.use('/api/users', userRoutes);
app.use('/api/owner', ownerRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/foro', foroRoutes);

// Rutas generales de locales [cite: 167]
app.use('/api/locales', localRoutes);

app.get('/', (req, res) => {
    res.send('Servidor CordoPlan API REST en funcionamiento.');
});

// 4. FUNCIÓN PARA INICIAR EL SERVIDOR Y CONECTAR A LA DB
// ====================================================================

const startServer = () => {
    // CAMBIO CLAVE: Escuchar en '0.0.0.0' para ser visible por el Samsung A25
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 Servidor CordoPlan Node.js corriendo en el puerto ${PORT}`);
        console.log(`📡 Accesible en red local (asegúrate de usar tu IP en Flutter)`);
    });
};

const connectWithRetry = async (retries = 5, delay = 5000) => {
    while (retries > 0) {
        try {
            const connection = await dbPool.getConnection(); // [cite: 150]
            console.log('✅ Conexión exitosa al Pool de MySQL.');
            connection.release();
            return;
        } catch (err) {
            console.error(`❌ Error al conectar al Pool de MySQL: ${err.message}. Reintentando en ${delay / 1000}s...`);
            retries--;
            if (retries === 0) {
                console.error('❌ No se pudo conectar a la DB. Saliendo...');
                process.exit(1);
            }
            await new Promise(res => setTimeout(res, delay));
        }
    }
};

// 5. INICIO DE LA APLICACIÓN [cite: 148]
// ====================================================================

connectWithRetry().then(() => {
    startServer();
});

module.exports = app;