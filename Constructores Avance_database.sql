---Base de datos Constructores Avance

CREATE DATABASE Constructores_Avance;
GO

USE Constructores_Avance;
GO

-- Tabla de Empleados

CREATE TABLE Empleados (
    EmpleadoID INT IDENTITY PRIMARY KEY,
    NumeroCarnet VARCHAR(50) UNIQUE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Categoria VARCHAR(20) CHECK (Categoria IN ('Administrador', 'Operaria', 'Peón')) NOT NULL,
    Salario DECIMAL(10,2) CHECK (Salario BETWEEN 250000 AND 500000) DEFAULT 250000,
    Direccion VARCHAR(150) DEFAULT 'San José',
    Telefono VARCHAR(20),
    Email VARCHAR(150) UNIQUE NOT NULL
);

-- Tabla de Proyectos

CREATE TABLE Proyectos (
    ProyectoID INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) UNIQUE NOT NULL,
    Descripcion TEXT,
    FechaInicio DATE NOT NULL,
    FechaFin DATE,
    Estado VARCHAR(20) CHECK (Estado IN ('Activo', 'En Progreso', 'Finalizado')) NOT NULL
);

-- Tabla de Asignaciones

CREATE TABLE Asignaciones (
    AsignacionID INT IDENTITY PRIMARY KEY,
    EmpleadoID INT NOT NULL,
    ProyectoID INT NOT NULL,
    FechaAsignacion DATE NOT NULL,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (ProyectoID) REFERENCES Proyectos(ProyectoID),
    CONSTRAINT UC_Asignacion UNIQUE (EmpleadoID, ProyectoID)
);

-- Insertar datos en Empleados

INSERT INTO Empleados (NumeroCarnet, Nombre, FechaNacimiento, Categoria, Salario, Direccion, Telefono, Email) VALUES
('C001', 'Luis Pérez', '1990-05-15', 'Operario', 300000, 'San José', '8888-1234', 'luis.perez@avance.com'),
('C002', 'Sophia Lee González', '1985-07-10', 'Administradora', 250000, 'San José', '8888-5678', 'sophia.lee@avance.com'),
('C003', 'Marco Ramírez', '1995-02-22', 'Arquitecto', 275000, 'San José', '8888-9101', 'marco.ramirez@avance.com');

-- Insertar datos en Proyectos

INSERT INTO Proyectos (Nombre, Descripcion, FechaInicio, FechaFin, Estado) VALUES
('Construcción de Puente', 'Proyecto para construir un puente', '2023-01-01', NULL, 'En Progreso'),
('Remodelación de Edificio', 'Remodelación de oficinas principales', '2023-05-15', '2023-12-15', 'Finalizado');

-- Insertar datos en Asignaciones

INSERT INTO Asignaciones (EmpleadoID, ProyectoID, FechaAsignacion) VALUES
(1, 1, '2023-01-02'),
(2, 1, '2023-01-05'),
(3, 2, '2023-06-01');

-- Procedimientos Almacenados

-- Insertar Empleado
CREATE PROCEDURE IngresarEmpleado
    @NumeroCarnet VARCHAR(50),
    @Nombre VARCHAR(100),
    @FechaNacimiento DATE,
    @Categoria VARCHAR(20),
    @Salario DECIMAL(10,2) = 250000,
    @Direccion VARCHAR(150) = 'San José',
    @Telefono VARCHAR(20),
    @Email VARCHAR(150)
AS
BEGIN
    -- Validación de numero de carnet 

    IF EXISTS (SELECT 1 FROM Empleados WHERE NumeroCarnet = @NumeroCarnet)
    BEGIN
        RAISERROR ('El número de carnet ya existe.', 16, 1)
        RETURN
    END

    -- Validar si es mayor de edad 

    IF (DATEDIFF(YEAR, @FechaNacimiento, GETDATE()) < 18)
    BEGIN
        RAISERROR ('El empleado debe ser mayor de edad.', 16, 1)
        RETURN
    END

    -- Insertar empleado

    INSERT INTO Empleados (NumeroCarnet, Nombre, FechaNacimiento, Categoria, Salario, Direccion, Telefono, Email)
    VALUES (@NumeroCarnet, @Nombre, @FechaNacimiento, @Categoria, @Salario, @Direccion, @Telefono, @Email)
