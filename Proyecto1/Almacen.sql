-- Active: 1792508140969@@127.0.0.1@3306@almacen3e
---------BASE DE DATOS
/*
    --DDL
    --DML
    --DQL
*/

--------------DDL
--Crear la BD almacen

CREATE DATABASE almacen3e

-- Usar la BD
use almacen3e 

-- Crear tabla CIUDAD

CREATE table ciudad(
    codigo VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(15) not null UNIQUE
)

-- Crrar la tabla producto
CREATE table producto(
    codigo VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(90) NOT NULL,
    precio float NOT NULL
)

-- crear tabla concepto pago
CREATE table concepto_pago(
    codigo VARCHAR(5) PRIMARY key,
    nombre VARCHAR(15) NOT null UNIQUE
)

-- crear tabla edo_pedido
CREATE table edo_pedido(
    CODIGO VARCHAR(4) PRIMARY KEY,
    descripcion VARCHAR (15) NOT NULL UNIQUE

)

CREATE table cliente(
    num int PRIMARY KEY AUTO_INCREMENT,
    nombreFiscal VARCHAR(50) NOT NULL,
    contNombre VARCHAR(30) NOT NULL,
    contPrimerApell VARCHAR(30) NOT NULL,
    contSegApell VARCHAR(30),
    numTel VARCHAR(15) NOT NULL,
    limCredito DECIMAL(10,2) NOT NULL,
    creditoDisponible DECIMAL(10,2) NOT NULL

)

CREATE table sucursal(
    codigo VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    dirCalle VARCHAR(30) NOT NULL,
    dirNum VARCHAR(10) NOT NULL,
    dirColonia VARCHAR(30)NOT NULL,
    ciudad VARCHAR(5) NOT NULL,
    FOREIGN KEY (ciudad) REFERENCES ciudad(codigo)

)

CREATE TABLE rep_vtas(
    num int PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    primerApell VARCHAR(30) NOT NULL,
    segApell VARCHAR(30), 
    fechaContrato DATE NOT NULL,
    director int,
    sucursal VARCHAR(5) NOT NULL,
    FOREIGN KEY (sucursal) REFERENCES sucursal(codigo)

)

ALTER table rep_vtas
ADD constraint fk_reventas_director
Foreign Key (director) REFERENCES rep_vtas(num)


CREATE table almacen(
    sucursal VARCHAR(5),
    producto VARCHAR(5),
    stock int NOT NULL,
    PRIMARY KEY(sucursal, producto),
    Foreign Key (sucursal) REFERENCES sucursal(codigo),
    Foreign Key (producto) REFERENCES producto(codigo)
)

CREATE table meta(
    num int PRIMARY KEY AUTO_INCREMENT,
    fechaInicio date NOT NULL,
    fechaFinal date NOT NULL,
    montoMeta DECIMAL(10,2) NOT NULL,
    montoventas DECIMAL(10,2) NOT NULL,
    sucursal VARCHAR(5),
    repVentas int, 
    Foreign Key (sucursal) REFERENCES sucursal(codigo),
    Foreign Key (repvtas) REFERENCES rep_vtas(num)
)

create table pedido(
    num INT PRIMARY KEY,
    fecha date NOT NULL,
    canTotalPros int NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL (10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    totalContInt DECIMAL(10,2) NOT NULL,
    sucursal VARCHAR(5) not null,
    repVtas Int NOT NULL,
    clientes int not null,
    estado VARCHAR(4) not null,
    Foreign Key (sucursal) REFERENCES sucursal(codigo),
    Foreign Key (repvtas) REFERENCES rep_vtas(num),
    Foreign Key (cliente) REFERENCES cliente(num),
    Foreign Key (estado) REFERENCES edo_pedido(codigo)
)

CREATE table ped_prod(
    pedido INT,
    producto VARCHAR(5),
    cantidad int not null,
    importe decimal(10,2),
    Foreign Key (pedido) REFERENCES pedido(num),
    Foreign Key (producto) REFERENCES producto(codigo),
    PRIMARY KEY(pedido, producto)
)

create table pago(
    numero int PRIMARY KEY AUTO_INCREMENT,
    fecha date not null,
    numPago int not null,
    montoPago decimal(10,2) not null,
    saldo decimal(10,2) not null, 
    concepto VARCHAR(5) not NULL,
    pedido int not null,
    Foreign Key (concepto) REFERENCES concepto_pago(codigo),
    Foreign Key (pedido) REFERENCES pedido(num)
)

/*
-- APRENDER LA REGLA DE ENTIDAD REFERENCIAL
*/