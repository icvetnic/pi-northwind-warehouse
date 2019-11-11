/*
ZADATAK 1
Koji proizvodi, te koje kategorije su najzastupljenije u narudžbama?
*/

USE NorthWindCvetnicSP
GO

SELECT  ProductName, CategoryName, COUNT(orderItems.PruductID) AS numOfOcurrence
	FROM dbo.cOrderItems AS orderItems
		JOIN
		dbo.dProducts AS products
			ON orderItems.PruductID = products.PruductID
	GROUP BY ProductName, CategoryName, orderItems.PruductID
	ORDER BY numOfOcurrence DESC
GO

SELECT  CategoryName, COUNT(products.CategoryID) AS numOfOcurrence
	FROM dbo.cOrderItems AS orderItems
		JOIN
		dbo.dProducts AS products
			ON orderItems.PruductID = products.PruductID
	GROUP BY CategoryName, products.CategoryID
	ORDER BY numOfOcurrence DESC
GO

/*
ZADATAK 2
Tko dostavlja proizvode koji se najviše prodaju?
*/

SELECT TOP 1 orderItems.SupplierID, suppliers.CompanyName, COUNT(orderItems.PruductID) AS numOfOcurrence
	FROM dbo.cOrderItems AS orderItems
		JOIN
		dbo.dSuppliers AS suppliers
			ON orderItems.SupplierID = suppliers.SupplierID
	GROUP BY orderItems.SupplierID, suppliers.CompanyName, orderItems.PruductID
	ORDER BY numOfOcurrence DESC
GO

/*
ZADATAK 3
Kojem prijevozniku su isplaæeni najveæi honorari?
*/

SELECT TOP 1 orders.ShipVia, shippers.CompanyName, SUM(orders.Freight) AS totalFreightByShipper
	FROM dbo.cOrders AS orders
		 JOIN 
		 dbo.dShippers AS shippers
			ON orders.ShipVia = shippers.ShipperID
	GROUP BY orders.ShipVia, shippers.CompanyName, orders.Freight
	ORDER BY totalFreightByShipper DESC
GO
