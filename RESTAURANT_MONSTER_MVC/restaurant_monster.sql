-- =============================================================
--  RESTAURANT MASTER MONSTER  –  Script Base de Datos MySQL
--  Autor : Mario Anrrango
--  Fecha : 2026
-- =============================================================

CREATE DATABASE IF NOT EXISTS restaurant_monster
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE restaurant_monster;

-- -----------------------------------------------------------
-- TABLA: usuarios  (login para los 3 perfiles)
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    perfil      ENUM('ADMIN','EMPLEADO','CLIENTE') NOT NULL,
    activo      TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: clientes
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nombres     VARCHAR(100) NOT NULL,
    apellidos   VARCHAR(100) NOT NULL,
    cedula      VARCHAR(10)  NOT NULL UNIQUE,
    direccion   VARCHAR(200),
    correo      VARCHAR(100),
    telefono    VARCHAR(15),
    id_usuario  INT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: empleados (meseros)
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS empleados (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombres         VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    cedula          VARCHAR(10)  NOT NULL UNIQUE,
    cargo           VARCHAR(80)  NOT NULL DEFAULT 'Mesero',
    telefono        VARCHAR(15),
    correo          VARCHAR(100),
    fecha_ingreso   DATE,
    id_usuario      INT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_empleado_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: categorias  (ENTRADA, SOPA, PLATO_FUERTE, POSTRE, BEBIDA)
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre  VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: platos
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS platos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(120) NOT NULL,
    descripcion     TEXT,
    precio          DECIMAL(8,2) NOT NULL,
    foto            VARCHAR(300) DEFAULT 'img/default.jpg',
    id_categoria    INT NOT NULL,
    activo          TINYINT(1) NOT NULL DEFAULT 1,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_plato_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: pedidos
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente      INT NOT NULL,
    id_empleado     INT,
    fecha           DATE NOT NULL,
    hora            TIME NOT NULL,
    estado          ENUM('PENDIENTE','PAGADO','CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
    subtotal        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    iva             DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    servicio        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_pedido_cliente  FOREIGN KEY (id_cliente)  REFERENCES clientes(id),
    CONSTRAINT fk_pedido_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------
-- TABLA: detalle_pedido
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_pedido (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_plato        INT NOT NULL,
    cantidad        INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal_linea  DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_plato  FOREIGN KEY (id_plato)  REFERENCES platos(id)
) ENGINE=InnoDB;

-- =============================================================
--  DATOS INICIALES
-- =============================================================

-- Categorías
INSERT INTO categorias (nombre) VALUES
    ('ENTRADA'),
    ('SOPA'),
    ('PLATO FUERTE'),
    ('POSTRE'),
    ('BEBIDA');

-- Usuario Admin (password: admin123)
INSERT INTO usuarios (username, password, perfil) VALUES
    ('admin', 'admin123', 'ADMIN');

-- Platos – ENTRADAS  (id_categoria = 1)
INSERT INTO platos (nombre, descripcion, precio, foto, id_categoria) VALUES
    ('Empanada de Morocho',
     'Platillo tradicional ecuatoriano, hecho con masa de maíz morocho y relleno de carne, arvejas y otros ingredientes, que se fríe hasta dorarse.',
     1.00, 'img/ENTRADA/empanada-de-morocho.jpg', 1),
    ('Bolón de Verde',
     'Plato típico de Ecuador. Se elabora a base de plátano verde (plátano macho) que se cocina y se machaca, luego se mezcla con queso, chicharrón o chorizo, y se forma una masa que se fríe hasta dorarse.',
     3.00, 'img/ENTRADA/bolon-de-verde.jpg', 1),
    ('Ceviche de Camarón',
     'Platillo fresco y cítrico donde los camarones se cocinan en jugo de limón o lima y se mezclan con vegetales frescos como tomate, cebolla, cilantro y aguacate.',
     5.00, 'img/ENTRADA/ceviche-de-camaron.jpg', 1);

-- Platos – SOPAS  (id_categoria = 2)
INSERT INTO platos (nombre, descripcion, precio, foto, id_categoria) VALUES
    ('Caldo de Bolas de Verde',
     'Sopa tradicional ecuatoriana, hecha con bolas de plátano verde rellenas de carne y vegetales, cocidas en un caldo sabroso con yuca y maíz.',
     3.50, 'img/SOPAS/caldo-bolas-verde.jpg', 2),
    ('Caldo de Gallina',
     'Caldo de gallina criolla, muy simple, que se puede servir como consomé o con la presa. Se acompaña con papa, cebollita blanca y cilantro.',
     3.50, 'img/SOPAS/caldo-de-gallina.webp', 2),
    ('Caldo de Patas',
     'Sopa tradicional ecuatoriana hecha con patas de res, mote, yuca, maní y leche, acompañada de arroz y ají, ideal para días fríos.',
     3.50, 'img/SOPAS/caldo-de-patas.png', 2);

-- Platos – PLATOS FUERTES  (id_categoria = 3)
INSERT INTO platos (nombre, descripcion, precio, foto, id_categoria) VALUES
    ('Arroz Marinero',
     'Plato latinoamericano de arroz con mariscos, similar a la paella española, que combina arroz cocido en caldo de mariscos con camarones, calamares, mejillones y especias.',
     9.00, 'img/PLATO_FUERTE/arroz-marinero.jpg', 3),
    ('Churrasco',
     'Corte de carne popular en América Latina, preparado a la parrilla o a la plancha, acompañado de papas fritas, arroz y ensalada.',
     5.00, 'img/PLATO_FUERTE/churrasco.jpg', 3),
    ('Apanado',
     'Filetes de carne empanizados, crujientes por fuera y jugosos por dentro, acompañados de arroz, menestra y ensalada.',
     4.50, 'img/PLATO_FUERTE/apanado.webp', 3);

-- Platos – POSTRES  (id_categoria = 4)
INSERT INTO platos (nombre, descripcion, precio, foto, id_categoria) VALUES
    ('Dulce de Higos',
     'Postre tradicional ecuatoriano de higos tiernos confitados en almíbar de panela, servido con queso fresco.',
     1.50, 'img/POSTRE/dulce-de-higos.webp', 4),
    ('Espumilla',
     'Merengue tradicional ecuatoriano de guayaba, claras de huevo y azúcar, famoso por su textura cremosa.',
     0.80, 'img/POSTRE/espumilla.jpg', 4),
    ('Helado Artesanal',
     'Helado artesanal elaborado con frutas tropicales ecuatorianas, cremoso y refrescante.',
     1.00, 'img/POSTRE/helado.jpg', 4);

-- Platos – BEBIDAS  (id_categoria = 5)
INSERT INTO platos (nombre, descripcion, precio, foto, id_categoria) VALUES
    ('Jugo de Naranja Natural',
     'Jugo de naranja recién exprimido, refrescante y natural, sin azúcar añadida.',
     1.50, 'img/BEBIDAS/jugo-naranja.jpg', 5),
    ('Limonada',
     'Limonada natural preparada con limón fresco, agua y azúcar al gusto.',
     1.50, 'img/BEBIDAS/limonada.jpg', 5),
    ('Agua Mineral',
     'Agua mineral sin gas, presentación personal 500ml.',
     0.75, 'img/BEBIDAS/agua-mineral.jpg', 5),
    ('Cola',
     'Bebida gaseosa presentación 355ml.',
     1.00, 'img/BEBIDAS/cola.jpg', 5);
