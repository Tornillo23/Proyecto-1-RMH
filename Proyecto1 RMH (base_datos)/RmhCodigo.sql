-- Crear base de datos
CREATE DATABASE RMH;

-- Usar base de datos
USE RMH;




-- ZONA_ALMACEN: guarda las zonas en las que se divide el almacén.
CREATE TABLE zona_almacen (
    codigo_zona VARCHAR(5)   PRIMARY KEY,
    nombre_zona VARCHAR(30)  NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL
);

-- UNIDADES_MEDIDA: guarda las unidades de medida con las que se registran
-- las cantidades de los materiales (pieza, caja, kg, etc.).
CREATE TABLE unidades_medida (
    clave       VARCHAR(5)  PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL UNIQUE,
    abreviatura VARCHAR(10) NOT NULL
);

-- MARCA: guarda las marcas asociadas a los materiales.
CREATE TABLE marca (
    clave       VARCHAR(5)   PRIMARY KEY,
    nombre      VARCHAR(40)  NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL
);

-- CATEGORIAS: guarda las categorías que sirven para clasificar los materiales.
CREATE TABLE categorias (
    clave_categoria VARCHAR(5)   PRIMARY KEY,
    nombre          VARCHAR(40)  NOT NULL UNIQUE,
    descripcion     VARCHAR(100) NOT NULL
);

-- TIPOS_MOVIMIENTOS: guarda los tipos de movimiento que se pueden registrar
-- en el almacén. El signo indica si el movimiento suma (entrada) o resta
-- (salida) existencias.
CREATE TABLE tipos_movimientos (
    num                    INT          PRIMARY KEY AUTO_INCREMENT,
    nombre                 VARCHAR(30)  NOT NULL UNIQUE,
    signo_operacion        INT,
    descripcion_movimiento VARCHAR(100) NOT NULL,
    CONSTRAINT chk_tipos_mov_signo CHECK (signo_operacion IN (1, -1))
);

-- ESPECIFICACIONES_TECNICAS: guarda las especificaciones técnicas de los
-- materiales (tipo de especificación y su detalle o valor).
CREATE TABLE especificaciones_tecnicas (
    especificadores            INT          PRIMARY KEY AUTO_INCREMENT,
    tipo_especificacion        VARCHAR(40)  NOT NULL,
    descripcion_especificacion VARCHAR(150) NOT NULL
);

------------------------------------------------------------------------------------------------------------------

-- TABLAS CON LLAVES FORÁNEAS

-- UBICACIONES: registra la ubicación física de los materiales dentro de una
-- zona del almacén (pasillo, nivel y casilla). No puede haber dos
-- ubicaciones iguales dentro de la misma zona.
CREATE TABLE ubicaciones (
    clave_ubi    VARCHAR(15) PRIMARY KEY,
    numero_zona  INT         NOT NULL,
    numero_nivel INT         NOT NULL,
    num_casilla  INT         NOT NULL,
    clave_zona   VARCHAR(5)  NOT NULL,
    CONSTRAINT fk_ubicaciones_zona
        FOREIGN KEY (clave_zona) REFERENCES zona_almacen(codigo_zona),
    -- la combinación completa debe ser única
    CONSTRAINT uq_ubicacion
        UNIQUE (clave_zona, numero_zona, numero_nivel, num_casilla)
);

