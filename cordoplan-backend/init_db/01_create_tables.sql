-- cordoplan-backend/init_db/01_create_tables.sql

-- 1. LIMPIEZA (Solo para desarrollo)

DROP TABLE IF EXISTS Foro_Mensajes;
DROP TABLE IF EXISTS Amigos;
DROP TABLE IF EXISTS Eventos;
DROP TABLE IF EXISTS Locales;
DROP TABLE IF EXISTS Usuarios;


-- 2. CREACIÓN DE TABLAS


-- Tabla para los usuarios de la aplicación
CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255), 
    firebase_uid VARCHAR(128) UNIQUE NOT NULL, 
    rol ENUM('Usuario', 'Propietario', 'Administrador') NOT NULL,
    nfc_tag_id VARCHAR(50) UNIQUE, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para almacenar los locales de ocio
CREATE TABLE Locales (
    id_local INT PRIMARY KEY AUTO_INCREMENT,
    id_propietario INT NOT NULL, 
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(255),
    latitud DECIMAL(10, 8) NOT NULL,
    longitud DECIMAL(11, 8) NOT NULL,
    aforo_maximo INT NOT NULL, 
    aforo_actual INT DEFAULT 0, 
    tipo_ocio VARCHAR(50), 
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_propietario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);

-- Tabla para almacenar eventos
CREATE TABLE Eventos (
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    id_local INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_hora DATETIME NOT NULL,
    creado_por INT, 
    FOREIGN KEY (id_local) REFERENCES Locales(id_local) ON DELETE CASCADE,
    FOREIGN KEY (creado_por) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

-- Tabla para la relación de amistad
CREATE TABLE Amigos (
    id_amistad INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario1 INT NOT NULL,
    id_usuario2 INT NOT NULL,
    FOREIGN KEY (id_usuario1) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario2) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    UNIQUE (id_usuario1, id_usuario2)
);

-- Tabla para los mensajes del foro de un local
CREATE TABLE Foro_Mensajes (
    id_mensaje INT PRIMARY KEY AUTO_INCREMENT,
    id_local INT NOT NULL,
    id_usuario INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_local) REFERENCES Locales(id_local) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);


-- 3. DATOS DE PRUEBA INICIALES

INSERT INTO Usuarios (nombre, email, rol, firebase_uid, nfc_tag_id) VALUES
('Admin CordoPlan', 'admin@cordoplan.com', 'Administrador', 'NXct4OpZH3SugmzPusZUE4xTg8G3', 'NFC-A001'),
('Propietario Bar', 'owner@local.com', 'Propietario', 'FIREBASE_UID_OWNER_456', 'NFC-P001');

-- CORRECCIÓN: Se añade 'activo' explícitamente para asegurar que el local de prueba siempre se cree como activo.
INSERT INTO Locales (id_propietario, nombre, descripcion, ubicacion, latitud, longitud, aforo_maximo, aforo_actual, tipo_ocio, activo) VALUES
(
    (SELECT id_usuario FROM Usuarios WHERE email='owner@local.com'),
    'Disco Muestra',
    'La mejor discoteca de ocio en la zona de ejemplo.',
    'Calle del Ejemplo, 1, 14001 Córdoba',
    37.8845,
    -4.7797,
    150,
    50,
    'Discoteca',
    TRUE -- Se establece explícitamente como activo
);

INSERT INTO Eventos (id_local, nombre, descripcion, fecha_hora, creado_por) VALUES
(
    (SELECT id_local FROM Locales WHERE nombre='Disco Muestra'),
    'Noche de Electronica',
    'Gran evento con DJs invitados.',
    DATE_ADD(NOW(), INTERVAL 7 DAY),
    (SELECT id_usuario FROM Usuarios WHERE email='owner@local.com')
);
