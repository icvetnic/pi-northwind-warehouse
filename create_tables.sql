USE NorthWindCvetnicSP
GO

--prvo obriši tablicu koja ima FK-jeve
DROP TABLE dbo.cOrders

DROP TABLE dbo.dCustomers
DROP TABLE dbo.dShippers
DROP TABLE dbo.dShips
DROP TABLE dbo.dPaymentMethod
DROP TABLE dbo.dEmployees

CREATE TABLE dbo.dCustomers
	(
	CustomerID  INT PRIMARY KEY IDENTITY,
	--ne želimo samogovreæe kljuæeve 
	CustomerIDDB NVARCHAR(5) UNIQUE,
	CompanyName NVARCHAR(40) NOT NULL,
	ContactName VARCHAR(30),
	ContactTitle VARCHAR(30),
	Phone VARCHAR(24),
	Fax VARCHAR(24),
	Address VARCHAR(60),
	CityID INT,
	PostalCode VARCHAR(10),
	CityName VARCHAR(15),
	Region VARCHAR(15),
	Country VARCHAR(15)
	)

CREATE TABLE dbo.dShippers
	(
	ShipperID INT PRIMARY KEY,
	CompanyName VARCHAR(40) NOT NULL,
	Phone VARCHAR(24)
	)

CREATE TABLE dbo.dShips
	(
	ShipID INT PRIMARY KEY IDENTITY,
	ShipName NVARCHAR(40),
	ShipAddress NVARCHAR(60),
	ShipCityId INT
	)

CREATE TABLE dbo.dPaymentMethod
	(
	PaymentMethodID INT PRIMARY KEY IDENTITY,
	Description NCHAR(10)
	)

CREATE TABLE dbo.dEmployees
	(
	EmployeeID INT PRIMARY KEY,
	LastName NVARCHAR(20) NOT NULL,
	FirstName NVARCHAR(10) NOT NULL,
	Title NVARCHAR(30),
	TitleOfCourtesy VARCHAR(25),
	BirthDate SMALLDATETIME,
	HireDate SMALLDATETIME,
	Address NVARCHAR(60),
	HomePhone NVARCHAR(24),
	Extension NVARCHAR(4),
	CityId INT,
	ReportsTo INT
	--Photo i Note atributi su izbaèeni jer se po njima neæe raditi
	--nikakvo pretraživanje, a potencijalno zauzimaju puno prostora
	)

CREATE TABLE dbo.cOrders
	(
	OrderID INT PRIMARY KEY,

	CustomerID INT,
	EmployeeID INT,
	ShipVia INT,
	ShipID INT,
	PaymentMethodKey INT,
	OrderDateKey INT,
	OrderTimeKey INT,
	RequiredDateKey INT,
	RequiredTimeKey INT,
	ShippedDateKey INT,
	ShippedTimeKey INT,

	Freight MONEY,

	CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES  dbo.dCustomers (CustomerID),
	CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES  dbo.dEmployees (EmployeeID),
	CONSTRAINT FK_ShipperID FOREIGN KEY (ShipVia) REFERENCES  dbo.dShippers (ShipperID),
	CONSTRAINT FK_ShipID FOREIGN KEY (ShipID) REFERENCES  dbo.dShips (ShipID),
	CONSTRAINT FK_PaymentMethodKey FOREIGN KEY (PaymentMethodKey) REFERENCES  dbo.dPaymentMethod (PaymentMethodID),
	CONSTRAINT FK_OrderDateKey FOREIGN KEY (OrderDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_OrderTimeKey FOREIGN KEY (OrderTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_RequiredDateKey FOREIGN KEY (RequiredDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_RequiredTimeKey FOREIGN KEY (RequiredTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_ShippedDateKey FOREIGN KEY (ShippedDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_ShippedTimeKey FOREIGN KEY (ShippedTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan)
	)

GO