-- MATERIAL: guarda la información y las existencias actuales de cada
-- material. cantidad_actual es la suma de cantidad_disponible de todos
-- sus lotes (NUM_LOTES).
CREATE TABLE material (
    num_serie                VARCHAR(15)  PRIMARY KEY,
    nombre                   VARCHAR(60)  NOT NULL,
    descripcion              VARCHAR(200) NOT NULL,
    cantidad_actual          INT,
    cantidad_maxima          INT,
    cantidad_minima          INT,
    especificaciones_tecnicas INT         NULL,
    ubicaciones              VARCHAR(15)  NOT NULL,
    unidades_medida          VARCHAR(5)   NOT NULL,
    marca                    VARCHAR(5)   NULL,
    categoria                VARCHAR(5)   NULL,
    CONSTRAINT chk_material_actual CHECK (cantidad_actual >= 0),
    CONSTRAINT chk_material_maxima CHECK (cantidad_maxima > 0),
    CONSTRAINT chk_material_minima CHECK (cantidad_minima >= 0 AND cantidad_minima <= cantidad_maxima),
    CONSTRAINT fk_material_especificaciones
        FOREIGN KEY (especificaciones_tecnicas) REFERENCES especificaciones_tecnicas(especificadores),
    CONSTRAINT fk_material_ubicacion
        FOREIGN KEY (ubicaciones)     REFERENCES ubicaciones(clave_ubi),
    CONSTRAINT fk_material_unidad
        FOREIGN KEY (unidades_medida) REFERENCES unidades_medida(clave),
    CONSTRAINT fk_material_marca
        FOREIGN KEY (marca)           REFERENCES marca(clave),
    CONSTRAINT fk_material_categoria
        FOREIGN KEY (categoria)       REFERENCES categorias(clave_categoria)
);

-- BITACORA: registra los cambios de existencias y las acciones realizadas
-- sobre los materiales (quién, cuándo, por qué y cómo cambió el stock).
-- cantidad_stock_nuevo = cantidad_stock_anterior + (cantidad_movida * signo_operacion)
CREATE TABLE bitacora (
    num_registro            INT          PRIMARY KEY AUTO_INCREMENT,
    fecha_hora              DATETIME     NOT NULL,
    usuario                 VARCHAR(50)  NOT NULL,
    justificacion           VARCHAR(200) NOT NULL,
    accion_realizada        VARCHAR(50)  NOT NULL,
    cantidad_stock_anterior INT          NOT NULL,
    cantidad_stock_nuevo    INT          NOT NULL,
    num_serie_material      VARCHAR(15)  NOT NULL,
    CONSTRAINT fk_bitacora_material
        FOREIGN KEY (num_serie_material) REFERENCES material(num_serie)
);

-- NUM_LOTES: registra los lotes de ingreso de cada material, con su cantidad
-- inicial y la cantidad que aún está disponible en el lote.
CREATE TABLE num_lotes (
    clave               VARCHAR(8)  PRIMARY KEY,
    fecha_ingreso       DATE        NOT NULL,
    cantidad_inicial    INT,
    cantidad_disponible INT,
    serie_material      VARCHAR(15) NOT NULL,
    CONSTRAINT chk_lotes_inicial    CHECK (cantidad_inicial > 0),
    CONSTRAINT chk_lotes_disponible CHECK (cantidad_disponible >= 0),
    CONSTRAINT fk_lotes_material
        FOREIGN KEY (serie_material) REFERENCES material(num_serie)
);

-- MOVIMIENTOS_CABECERA: guarda los datos generales de cada transacción de
-- movimiento del almacén (folio, fecha, tipo y observaciones).
CREATE TABLE movimientos_cabecera (
    num_folio              INT          PRIMARY KEY AUTO_INCREMENT,
    observaciones          VARCHAR(200) NULL,
    fecha_hora_transaccion DATETIME     NOT NULL,
    tipos_movimientos      INT          NOT NULL,
    CONSTRAINT fk_mov_cab_tipo
        FOREIGN KEY (tipos_movimientos) REFERENCES tipos_movimientos(num)
);

-- MOVIMIENTOS_DETALLES: guarda los lotes (y por ende los materiales)
-- afectados en cada movimiento, junto con la cantidad movida.
CREATE TABLE movimientos_detalles (
    num_detalle         INT         PRIMARY KEY AUTO_INCREMENT,
    cantidad_movida     INT,
    movimiento_cabecera INT         NOT NULL,
    num_lotes           VARCHAR(8)  NOT NULL,
    CONSTRAINT chk_mov_det_cantidad CHECK (cantidad_movida > 0),
    CONSTRAINT fk_mov_det_cabecera
        FOREIGN KEY (movimiento_cabecera) REFERENCES movimientos_cabecera(num_folio),
    CONSTRAINT fk_mov_det_lote
        FOREIGN KEY (num_lotes)           REFERENCES num_lotes(clave)
);