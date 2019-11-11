USE NorthWindCvetnicSP
GO

/*
-----------------------------------
BRISANJE SVIH PODATAKA IZ SKLADIŠTA
-----------------------------------
*/

DELETE FROM dbo.cOrders
DELETE FROM dbo.cOrderItems
DELETE FROM dbo.dProducts
DELETE FROM dbo.dCustomers
DELETE FROM dbo.dShippers
DELETE FROM dbo.dShips
DELETE FROM dbo.dPaymentMethod
DELETE FROM dbo.dEmployees


/*
----------------------------------------
PUNJENJE DIMENZIJSKIH TABLICA ZA cOrders
----------------------------------------
*/
INSERT INTO NorthWindCvetnicSP.dbo.dCustomers
	(
	--CustomerID is generated automaticly (implicit)
	CustomerIDDB,
	CompanyName,
	ContactName,
	ContactTitle,
	Phone,
	Fax,
	Address,
	CityID,
	PostalCode,
	CityName,
	Region,
	Country
	)
	SELECT 
		CustomerID,
		CompanyName,
		ContactName,
		ContactTitle,
		Phone,
		Fax,
		Address,
		cust.CityID,
		PostalCode,
		CityName,
		Region,
		Country
		FROM NorthWind2015.dbo.Customers AS cust 
			LEFT JOIN 
			NorthWind2015.dbo.City AS city
			ON cust.CityID = city.CityID
GO

--specijalni zapis ako Customer ne postoji (CompanyName postavljamo na 'nepoznato')
INSERT INTO NorthWindCvetnicSP.dbo.dCustomers(CompanyName) VALUES ('nepozanto')
GO

INSERT INTO NorthWindCvetnicSP.dbo.dShippers
	(
	ShipperID,
	CompanyName,
	Phone
	)
	SELECT 
		ShipperID,
		CompanyName,
		Phone
		FROM NorthWind2015.dbo.Shippers 
GO

--specijalni zapis ako Shipper ne postoji (CompanyName postavljamo na 'nepoznato')
INSERT INTO NorthWindCvetnicSP.dbo.dShippers(ShipperID, CompanyName) VALUES (1000000, 'nepozanto')
GO

INSERT INTO NorthWindCvetnicSP.dbo.dShips
	(
	--ShipID is generated automaticly (implicit)
	ShipName,
	ShipAddress,
	ShipCityId
	)
	SELECT DISTINCT
			ShipName,
			ShipAddress,
			ShipCityId
			FROM NorthWind2015.dbo.Orders
GO

--brod bez imena
UPDATE NorthWindCvetnicSP.dbo.dShips
	SET ShipName = 'nepoznato'
	WHERE ShipName IS NULL

 INSERT INTO NorthWindCvetnicSP.dbo.dPaymentMethod
	(
	Description
	)
	SELECT DISTINCT	
			PaymentMethod
			FROM NorthWind2015.dbo.Orders
GO

UPDATE NorthWindCvetnicSP.dbo.dPaymentMethod
	SET Description = 'nepoznato'
	WHERE Description IS NULL

 INSERT INTO NorthWindCvetnicSP.dbo.dEmployees
	(
	EmployeeID,
	LastName,
	FirstName,
	Title,
	TitleOfCourtesy,
	BirthDate,
	HireDate,
	Address,
	HomePhone,
	Extension,
	CityId,
	ReportsTo
	)
	SELECT	
		EmployeeID,
		LastName,
		FirstName,
		Title,
		TitleOfCourtesy,
		BirthDate,
		HireDate,
		Address,
		HomePhone,
		Extension,
		CityId,
		ReportsTo
		FROM NorthWind2015.dbo.Employees
GO

--specijalni zapis ako Emplyee ne postoji (FirstName postavljamo na 'nepoznato')
INSERT INTO NorthWindCvetnicSP.dbo.dEmployees(EmployeeID, LastName, FirstName) VALUES (1000000, 'nepozanto', 'nepozanto')
GO

/*
--------------------------------------------
PUNJENJE ÈINJENIÈNE TABLICE cOrders
--------------------------------------------
*/

--pomoæne varijable
DECLARE @nepoznato_vrijeme INT = DATEDIFF(ss, '00:00:00', '23:59:59') + 1

