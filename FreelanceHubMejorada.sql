-- =======================================================
-- CREACIÓN DE LA BASE DE DATOS PARA FREELANCEHUB (MEJORADA)
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
    reputacion DECIMAL(2,1) CHECK (reputacion BETWEEN 0 AND 5),
    experiencia VARCHAR(255),
    descripcion TEXT,
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer)
);

-- Normalización de habilidades y certificaciones
CREATE TABLE Habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Freelancer_Habilidad (
    id_freelancer INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(20) CHECK (nivel IN ('básico', 'intermedio', 'avanzado', 'experto')),
    PRIMARY KEY (id_freelancer, id_habilidad),
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer),
    FOREIGN KEY (id_habilidad) REFERENCES Habilidad(id_habilidad)
);

CREATE TABLE Certificacion (
    id_certificacion SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    entidad_emisora VARCHAR(100) NOT NULL,
    fecha_emision DATE
);

CREATE TABLE Freelancer_Certificacion (
    id_freelancer INT NOT NULL,
    id_certificacion INT NOT NULL,
    fecha_obtencion DATE NOT NULL,
    PRIMARY KEY (id_freelancer, id_certificacion),
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer),
    FOREIGN KEY (id_certificacion) REFERENCES Certificacion(id_certificacion)
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

CREATE TABLE Requisito_Proyecto (
    id_requisito SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto)
);

CREATE TABLE Proyecto_Detalle (
    id_proyecto_detalle SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    id_freelancer INT NOT NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_participacion VARCHAR(15) CHECK (estado_participacion IN ('en progreso', 'finalizado')) DEFAULT 'en progreso',
    UNIQUE (id_proyecto, id_freelancer),
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto),
    FOREIGN KEY (id_freelancer) REFERENCES Freelancer_Maestro(id_freelancer)
);

-- Índices en proyectos
CREATE INDEX idx_proyecto_estado ON Proyecto_Maestro(estado);
CREATE INDEX idx_proyecto_presupuesto ON Proyecto_Maestro(presupuesto);

-- =======================================================
-- TABLA CONTRATO 
-- =======================================================
CREATE TABLE Contrato (
    id_contrato SERIAL PRIMARY KEY,
    id_proyecto INT NOT NULL,
    estado VARCHAR(15) CHECK (estado IN ('pendiente', 'activo', 'finalizado', 'cancelado')) DEFAULT 'pendiente',
    terminos TEXT NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_finalizacion TIMESTAMP,
    FOREIGN KEY (id_proyecto) REFERENCES Proyecto_Maestro(id_proyecto)
);

CREATE TABLE Termino_Contrato (
    id_termino SERIAL PRIMARY KEY,
    id_contrato INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato)
);

CREATE TABLE Firma_Contrato (
    id_contrato INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_firma TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_contrato, id_usuario),
    FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Índice para búsqueda rápida de contratos
CREATE INDEX idx_contrato_estado ON Contrato(estado);

-- Vista para contrato (incluye id_emprendedor)
CREATE VIEW Vista_Contrato AS
SELECT 
    c.id_contrato,
    c.id_proyecto,
    p.id_emprendedor,
    c.estado,
    c.terminos,
    c.fecha_inicio,
    c.fecha_finalizacion
FROM Contrato c
JOIN Proyecto_Maestro p ON c.id_proyecto = p.id_proyecto;

-- =======================================================
-- TABLA DE PAGOS 
-- =======================================================
CREATE TABLE Pago_Maestro (
    id_pago SERIAL PRIMARY KEY,
    id_contrato INT NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL CHECK (monto_total > 0),
    estado VARCHAR(15) CHECK (estado IN ('pendiente', 'completado', 'cancelado')) DEFAULT 'pendiente',
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(15) CHECK (metodo IN ('tarjeta', 'paypal', 'transferencia')) NOT NULL,
    FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato)
);

