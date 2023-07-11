USE NORTHWND
GO

CREATE PROCEDURE sp_VentasCompaniaXpaisMayor25000
as
select c.CompanyName,c.Country,sum(d.Quantity*d.UnitPrice) as TOTAL
from Customers as c inner join orders as o
on c.CustomerID=o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
group by CompanyName,Country
having sum(d.Quantity*d.UnitPrice)>25000
GO

execute sp_VentasCompaniaXpaisMayor25000
go



CREATE PROCEDURE SP_ReporteGeneral
AS
select c.Country,c.CompanyName,c.CustomerID,o.OrderID,o.OrderDate,
DATEPART(YYYY,o.orderdate) as año,DATEPART(mm,o.orderdate) as mes,
p.ProductName,d.UnitPrice,d.Quantity,d.UnitPrice*d.Quantity as parcial
from Customers as c inner join Orders o on c.CustomerID=o.CustomerID
					inner join [Order Details] as d on d.OrderID=o.OrderID
					inner join Products as p on p.ProductID=d.ProductID
GO

execute SP_ReporteGeneral


SELECT COUNT(1) FROM NORTHWND.DBO.Customers
GO
SELECT COUNT(1) FROM NORTHWND.DBO.Orders
GO
SELECT COUNT(1) FROM NORTHWND.DBO.[Order Details]
GO

SELECT * FROM BICICLETA.dbo.CLIENTES
GO