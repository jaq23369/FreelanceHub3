-- =======================================================
-- CREACIÓN DE LA BASE DE DATOS PARA FREELANCEHUB
-- =======================================================

-- =======================================================
-- TABLA PRINCIPAL: USUARIOS
-- =======================================================
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(15) CHECK (tipo_usuario IN ('freelancer', 'emprendedor')) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    telefono VARCHAR(20) UNIQUE
);

-- Índice para búsqueda rápida por email
CREATE INDEX idx_usuario_email ON Usuario(email);

-- =======================================================
-- TABLAS PARA EMPRENDEDORES
-- =======================================================
CREATE TABLE Emprendedor_Maestro (
    id_emprendedor SERIAL PRIMARY KEY,
    id_usuario INT UNIQUE NOT NULL,
    estado VARCHAR(15) CHECK (estado IN ('activo', 'inactivo', 'suspendido')) DEFAULT 'activo',
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Emprendedor_Detalle (
    id_emprendedor_detalle SERIAL PRIMARY KEY,
    id_emprendedor INT UNIQUE NOT NULL,
    presupuesto DECIMAL(10,2) CHECK (presupuesto >= 0),
    historial_contratos TEXT,
    preferencias TEXT,
    descripcion TEXT,
    FOREIGN KEY (id_emprendedor) REFERENCES Emprendedor_Maestro(id_emprendedor)
);

-- Índices en emprendedores
CREATE INDEX idx_emprendedor_estado ON Emprendedor_Maestro(estado);
CREATE INDEX idx_emprendedor_presupuesto ON Emprendedor_Detalle(presupuesto);

-- =======================================================
-- TABLAS PARA FREELANCERS
-- =======================================================
CREATE TABLE Freelancer_Maestro (
    id_freelancer SERIAL PRIMARY KEY,
    id_usuario INT UNIQUE NOT NULL,
    estado VARCHAR(15) CHECK (estado IN ('activo', 'inactivo', 'suspendido')) DEFAULT 'activo',
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Freelancer_Detalle (
    id_freelancer_detalle SERIAL PRIMARY KEY,
    id_freelancer INT UNIQUE NOT NULL,
    habilidades TEXT,
    reputacion DECIMAL(2,1) CHECK (reputacion BETWEEN 0 AND 5),
    certificaciones TEXT,
    experiencia VARCHAR(255),
    descripcion TEXT,
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer)
);

-- Índices en freelancers
CREATE INDEX idx_freelancer_estado ON Freelancer_Maestro(estado);
CREATE INDEX idx_freelancer_reputacion ON Freelancer_Detalle(reputacion);

-- =======================================================
-- TABLAS PARA PROYECTOS
-- =======================================================
CREATE TABLE Proyecto_Maestro (
    id_proyecto SERIAL PRIMARY KEY,
    id_emprendedor INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    presupuesto DECIMAL(10,2) CHECK (presupuesto >= 0),
    estado VARCHAR(15) CHECK (estado IN ('abierto', 'en progreso', 'finalizado')) DEFAULT 'abierto',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_emprendedor) REFERENCES Emprendedor_Maestro(id_emprendedor)
);

CREATE TABLE Proyecto_Detalle (
    id_proyecto_detalle SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    id_freelancer INT NOT NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_participacion VARCHAR(15) CHECK (estado_participacion IN ('en progreso', 'finalizado')) DEFAULT 'en progreso',
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto),
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer)
);

-- Índices en proyectos
CREATE INDEX idx_proyecto_estado ON Proyecto_Maestro(estado);
CREATE INDEX idx_proyecto_presupuesto ON Proyecto_Maestro(presupuesto);

-- =======================================================
-- TABLA CONTRATO (Con estado)
-- =======================================================
CREATE TABLE Contrato (
    id_contrato SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    id_emprendedor INT NOT NULL,
    estado VARCHAR(15) CHECK (estado IN ('pendiente', 'activo', 'finalizado', 'cancelado')) DEFAULT 'pendiente',
    terminos TEXT NOT NULL,
    firma_emprendedor BOOLEAN DEFAULT FALSE,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_finalizacion TIMESTAMP,
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto),
    FOREIGN KEY (id_emprendedor) REFERENCES Emprendedor_Maestro(id_emprendedor)
);

-- Índice para búsqueda rápida de contratos
CREATE INDEX idx_contrato_estado ON Contrato(estado);

-- =======================================================
-- TABLA DE PAGOS
-- =======================================================
CREATE TABLE Pago_Maestro (
    id_pago SERIAL PRIMARY KEY,
    id_contrato INT NOT NULL,
    monto DECIMAL(10,2),
    estado VARCHAR(15) CHECK (estado IN ('pendiente', 'completado')) DEFAULT 'pendiente',
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(15) CHECK (metodo IN ('tarjeta', 'paypal', 'transferencia')) NOT NULL,
    FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato)
);

CREATE TABLE Pago_Detalle (
    id_pago_detalle SERIAL PRIMARY KEY,
    id_pago INT NOT NULL,
    id_freelancer INT NOT NULL,
    monto DECIMAL(10,2),
    FOREIGN KEY (id_pago) REFERENCES Pago_Maestro(id_pago),
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer)
);

-- Índices en pagos
CREATE INDEX idx_pago_estado ON Pago_Maestro(estado);
CREATE INDEX idx_pago_metodo ON Pago_Maestro(metodo);

-- =======================================================
-- TABLAS DE CHAT Y MENSAJES ENTRE USUARIOS
-- =======================================================
CREATE TABLE Chat (
    id_chat SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto)
);

CREATE TABLE Mensaje (
    id_mensaje SERIAL PRIMARY KEY,
    id_chat INT NOT NULL,
    id_usuario INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_chat) REFERENCES Chat(id_chat),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Índices en chat y mensajes
CREATE INDEX idx_chat_fecha ON Chat(fecha_creacion);
CREATE INDEX idx_mensaje_usuario ON Mensaje(id_usuario);

-- =======================================================
-- TABLA DE NOTIFICACIONES
-- =======================================================
CREATE TABLE Notificacion (
    id_notificacion SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('mensaje', 'pago', 'proyecto', 'contrato')),
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) CHECK (estado IN ('pendiente', 'leído')),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Índices en notificaciones
CREATE INDEX idx_notificacion_usuario ON Notificacion(id_usuario);
CREATE INDEX idx_notificacion_estado ON Notificacion(estado);