CREATE TABLE Pago_Detalle (
    id_pago INT NOT NULL,
    id_freelancer INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    concepto VARCHAR(100) NOT NULL DEFAULT 'Pago por servicios',
    PRIMARY KEY (id_pago, id_freelancer),
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




----INSERTS----

-------------------------------------------------------------------------------
-- 1) USUARIO (20 registros: 10 Emprendedores + 10 Freelancers)
-------------------------------------------------------------------------------
INSERT INTO Usuario (nombre, email, contraseña, tipo_usuario, telefono)
VALUES
  -- 10 Emprendedores (id_usuario 1..10)
  ('Emp 1',  'emp1@example.com',  'empPass1',  'emprendedor', '555-1001'),
  ('Emp 2',  'emp2@example.com',  'empPass2',  'emprendedor', '555-1002'),
  ('Emp 3',  'emp3@example.com',  'empPass3',  'emprendedor', '555-1003'),
  ('Emp 4',  'emp4@example.com',  'empPass4',  'emprendedor', '555-1004'),
  ('Emp 5',  'emp5@example.com',  'empPass5',  'emprendedor', '555-1005'),
  ('Emp 6',  'emp6@example.com',  'empPass6',  'emprendedor', '555-1006'),
  ('Emp 7',  'emp7@example.com',  'empPass7',  'emprendedor', '555-1007'),
  ('Emp 8',  'emp8@example.com',  'empPass8',  'emprendedor', '555-1008'),
  ('Emp 9',  'emp9@example.com',  'empPass9',  'emprendedor', '555-1009'),
  ('Emp 10','emp10@example.com', 'empPass10','emprendedor', '555-1010'),

  -- 10 Freelancers (id_usuario 11..20)
  ('Free 1',  'free1@example.com',  'freePass1',  'freelancer', '555-2001'),
  ('Free 2',  'free2@example.com',  'freePass2',  'freelancer', '555-2002'),
  ('Free 3',  'free3@example.com',  'freePass3',  'freelancer', '555-2003'),
  ('Free 4',  'free4@example.com',  'freePass4',  'freelancer', '555-2004'),
  ('Free 5',  'free5@example.com',  'freePass5',  'freelancer', '555-2005'),
  ('Free 6',  'free6@example.com',  'freePass6',  'freelancer', '555-2006'),
  ('Free 7',  'free7@example.com',  'freePass7',  'freelancer', '555-2007'),
  ('Free 8',  'free8@example.com',  'freePass8',  'freelancer', '555-2008'),
  ('Free 9',  'free9@example.com',  'freePass9',  'freelancer', '555-2009'),
  ('Free 10','free10@example.com', 'freePass10','freelancer', '555-2010');


-------------------------------------------------------------------------------
-- 2) EMPRENDEDORES
--    2.1) Emprendedor_Maestro (10 registros -> id_usuario 1..10)
-------------------------------------------------------------------------------
INSERT INTO Emprendedor_Maestro (id_usuario, estado)
VALUES
  (1,  'activo'),
  (2,  'activo'),
  (3,  'activo'),
  (4,  'inactivo'),
  (5,  'activo'),
  (6,  'suspendido'),
  (7,  'activo'),
  (8,  'activo'),
  (9,  'inactivo'),
  (10, 'activo');

-------------------------------------------------------------------------------
-- 2.2) Emprendedor_Detalle (10 registros -> id_emprendedor 1..10)
-------------------------------------------------------------------------------
INSERT INTO Emprendedor_Detalle (id_emprendedor, presupuesto, preferencias, descripcion)
VALUES
  (1,  1000.00, 'Prefiere proyectos cortos', 'Buscando desarrollo web básico'),
  (2,  2500.00, 'Prefiere alta calidad',     'Expandir e-commerce'),
  (3,  500.00,  'Abierto a cualquier oferta','Necesita logo y branding'),
  (4,  8000.00, 'Prefiere trabajo remoto',   'Lanzando startup innovadora'),
  (5,  1500.00, 'Trabajo rápido y económico','Mejorar imagen de marca'),
  (6,  3000.00, 'Poca comunicación',         'Proyecto de app móvil'),
  (7,  1200.00, 'Freelancers nuevos',        'Primer proyecto en la plataforma'),
  (8,  5000.00, 'Alta calidad y experiencia','Empresa en crecimiento'),
  (9,  2000.00, 'Costos moderados',          'Rediseño de sitio web'),
  (10, 4500.00, 'Proyectos de largo plazo',  'Automatización de procesos');