END;

-- Borrar Empleado

CREATE PROCEDURE BorrarEmpleado
    @EmpleadoID INT
AS
BEGIN
    DELETE FROM Empleados WHERE EmpleadoID = @EmpleadoID
END;

-- Modificar Empleado

CREATE PROCEDURE ModificarEmpleado
    @EmpleadoID INT,
    @NumeroCarnet VARCHAR(50),
    @Nombre VARCHAR(100),
    @FechaNacimiento DATE,
    @Categoria VARCHAR(20),
    @Salario DECIMAL(10,2),
    @Direccion VARCHAR(150),
    @Telefono VARCHAR(20),
    @Email VARCHAR(150)
AS
BEGIN
    UPDATE Empleados
    SET NumeroCarnet = @NumeroCarnet, Nombre = @Nombre, FechaNacimiento = @FechaNacimiento, Categoria = @Categoria,
        Salario = @Salario, Direccion = @Direccion, Telefono = @Telefono, Email = @Email
    WHERE EmpleadoID = @EmpleadoID
END;

-- Consultar Empleados

CREATE PROCEDURE ConsultarEmpleados
    @Categoria VARCHAR(20) = NULL
AS
BEGIN
    IF (@Categoria IS NULL)
    BEGIN
        SELECT * FROM Empleados
    END
    ELSE
    BEGIN
        SELECT * FROM Empleados WHERE Categoria = @Categoria
    END
END;

-- Insertar Proyecto

CREATE PROCEDURE IngresarProyecto
    @Nombre VARCHAR(100),
    @Descripcion TEXT,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Estado VARCHAR(20)
AS
BEGIN
    INSERT INTO Proyectos (Nombre, Descripcion, FechaInicio, FechaFin, Estado)
    VALUES (@Nombre, @Descripcion, @FechaInicio, @FechaFin, @Estado)
END;

-- Borrar Proyecto

CREATE PROCEDURE BorrarProyecto
    @ProyectoID INT
AS
BEGIN
    DELETE FROM Proyectos WHERE ProyectoID = @ProyectoID
END;

-- Modificar Proyecto

CREATE PROCEDURE ModificarProyecto
    @ProyectoID INT,
    @Nombre VARCHAR(100),
    @Descripcion TEXT,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Estado VARCHAR(20)
AS
BEGIN
    UPDATE Proyectos
    SET Nombre = @Nombre, Descripcion = @Descripcion, FechaInicio = @FechaInicio, FechaFin = @FechaFin, Estado = @Estado
    WHERE ProyectoID = @ProyectoID
END;

-- Consultar Proyectos

CREATE PROCEDURE ConsultarProyectos
AS
BEGIN
    SELECT * FROM Proyectos
END;

-- Insertar Asignación

CREATE PROCEDURE IngresarAsignacion
    @EmpleadoID INT,
    @ProyectoID INT,
    @FechaAsignacion DATE
AS
BEGIN
    -- Validar si la asignación es única

    IF EXISTS (SELECT 1 FROM Asignaciones WHERE EmpleadoID = @EmpleadoID AND ProyectoID = @ProyectoID)
    BEGIN
        RAISERROR ('El empleado ya está asignado a este proyecto.', 16, 1)
        RETURN
    END

    INSERT INTO Asignaciones (EmpleadoID, ProyectoID, FechaAsignacion)
    VALUES (@EmpleadoID, @ProyectoID, @FechaAsignacion)
END;

-- Consultar Asignaciones

CREATE PROCEDURE ConsultarAsignaciones
AS
BEGIN
    SELECT * FROM Asignaciones
END;
