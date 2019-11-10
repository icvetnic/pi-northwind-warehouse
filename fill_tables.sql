USE NorthWindCvetnicSP
GO

DELETE FROM dbo.cOrders
DELETE FROM dbo.dCustomers
DELETE FROM dbo.dShippers
DELETE FROM dbo.dShips
DELETE FROM dbo.dPaymentMethod
DELETE FROM dbo.dEmployees

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

DECLARE @nepoznato_vrijeme INT = DATEDIFF(ss, '00:00:00', '23:59:59') + 1

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
		(
		SELECT TOP 1 CustomerID 
			FROM  NorthWindCvetnicSP.dbo.dCustomers AS cust
			WHERE cust.CustomerIDDB = orders.CustomerID
		)
		,
		EmployeeID,
		ShipVia,
		IIF(
			orders.ShipName IS NOT NULL,
			(
			SELECT TOP 1 ShipID 
				FROM  NorthWindCvetnicSP.dbo.dShips AS ships
				WHERE ships.ShipName = orders.ShipName
					AND (ships.ShipAddress = orders.ShipAddress OR (ships.ShipAddress IS NULL AND orders.ShipAddress IS NULL))
					AND (ships.ShipCityId = orders.ShipCityId OR (ships.ShipCityId IS NULL AND orders.ShipCityId IS NULL))
			),
			(
			SELECT TOP 1 ShipID 
				FROM  NorthWindCvetnicSP.dbo.dShips AS ships
				WHERE ships.ShipName = 'nepoznato'
			)
		)
		,
		(
		SELECT TOP 1 PaymentMethodID 
			FROM  NorthWindCvetnicSP.dbo.dPaymentMethod AS method
			WHERE method.Description = orders.PaymentMethod
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

GO