-------------------------------------------------------------------------------
-- 3) FREELANCERS
--    3.1) Freelancer_Maestro (10 registros -> id_usuario 11..20)
-------------------------------------------------------------------------------
INSERT INTO Freelancer_Maestro (id_usuario, estado)
VALUES
  (11, 'activo'),
  (12, 'activo'),
  (13, 'suspendido'),
  (14, 'activo'),
  (15, 'activo'),
  (16, 'inactivo'),
  (17, 'activo'),
  (18, 'activo'),
  (19, 'activo'),
  (20, 'inactivo');

-------------------------------------------------------------------------------
-- 3.2) Freelancer_Detalle (10 registros -> id_freelancer 1..10)
-------------------------------------------------------------------------------
INSERT INTO Freelancer_Detalle (id_freelancer, reputacion, experiencia, descripcion)
VALUES
  (1,  4.5, '2 años', 'Front-end specialist'),
  (2,  3.8, '1 año',  'Desarrollador backend junior'),
  (3,  4.9, '3 años', 'Experto en diseño gráfico'),
  (4,  4.2, '2 años', 'Full stack con React/Node'),
  (5,  4.0, '4 años', 'WordPress y SEO'),
  (6,  4.7, '2 años', 'Python/Django'),
  (7,  3.5, '5 años', 'Java y Spring'),
  (8,  4.8, '3 años', 'Apps móviles Android/iOS'),
  (9,  4.9, '2 años', 'Machine Learning e IA'),
  (10, 3.7, '1 año',  'Desarrollo con .NET');


-------------------------------------------------------------------------------
-- 4) HABILIDAD (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Habilidad (nombre)
VALUES
  ('HTML/CSS'),
  ('PHP/MySQL'),
  ('Diseño Gráfico'),
  ('Python'),
  ('Mobile Dev'),
  ('Node.js'),
  ('SEO'),
  ('Java/Spring'),
  ('React'),
  ('Ruby on Rails');

-------------------------------------------------------------------------------
-- 4.1) Freelancer_Habilidad (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Freelancer_Habilidad (id_freelancer, id_habilidad, nivel)
VALUES
  (1,  1,  'avanzado'),   -- Freelance1 -> HTML/CSS
  (2,  2,  'intermedio'), -- Freelance2 -> PHP/MySQL
  (3,  3,  'experto'),    -- Freelance3 -> Diseño Gráfico
  (4,  4,  'avanzado'),   -- Freelance4 -> Python
  (5,  5,  'avanzado'),   -- Freelance5 -> Mobile Dev
  (6,  6,  'intermedio'), -- Freelance6 -> Node.js
  (7,  7,  'básico'),     -- Freelance7 -> SEO
  (8,  8,  'avanzado'),   -- Freelance8 -> Java/Spring
  (9,  9,  'experto'),    -- Freelance9 -> React
  (10,10, 'básico');      -- Freelance10-> Ruby on Rails


-------------------------------------------------------------------------------
-- 5) CERTIFICACION (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Certificacion (nombre, entidad_emisora, fecha_emision)
VALUES
  ('Cert FrontEnd',   'Tech Institute',  '2023-01-10'),
  ('Cert Backend',    'Global Code',     '2022-05-20'),
  ('Adobe Expert',    'Adobe',           '2021-08-15'),
  ('Python Master',   'Python Org',      '2023-02-01'),
  ('Mobile Guru',     'Mobile World',    '2022-11-30'),
  ('Node Developer',  'Node Foundation', '2023-03-12'),
  ('SEO Specialist',  'Marketing Org',   '2021-07-19'),
  ('Java Certified',  'Oracle',          '2022-02-25'),
  ('React Developer', 'React Community', '2023-04-05'),
  ('Ruby Certified',  'RubyCentral',     '2022-10-10');

-------------------------------------------------------------------------------
-- 5.1) Freelancer_Certificacion (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Freelancer_Certificacion (id_freelancer, id_certificacion, fecha_obtencion)
VALUES
  (1,  1,  '2023-03-01'),
  (2,  2,  '2022-06-01'),
  (3,  3,  '2022-09-10'),
  (4,  4,  '2023-02-10'),
  (5,  5,  '2022-12-01'),
  (6,  6,  '2023-03-20'),
  (7,  7,  '2021-10-05'),
  (8,  8,  '2022-02-26'),
  (9,  9,  '2023-04-10'),
  (10,10,'2022-10-11');


-------------------------------------------------------------------------------
-- 6) PROYECTOS
--    6.1) Proyecto_Maestro (10 registros -> ref. id_emprendedor 1..10)
-------------------------------------------------------------------------------
INSERT INTO Proyecto_Maestro (id_emprendedor, titulo, descripcion, presupuesto, estado)
VALUES
  (1,  'Proyecto A', 'Desarrollo eCommerce básico',    2000.00, 'abierto'),
  (2,  'Proyecto B', 'Rediseño de logotipo',           500.00,  'abierto'),
  (3,  'Proyecto C', 'Aplicación de reservas online',  3000.00, 'abierto'),
  (4,  'Proyecto D', 'Landing page promocional',       800.00,  'abierto'),
  (5,  'Proyecto E', 'Sistema de reportes',            1200.00, 'abierto'),
  (6,  'Proyecto F', 'Optimización SEO',               700.00,  'abierto'),
  (7,  'Proyecto G', 'Integración de pasarelas pago',  1500.00, 'abierto'),
  (8,  'Proyecto H', 'Migración de servidor a la nube',4000.00, 'abierto'),
  (9,  'Proyecto I', 'Chat interno corporativo',       2800.00, 'abierto'),
  (10, 'Proyecto J', 'Aplicación de analytics',        3500.00, 'abierto');

