# Reporte-Mensual-SP-SSIS
Desarrollo de reporte mensual con procedimiento almacenado con SSIS

Antes de crear el proyecto se debe ejecutar el siguiente Script: ```Script+-+crear+database+Bicicleta.txt```

En nuestro proyecto de Integración de Servicios creamos las siguientes variables:

<b>Fecha: AAAAMMDD</b><br>```(DT_I4) ((DT_WSTR, 4)YEAR( GETDATE()  ) + RIGHT( "0" + (DT_WSTR, 2)  MONTH( GETDATE() ) , 2 ) + RIGHT( "0" + (DT_WSTR, 2)  DAY( GETDATE() ) , 2 ))```<br>
<b>Periodo: AAAAMM</b><br>```(DT_I4) LEFT( (DT_WSTR, 8) @[User::Fecha], 6 )```<br>
<b>Ruta:</b> Definimos la ruta dónde se almacenaran los archivos de Excel: <br>```C:\SSIS Integration Services\Reporte con procedimiento almacenado ```

<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen1.png"  height=150>
</p>

Ahora utilizamos <b>Execute SQl Task</b> dónde configuramos la conexión a la DB, en este caso Bicicleta y agregamos SQLStatement ```DELETE FROM CLIENTES WHERE Fecha = ?```
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen2.png"  height=350>
</p>

Agregamos un Data Flow Task para hacer la carga de data. Utilizamos como origen un Excel Source y agregamos la ruta del archivo con la fecha de hoy.
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen3.png"  height=350>
</p>

Convertimos los valores que utilizaremos:
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen4.png"  height=350>
</p>

Estableceremos la secuencia de las variables Periodo y Fecha con Derived Column:
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen5.png"  height=350>
</p>

Ahora agregamos la DB destino. <b>Nota:</b> En la parte de Mappings se copian todas las variables menos Fecha y Periodo.
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen6.png"  height=350>
</p>

Ahora vamos a establecer la conexión dinámica  hacia el archivo de Excel: Propiedades/ ExcelFilePath 
<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen7.png"  height=350>
</p>

```@[User::Ruta]+"ClientesNuevos_"+ (DT_WSTR, 8) @[User::Fecha]+".xlsx"```

Ahora creamos los SP en la DB Bicicleta

<b> SP Insertar Clientes </b>

```Ruby
USE [BICICLETA]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertarClientes]    Script Date: 8/07/2023 12:47:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_InsertarClientes]
AS
	IF EXISTS(
		SELECT CustomerID FROM BICICLETA.dbo.CLIENTES WHERE CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS NOT IN (SELECT CustomerID FROM NORTHWND.dbo.Customers)
	)
	BEGIN
		INSERT INTO NORTHWND.dbo.Customers([CustomerID], [CompanyName], [ContactName], [ContactTitle], [Address], [City], [Region], [PostalCode], [Country], [Phone], [Fax])
		SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax FROM BICICLETA.dbo.CLIENTES
		WHERE Fecha=CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0'+CAST(MONTH(GETDATE()) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(GETDATE()) AS VARCHAR(2)),2) AS INT)

		PRINT 'SE INSERTARON REGISTROS EN LA TABLA CUSTOMERS DE NORTHWND'
	END ELSE
	BEGIN
		PRINT 'YA SE ENCUENTRAN REGISTRADOS LOS CLIENTES'
	END
```
<b> SP Insertar Ordenes </b>

```Ruby
CREATE PROCEDURE SP_IntertarOrdenes
AS
	IF EXISTS(
		SELECT CustomerID FROM BICICLETA.dbo.CLIENTES WHERE CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS NOT IN (SELECT CustomerID FROM NORTHWND.dbo.Orders)
	)
	BEGIN
		INSERT INTO NORTHWND.dbo.Orders([CustomerID], [EmployeeID], [OrderDate], [RequiredDate], [ShippedDate], [ShipVia], [Freight], [ShipName], [ShipAddress], [ShipCity], [ShipRegion], [ShipPostalCode], [ShipCountry])
		SELECT CustomerID, EmployeeID, OrderDate, RequieredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry FROM BICICLETA.dbo.CLIENTES
		WHERE Fecha=CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0'+CAST(MONTH(GETDATE()) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(GETDATE()) AS VARCHAR(2)),2) AS INT)

		PRINT 'SE INSERTARON REGISTROS EN LA TABLA ORDERS DE NORTHWND'
	END ELSE
	BEGIN
		PRINT 'YA SE ENCUENTRAN REGISTRADOS LOS PEDIDOS'
	END
	GO
GO
```

<b> SP Insertar Detalles Ordenes </b>

```Ruby

CREATE PROCEDURE SP_IntertarDetallesOrdenes
AS
	IF EXISTS(
		SELECT OrderID FROM NORTHWND.dbo.Orders WHERE OrderID NOT IN (SELECT OrderID FROM NORTHWND.dbo.[Order Details])
	)
	BEGIN
		INSERT INTO NORTHWND.dbo.[Order Details]([OrderID], [ProductID], [UnitPrice], [Quantity], [Discount])
		SELECT O.OrderID, C.ProductID, C.UnitPrice, C.Quantity, C.Discount
		FROM BICICLETA.DBO.CLIENTES AS C
		INNER JOIN NORTHWND.DBO.Customers AS N
		ON C.CustomerID COLLATE Modern_Spanish_CI_AS=N.CustomerID
		INNER JOIN NORTHWND.DBO.Orders AS O
		ON N.CustomerID=O.CustomerID
		WHERE C.Fecha=CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('0'+CAST(MONTH(GETDATE()) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(GETDATE()) AS VARCHAR(2)),2) AS INT)

		PRINT 'SE INSERTARON REGISTROS EN LA TABLA [ORDER DETAILS] DE NORTHWND'
	END ELSE
	BEGIN
		PRINT 'YA SE ENCUENTRAN REGISTRADOS LOS DETALLES DE LOS PEDIDOS'
	END
	GO
GO
```
En este punto configuraremos los SPs en nuestro proyecto de Integration Services:

<p align="center">
<img src="https://github.com/csantamaria89/Reporte-Mensual-SP-SSIS/blob/main/assets/Imagen8.png"  height=550>
</p>

Finalmente vamos a generar los reportes esperados:

Lo primero que debemos hacer es crear los SPs para los reportes:

```Ruby
CREATE PROCEDURE sp_VentasCompaniaXpaisMayor25000
as
select c.CompanyName,c.Country,sum(d.Quantity*d.UnitPrice) as TOTAL
from Customers as c inner join orders as o
on c.CustomerID=o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
group by CompanyName,Country
having sum(d.Quantity*d.UnitPrice)>25000
```

```Ruby
CREATE PROCEDURE SP_ReporteGeneral
AS
select c.Country,c.CompanyName,c.CustomerID,o.OrderID,o.OrderDate,
DATEPART(YYYY,o.orderdate) as año,DATEPART(mm,o.orderdate) as mes,
p.ProductName,d.UnitPrice,d.Quantity,d.UnitPrice*d.Quantity as parcial
from Customers as c inner join Orders o on c.CustomerID=o.CustomerID
					inner join [Order Details] as d on d.OrderID=o.OrderID
					inner join Products as p on p.ProductID=d.ProductID
```
