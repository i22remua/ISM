// cordoplan-backend/src/db.js
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'mysql_db', 
    user: process.env.DB_USER || 'cordoplan_user',
    password: process.env.DB_PASSWORD || '12345678',
    database: process.env.DB_NAME || 'cordoplan_db',
    
    // --- CORRECCIÓN DE ZONA HORARIA ---
    // Se establece explícitamente la zona horaria a la de España.
    // Esto asegura que todas las fechas (DATETIME) se insertan y leen
    // en la hora local correcta, evitando problemas con UTC.
    timezone: '+02:00', // O 'Europe/Madrid' si el servidor MySQL lo soporta

    waitForConnections: true, 
    connectionLimit: 15, // Aumentado ligeramente para reintentos
    queueLimit: 0,
    connectTimeout: 20000 // Aumentado para dar más margen
});

module.exports = pool;