-------------------------------------------------------------------------------
-- 6.2) Requisito_Proyecto (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Requisito_Proyecto (id_proyecto, tipo, descripcion)
VALUES
  (1,  'Funcional', 'Carrito de compras y pagos'),
  (2,  'Diseño',    'Crear identidad visual'),
  (3,  'Funcional', 'Reservas con notificaciones'),
  (4,  'Diseño',    'Página marketing con formulario'),
  (5,  'Funcional', 'Generar reportes PDF y Excel'),
  (6,  'SEO',       'Optimizar metatags, velocidad'),
  (7,  'Funcional', 'Procesar tarjetas y PayPal'),
  (8,  'Infra',     'Configurar contenedores en la nube'),
  (9,  'Funcional', 'Chat en tiempo real con logs'),
  (10, 'Funcional','Dashboard de analíticas');

-------------------------------------------------------------------------------
-- 6.3) Proyecto_Detalle (10 registros -> cada proyecto con un freelancer)
-------------------------------------------------------------------------------
INSERT INTO Proyecto_Detalle (id_proyecto, id_freelancer, fecha_asignacion, estado_participacion)
VALUES
  (1,  1,  CURRENT_TIMESTAMP, 'en progreso'),
  (2,  2,  CURRENT_TIMESTAMP, 'en progreso'),
  (3,  3,  CURRENT_TIMESTAMP, 'en progreso'),
  (4,  4,  CURRENT_TIMESTAMP, 'en progreso'),
  (5,  5,  CURRENT_TIMESTAMP, 'en progreso'),
  (6,  6,  CURRENT_TIMESTAMP, 'en progreso'),
  (7,  7,  CURRENT_TIMESTAMP, 'en progreso'),
  (8,  8,  CURRENT_TIMESTAMP, 'en progreso'),
  (9,  9,  CURRENT_TIMESTAMP, 'en progreso'),
  (10,10, CURRENT_TIMESTAMP, 'en progreso');