DECLARE @CustomerID_nepoznato INT =
		(
		SELECT TOP 1 CustomerID
		FROM  NorthWindCvetnicSP.dbo.dCustomers AS c
		WHERE c.CompanyName = 'nepoznato'
		)

DECLARE @ShipID_nepoznato INT =
		(
		SELECT TOP 1 ShipID 
		FROM  NorthWindCvetnicSP.dbo.dShips AS ships
		WHERE ships.ShipName = 'nepoznato'
		)

DECLARE @PaymentMethodID_nepoznato INT =
		(
			SELECT TOP 1 PaymentMethodID 
				FROM  NorthWindCvetnicSP.dbo.dPaymentMethod AS method
				WHERE method.Description = 'nepoznato'
		)

 INSERT INTO NorthWindCvetnicSP.dbo.cOrders
	(
	OrderID,
	CustomerID,
	EmployeeID,
	ShipVia,
	ShipID,
	PaymentMethodKey,
	OrderDateKey,
	OrderTimeKey,
	RequiredDateKey,
	RequiredTimeKey,
	ShippedDateKey,
	ShippedTimeKey,
	Freight
	)
	SELECT	
		OrderID,
		IIF(orders.CustomerID IS NOT NULL, customers.CustomerID, @CustomerID_nepoznato),
		IIF(orders.EmployeeID IS NOT NULL, employees.EmployeeID, 1000000),
		IIF(orders.ShipVia IS NOT NULL, shippers.ShipperID, 1000000),
		IIF(
			orders.ShipName IS NOT NULL,
			(
			SELECT TOP 1 ShipID 
				FROM  NorthWindCvetnicSP.dbo.dShips AS ships
				WHERE ships.ShipName = orders.ShipName
					AND (ships.ShipAddress = orders.ShipAddress OR (ships.ShipAddress IS NULL AND orders.ShipAddress IS NULL))
					AND (ships.ShipCityId = orders.ShipCityId OR (ships.ShipCityId IS NULL AND orders.ShipCityId IS NULL))
			),
			@ShipID_nepoznato
		)
		,
		IIF(
			orders.PaymentMethod IS NOT NULL,
			pmethod.PaymentMethodID,
			@PaymentMethodID_nepoznato
		)
		,
		--Pretvori SMALLDATETIME u DATE, zatim pretvori u format 'yyyymmdd', na kraju pretvori u INT
		IIF(OrderDate IS NULL, 1000000000, CAST(CONVERT(char(8), CAST(OrderDate AS DATE), 112) AS INT)),
		--Pretvori SMALLDATETIME u TIME, zatim pretvori u INT
		IIF(OrderDate IS NULL,  @nepoznato_vrijeme, DATEDIFF(ss, 0, CAST(OrderDate AS TIME(0)))),
		IIF(RequiredDate IS NULL, 1000000000, CAST(CONVERT(char(8), CAST(RequiredDate AS DATE), 112) AS INT)),
		IIF(RequiredDate IS NULL,  @nepoznato_vrijeme, DATEDIFF(ss, 0, CAST(RequiredDate AS TIME(0)))),
		IIF(ShippedDate IS NULL, 1000000000, CAST(CONVERT(char(8), CAST(ShippedDate AS DATE), 112) AS INT)),
		IIF(ShippedDate IS NULL,  @nepoznato_vrijeme, DATEDIFF(ss, 0, CAST(ShippedDate AS TIME(0)))),
		Freight
		FROM NorthWind2015.dbo.Orders AS orders
			 LEFT JOIN NorthWindCvetnicSP.dbo.dCustomers AS customers
				ON orders.CustomerID = customers.CustomerIDDB
			 LEFT JOIN NorthWindCvetnicSP.dbo.dPaymentMethod AS pmethod
				ON orders.PaymentMethod = pmethod.Description
			 LEFT JOIN NorthWindCvetnicSP.dbo.dEmployees AS employees
				ON orders.EmployeeID = employees.EmployeeID
			 LEFT JOIN NorthWindCvetnicSP.dbo.dShippers AS shippers
				ON orders.ShipVia = shippers.ShipperID
GO


