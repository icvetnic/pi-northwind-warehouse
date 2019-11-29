USE NorthWindCvetnicSP
GO

--prvo obriši tablicu koja ima FK-jeve
DROP TABLE dbo.cOrders
DROP TABLE dbo.cOrderItems
DROP TABLE dbo.dProducts
DROP TABLE dbo.dDiscounts
DROP TABLE dbo.dSuppliers
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
	TotalPriceWithDiscount MONEY,
	TotalPriceWithoutDiscount MONEY,
	NumOfProducts INT,
	NumOfDistinctProducts INT,
	Duration INT, -- in seconds

	CONSTRAINT FK_cOrders_CustomerID FOREIGN KEY (CustomerID) REFERENCES  dbo.dCustomers (CustomerID),
	CONSTRAINT FK_cOrders_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES  dbo.dEmployees (EmployeeID),
	CONSTRAINT FK_cOrders_ShipperID FOREIGN KEY (ShipVia) REFERENCES  dbo.dShippers (ShipperID),
	CONSTRAINT FK_cOrders_ShipID FOREIGN KEY (ShipID) REFERENCES  dbo.dShips (ShipID),
	CONSTRAINT FK_cOrders_PaymentMethodKey FOREIGN KEY (PaymentMethodKey) REFERENCES  dbo.dPaymentMethod (PaymentMethodID),
	CONSTRAINT FK_cOrders_OrderDateKey FOREIGN KEY (OrderDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrders_OrderTimeKey FOREIGN KEY (OrderTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_cOrders_RequiredDateKey FOREIGN KEY (RequiredDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrders_RequiredTimeKey FOREIGN KEY (RequiredTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_cOrders_ShippedDateKey FOREIGN KEY (ShippedDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrders_ShippedTimeKey FOREIGN KEY (ShippedTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan)
	)

GO

CREATE TABLE dbo.dProducts
	(
	ProductID INT PRIMARY KEY,
	ProductName NVARCHAR(40) NOT NULL,
	CountryOfOrigin NCHAR(25),
	QuantityPerUnit NVARCHAR(20),
	UnitPrice MONEY,
	UnitsInStock SMALLINT,
	CategoryID INT,
	CategoryName NVARCHAR(15)
	)
GO

CREATE TABLE dbo.dSuppliers
	(
	SupplierID INT PRIMARY KEY,
	CompanyName NVARCHAR(40) NOT NULL,
	ContactName NVARCHAR(30),
	ContactTitle NVARCHAR(30),
	Address NVARCHAR(60),
	CityID INT,
	Phone NVARCHAR(24),
	Fax NVARCHAR(24),
	)
GO

CREATE TABLE dbo.dDiscounts
	(
	DiscountID INT PRIMARY KEY IDENTITY,
	DiscountDesc NCHAR(30)
	)

CREATE TABLE dbo.cOrderItems
	(
	--primary key
	OrderID INT NOT NULL,
	ProductID INT NOT NULL,

	--dimensions from cOrders
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

	SupplierID INT,
	DiscountKey INT,

	UnitPrice MONEY NOT NULL,
	Quantity SMALLINT NOT NULL,
	Discount REAL NOT NULL,
	
	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ProductID),
	CONSTRAINT FK_cOrderItemes_ProductID FOREIGN KEY (ProductID) REFERENCES  dbo.dProducts (ProductID),
	CONSTRAINT FK_cOrderItemes_CustomerID FOREIGN KEY (CustomerID) REFERENCES  dbo.dCustomers (CustomerID),
	CONSTRAINT FK_cOrderItemes_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES  dbo.dEmployees (EmployeeID),
	CONSTRAINT FK_cOrderItemes_ShipperID FOREIGN KEY (ShipVia) REFERENCES  dbo.dShippers (ShipperID),
	CONSTRAINT FK_cOrderItemes_ShipID FOREIGN KEY (ShipID) REFERENCES  dbo.dShips (ShipID),
	CONSTRAINT FK_cOrderItemes_PaymentMethodKey FOREIGN KEY (PaymentMethodKey) REFERENCES  dbo.dPaymentMethod (PaymentMethodID),
	CONSTRAINT FK_cOrderItemes_OrderDateKey FOREIGN KEY (OrderDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrderItemes_OrderTimeKey FOREIGN KEY (OrderTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_cOrderItemes_RequiredDateKey FOREIGN KEY (RequiredDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrderItemes_RequiredTimeKey FOREIGN KEY (RequiredTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_cOrderItemes_ShippedDateKey FOREIGN KEY (ShippedDateKey) REFERENCES  dbo.dDatum (sifDatum),
	CONSTRAINT FK_cOrderItemes_ShippedTimeKey FOREIGN KEY (ShippedTimeKey) REFERENCES  dbo.dVrijemedan (sifVrijemeDan),
	CONSTRAINT FK_cOrderItemes_SupplierID FOREIGN KEY (SupplierID) REFERENCES  dbo.dSuppliers (SupplierID),
	CONSTRAINT FK_cOrderItemes_DiscountKey FOREIGN KEY (DiscountKey) REFERENCES  dbo.dDiscounts (DiscountID)
	)
GO