-------------------------------------------------------------------------------
-- 7) CONTRATO
--    7.1) Contrato (10 registros -> 1..10)
-------------------------------------------------------------------------------
INSERT INTO Contrato (id_proyecto, estado, terminos, fecha_inicio, fecha_finalizacion)
VALUES
  (1,  'pendiente',  'Términos A', CURRENT_TIMESTAMP, NULL),
  (2,  'activo',     'Términos B', CURRENT_TIMESTAMP, NULL),
  (3,  'activo',     'Términos C', CURRENT_TIMESTAMP, NULL),
  (4,  'pendiente',  'Términos D', CURRENT_TIMESTAMP, NULL),
  (5,  'activo',     'Términos E', CURRENT_TIMESTAMP, NULL),
  (6,  'activo',     'Términos F', CURRENT_TIMESTAMP, NULL),
  (7,  'cancelado',  'Términos G', CURRENT_TIMESTAMP, NULL),
  (8,  'activo',     'Términos H', CURRENT_TIMESTAMP, NULL),
  (9,  'pendiente',  'Términos I', CURRENT_TIMESTAMP, NULL),
  (10, 'finalizado', 'Términos J', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-------------------------------------------------------------------------------
-- 7.2) Termino_Contrato (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Termino_Contrato (id_contrato, tipo, descripcion)
VALUES
  (1, 'Pago',        'Pago parcial al inicio'),
  (2, 'Pago',        'Pago al 50% de avance'),
  (3, 'Responsable', 'Freelancer cubre hosting'),
  (4, 'Licencias',   'Incluye licencias de software'),
  (5, 'Soporte',     'Soporte 3 meses'),
  (6, 'Entrega',     'Entrega con acceso repositorio'),
  (7, 'Cancelación', 'Costo parcial por cancelación'),
  (8, 'Garantía',    'Garantía 2 meses'),
  (9, 'Seguridad',   'SSL y encriptación incluida'),
  (10,'Entrega',     'Cierre y traspaso final');

-------------------------------------------------------------------------------
-- 7.3) Firma_Contrato (10 registros -> emprendedor = usuario 1..10)
-------------------------------------------------------------------------------
INSERT INTO Firma_Contrato (id_contrato, id_usuario, fecha_firma)
VALUES
  (1,  1,  CURRENT_TIMESTAMP),
  (2,  2,  CURRENT_TIMESTAMP),
  (3,  3,  CURRENT_TIMESTAMP),
  (4,  4,  CURRENT_TIMESTAMP),
  (5,  5,  CURRENT_TIMESTAMP),
  (6,  6,  CURRENT_TIMESTAMP),
  (7,  7,  CURRENT_TIMESTAMP),
  (8,  8,  CURRENT_TIMESTAMP),
  (9,  9,  CURRENT_TIMESTAMP),
  (10, 10, CURRENT_TIMESTAMP);


-------------------------------------------------------------------------------
-- 8) PAGOS
--    8.1) Pago_Maestro (10 registros -> contrato 1..10)
-------------------------------------------------------------------------------
INSERT INTO Pago_Maestro (id_contrato, monto_total, estado, fecha_pago, metodo)
VALUES
  (1,  400.00, 'pendiente',  CURRENT_TIMESTAMP, 'tarjeta'),
  (2,  200.00, 'completado', CURRENT_TIMESTAMP, 'paypal'),
  (3,  800.00, 'completado', CURRENT_TIMESTAMP, 'transferencia'),
  (4,  100.00, 'pendiente',  CURRENT_TIMESTAMP, 'tarjeta'),
  (5,  300.00, 'completado', CURRENT_TIMESTAMP, 'paypal'),
  (6,  700.00, 'pendiente',  CURRENT_TIMESTAMP, 'tarjeta'),
  (7,  150.00, 'cancelado',  CURRENT_TIMESTAMP, 'transferencia'),
  (8,  400.00, 'pendiente',  CURRENT_TIMESTAMP, 'tarjeta'),
  (9,  900.00, 'completado', CURRENT_TIMESTAMP, 'paypal'),
  (10, 650.00, 'pendiente',  CURRENT_TIMESTAMP, 'transferencia');