/*
--------------------------------------------
PUNJENJE DIMENZIJSKIH TABLICA ZA cOrderItems
--------------------------------------------
*/
INSERT INTO NorthWindCvetnicSP.dbo.dProducts
	(
	PruductID,
	ProductName,
	CategoryID,
	CategoryName
	)
	SELECT 
		ProductID,
		ProductName,
		prod.CategoryID,
		CategoryName
		FROM NorthWind2015.dbo.Products AS prod
			 LEFT JOIN
			 NorthWind2015.dbo.Categories AS cat
				ON prod.CategoryID = cat.CategoryID
GO

INSERT INTO NorthWindCvetnicSP.dbo.dSuppliers
	(
	SupplierID,
	CompanyName,
	ContactName,
	ContactTitle,
	Address,
	CityID,
	Phone,
	Fax
	)
	SELECT 
		SupplierID,
		CompanyName,
		ContactName,
		ContactTitle,
		Address,
		CityID,
		Phone,
		Fax
		FROM NorthWind2015.dbo.Suppliers
GO

--specijalni zapis ako Supplier ne postoji (CompanyName postavljamo na 'nepoznato')
INSERT INTO NorthWindCvetnicSP.dbo.dSuppliers (SupplierID, CompanyName) VALUES (1000000, 'nepozanto')

 INSERT INTO NorthWindCvetnicSP.dbo.dDiscounts (DiscountDesc)
	SELECT DISTINCT	
		DiscountDesc
			FROM NorthWind2015.dbo.OrderItems
			WHERE DiscountDesc IS NOT NULL
GO

--Postoje popusti koji nemaju opis
 INSERT INTO NorthWindCvetnicSP.dbo.dDiscounts (DiscountDesc)
	VALUES
		('bez popusta'),
		('nepoznato')
GO

/*
--------------------------------------------
PUNJENJE ÈINJENIÈNE TABLICE cOrderItems
--------------------------------------------
*/

--pomoæne varijable
DECLARE @nepoznato_vrijeme INT = DATEDIFF(ss, '00:00:00', '23:59:59') + 1

DECLARE @discountID_bez_popusta INT = 
		(
		SELECT TOP 1 DiscountID 
		FROM dDiscounts
		WHERE DiscountDesc = 'bez popusta'
		)

DECLARE @discountID_nepoznato INT = 
		(
		SELECT TOP 1 DiscountID 
		FROM dDiscounts
		WHERE DiscountDesc = 'nepoznato'
		)

 INSERT INTO NorthWindCvetnicSP.dbo.cOrderItems
	(
	--primary key
	OrderID,
	PruductID,

	--dimensions from cOrders
	CustomerID,
	EmployeeID,
	ShipVia,
	ShipID,
	PaymentMethodKey,
	OrderDateKey,
	OrderTimeKey,
	RequiredDateKey,
	RequiredTimeKey,
	ShippedDateKey,
	ShippedTimeKey,

	SupplierID,
	DiscountKey, 

	UnitPrice,
	Quantity,
	Discount
	)
	SELECT	
		orderItems.OrderID,
		orderItems.ProductID,
		CustomerID,
		EmployeeID,
		ShipVia,
		ShipID,
		PaymentMethodKey,
		OrderDateKey,
		OrderTimeKey,
		RequiredDateKey,
		RequiredTimeKey,
		ShippedDateKey,
		ShippedTimeKey,
		IIF(products.SupplierID IS NOT NULL, suppliers.SupplierID, 1000000)
		,
		(
		CASE
			WHEN orderItems.DiscountDesc IS NULL AND orderItems.Discount > 0
				THEN @discountID_nepoznato
			WHEN orderItems.DiscountDesc IS NULL AND orderItems.Discount = 0
				THEN @discountID_bez_popusta
			ELSE disc.DiscountID
		END
		),
		orderItems.UnitPrice,
		Quantity,
		Discount
		FROM NorthWind2015.dbo.OrderItems AS orderItems
			 LEFT JOIN NorthWindCvetnicSP.dbo.cOrders AS orders
				ON orderItems.OrderID = orders.OrderID
			 LEFT JOIN NorthWindCvetnicSP.dbo.dDiscounts AS disc
				ON orderItems.DiscountDesc = disc.DiscountDesc
			 LEFT JOIN NorthWind2015.dbo.Products AS products
				ON orderItems.ProductID = products.ProductID
			 LEFT JOIN NorthWindCvetnicSP.dbo.dSuppliers AS suppliers
				ON products.SupplierID = suppliers.SupplierID
GO