// cordoplan-backend/src/app.js

const express = require('express');
const dotenv = require('dotenv');
const firebaseAdmin = require('firebase-admin');
const dbPool = require('./db'); // Importar el pool de DB

// 1. CARGA DE CONFIGURACIÓN Y SERVICIOS
// =====================================

dotenv.config();

// Importación de Rutas
const userRoutes = require('./routes/userRoutes');   
const ownerRoutes = require('./routes/ownerRoutes');
const adminRoutes = require('./routes/adminRoutes'); 
const localRoutes = require('./routes/localRoutes'); 
const foroRoutes = require('./routes/foroRoutes'); // Importación de las rutas del foro

// Inicialización de Express
const app = express();
const PORT = process.env.PORT || 3000;

// 2. CONFIGURACIÓN DE FIREBASE ADMIN (RNF-06: Seguridad)
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

app.use(express.json()); 

// Rutas específicas para roles y funcionalidades
app.use('/api/users', userRoutes);     
app.use('/api/owner', ownerRoutes);
app.use('/api/admin', adminRoutes);   
app.use('/api/foro', foroRoutes);     // Registro de las rutas del foro de locales

// Rutas más generales de locales (públicas)
app.use('/api/locales', localRoutes);

app.get('/', (req, res) => {
    res.send('Servidor CordoPlan API REST en funcionamiento.');
});

// 4. FUNCIÓN PARA INICIAR EL SERVIDOR Y CONECTAR A LA DB
// ====================================================================

const startServer = () => {
    app.listen(PORT, () => {
        console.log(`🚀 Servidor CordoPlan Node.js corriendo en el puerto ${PORT}`);
    });
};

const connectWithRetry = async (retries = 5, delay = 5000) => {
    while (retries > 0) {
        try {
            const connection = await dbPool.getConnection();
            console.log('✅ Conexión exitosa al Pool de MySQL.');
            connection.release();
            return; // Conexión exitosa, salir de la función
        } catch (err) {
            console.error(`❌ Error al conectar al Pool de MySQL: ${err.message}. Reintentando en ${delay / 1000}s... (${retries - 1} reintentos restantes)`);
            retries--;
            if (retries === 0) {
                console.error('❌ No se pudo conectar a la base de datos después de varios reintentos. Saliendo...');
                process.exit(1);
            }
            await new Promise(res => setTimeout(res, delay));
        }
    }
};

// 5. INICIO DE LA APLICACIÓN
// ====================================================================

// Primero, intentar conectar a la base de datos. Si tiene éxito, iniciar el servidor.
connectWithRetry().then(() => {
    startServer();
});

// Exportar 'app' para pruebas (opcional)
module.exports = app;