-------------------------------------------------------------------------------
-- 8.2) Pago_Detalle (10 registros -> relacionamos cada id_pago con 1 freelancer)
-------------------------------------------------------------------------------
INSERT INTO Pago_Detalle (id_pago, id_freelancer, monto, concepto)
VALUES
  (1,  1,  300.00, 'Inicio de proyecto'),
  (2,  2,  160.00, 'Adelanto'),
  (3,  3,  720.00, 'Pago final'),
  (4,  4,   80.00, 'Anticipo'),
  (5,  5,  240.00, 'Pago final'),
  (6,  6,  560.00, 'Parcialidad'),
  (7,  7,  120.00, 'Reembolso parcial'),
  (8,  8,  320.00, 'Avance proyecto'),
  (9,  9,  810.00, 'Pago completo'),
  (10,10, 520.00, 'Costo desarrollo');


-------------------------------------------------------------------------------
-- 9) CHAT Y MENSAJES
--    9.1) Chat (10 registros -> 1 chat por proyecto 1..10)
-------------------------------------------------------------------------------
INSERT INTO Chat (id_proyecto, fecha_creacion)
VALUES
  (1,  CURRENT_TIMESTAMP),
  (2,  CURRENT_TIMESTAMP),
  (3,  CURRENT_TIMESTAMP),
  (4,  CURRENT_TIMESTAMP),
  (5,  CURRENT_TIMESTAMP),
  (6,  CURRENT_TIMESTAMP),
  (7,  CURRENT_TIMESTAMP),
  (8,  CURRENT_TIMESTAMP),
  (9,  CURRENT_TIMESTAMP),
  (10, CURRENT_TIMESTAMP);

-------------------------------------------------------------------------------
-- 9.2) Mensaje (10 registros, 1 en cada chat, usuario 1..20)
-------------------------------------------------------------------------------
INSERT INTO Mensaje (id_chat, id_usuario, contenido, fecha_envio)
VALUES
  (1,  1,  'Hola desde Emprendedor 1',        CURRENT_TIMESTAMP),
  (2,  12, 'Saludos, Freelancer 2 aquí',     CURRENT_TIMESTAMP),
  (3,  3,  'Emp 3 revisando avances',        CURRENT_TIMESTAMP),
  (4,  14, 'Free 4: duda sobre requerimiento',CURRENT_TIMESTAMP),
  (5,  5,  'Emp 5 consultando plazos',       CURRENT_TIMESTAMP),
  (6,  16, 'Free 6: revisión de requisitos', CURRENT_TIMESTAMP),
  (7,  7,  'Emp 7: esperando feedback',      CURRENT_TIMESTAMP),
  (8,  18, 'Free 8: en proceso de entrega',  CURRENT_TIMESTAMP),
  (9,  9,  'Emp 9: faltan detalles',         CURRENT_TIMESTAMP),
  (10, 20, 'Free 10: finalizamos proyecto',  CURRENT_TIMESTAMP);


-------------------------------------------------------------------------------
-- 10) NOTIFICACIONES (10 registros)
-------------------------------------------------------------------------------
INSERT INTO Notificacion (id_usuario, tipo, contenido, fecha_envio, estado)
VALUES
  (1,  'mensaje',   'Tienes un nuevo mensaje en Proyecto A',  CURRENT_TIMESTAMP, 'pendiente'),
  (2,  'pago',      'Se ha procesado un pago de tu proyecto', CURRENT_TIMESTAMP, 'leído'),
  (12, 'proyecto',  'Has sido asignado a Proyecto B',         CURRENT_TIMESTAMP, 'pendiente'),
  (5,  'contrato',  'Contrato pendiente de firma',            CURRENT_TIMESTAMP, 'pendiente'),
  (14, 'mensaje',   'Mensaje nuevo en chat de Proyecto D',    CURRENT_TIMESTAMP, 'leído'),
  (9,  'pago',      'Pago completado para tu Proyecto I',     CURRENT_TIMESTAMP, 'pendiente'),
  (20, 'contrato',  'Tu contrato ha finalizado',              CURRENT_TIMESTAMP, 'pendiente'),
  (3,  'mensaje',   'Revisa notificaciones del Proyecto C',   CURRENT_TIMESTAMP, 'pendiente'),
  (6,  'proyecto',  'Invitación a un nuevo proyecto F',       CURRENT_TIMESTAMP, 'pendiente'),
  (18, 'pago',      'Transacción pendiente en tu cuenta',     CURRENT_TIMESTAMP, 'leído');


