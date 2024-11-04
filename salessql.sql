CREATE DATABASE Sales;
USE Sales;

CREATE TABLE SalesData (
    TransactionID INT PRIMARY KEY,
    OrderNumber INT,
    LineItem INT,
    OrderDate TEXT,
    DeliveryDate TEXT,
    Quantity INT,
    CustomerID INT,
    CustomerGender VARCHAR(10),
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    CustomerStateCode VARCHAR(50),
    CustomerState VARCHAR(50),
    CustomerZip VARCHAR(20),
    CustomerCountry VARCHAR(50),
    CustomerContinent VARCHAR(20),
    CustomerDOB TEXT,
    StoreID INT,
    StoreCountry VARCHAR(50),
    StoreState VARCHAR(50),
    StoreSqMeters INT,
    StoreOpenDate TEXT,
    ProductID INT,
    ProductName VARCHAR(100),
    ProductBrand VARCHAR(100),
    ProductColor VARCHAR(20),
    ProductCost DECIMAL(10, 2),
    ProductPrice DECIMAL(10, 2),
    ProductSubcategoryID INT,
    ProductSubcategory VARCHAR(100),
    ProductCategoryID INT,
    ProductCategory VARCHAR(100)
);

SELECT * FROM SalesData;

LOAD DATA LOCAL INFILE '\path.csv'
INTO TABLE SalesData
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM salesdata;

UPDATE SalesData
SET DeliveryDate = ''
WHERE DeliveryDate = 'NULL';

-- Update the columns with STR_TO_DATE to parse string dates into MySQL DATE format
UPDATE SalesData
SET 
    OrderDate = STR_TO_DATE(OrderDate, '%d/%m/%Y'),
    DeliveryDate = STR_TO_DATE(DeliveryDate, '%d/%m/%Y'),
    CustomerDOB = STR_TO_DATE(CustomerDOB, '%d/%m/%Y'),
    StoreOpenDate = STR_TO_DATE(StoreOpenDate, '%d/%m/%Y');


-- Modify the columns to enforce the DATE data type
ALTER TABLE SalesData
MODIFY COLUMN OrderDate DATE,
MODIFY COLUMN DeliveryDate DATE,
MODIFY COLUMN CustomerDOB DATE,
MODIFY COLUMN StoreOpenDate DATE;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerGender VARCHAR(50),
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    CustomerStateCode VARCHAR(50),
    CustomerState VARCHAR(50),
    CustomerZip VARCHAR(50),
    CustomerCountry VARCHAR(50),
    CustomerContinent VARCHAR(50),
    CustomerDOB DATE
);
INSERT INTO Customers (CustomerID, CustomerGender, CustomerName, CustomerCity, CustomerStateCode, CustomerState, CustomerZip, CustomerCountry, CustomerContinent, CustomerDOB)
SELECT DISTINCT CustomerID, CustomerGender, CustomerName, CustomerCity, CustomerStateCode, CustomerState, CustomerZip, CustomerCountry, CustomerContinent, CustomerDOB
FROM SalesData;

CREATE TABLE Stores (
    StoreID INT PRIMARY KEY,
    StoreCountry VARCHAR(100),
    StoreState VARCHAR(100),
    StoreSqMeters INT,
    StoreOpenDate DATE
);
INSERT INTO Stores (StoreID, StoreCountry, StoreState, StoreSqMeters, StoreOpenDate)
SELECT DISTINCT StoreID, StoreCountry, StoreState, StoreSqMeters, StoreOpenDate
FROM SalesData;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductBrand VARCHAR(100),
    ProductColor VARCHAR(20),
    ProductCost DECIMAL(10, 2),
    ProductPrice DECIMAL(10, 2),
    ProductCategoryID INT,
    ProductCategory VARCHAR(100),
    ProductSubcategoryID INT,
    ProductSubcategory VARCHAR(100)
);
INSERT INTO Products (ProductID, ProductName, ProductBrand, ProductColor, ProductCost, ProductPrice, ProductCategoryID, ProductCategory, ProductSubcategoryID, ProductSubcategory)
SELECT DISTINCT ProductID, ProductName, ProductBrand, ProductColor, ProductCost, ProductPrice, ProductCategoryID, ProductCategory, ProductSubcategoryID, ProductSubcategory
FROM SalesData;

CREATE TABLE Orders (
    TransactionID INT PRIMARY KEY,
    OrderNumber INT,
    LineItem INT,
    OrderDate DATE,
    DeliveryDate DATE,
    Quantity INT,
    CustomerID INT,
    StoreID INT,
    ProductID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
INSERT INTO Orders (TransactionID, OrderNumber, LineItem, OrderDate, DeliveryDate, Quantity, CustomerID, StoreID, ProductID)
SELECT TransactionID, OrderNumber, LineItem, OrderDate, DeliveryDate, Quantity, CustomerID, StoreID, ProductID
FROM SalesData;

CREATE TABLE ProductCategories (
    ProductCategoryID INT PRIMARY KEY,
    ProductCategory VARCHAR(100) NOT NULL
);
INSERT INTO ProductCategories (ProductCategoryID, ProductCategory)
SELECT DISTINCT ProductCategoryID, ProductCategory
FROM Products;

CREATE TABLE ProductSubcategories (
    ProductSubcategoryID INT PRIMARY KEY,
    ProductSubcategory VARCHAR(100) NOT NULL,
    ProductCategoryID INT,
    FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategories(ProductCategoryID)
);
INSERT INTO ProductSubcategories (ProductSubcategoryID, ProductSubcategory, ProductCategoryID)
SELECT DISTINCT ProductSubcategoryID, ProductSubcategory, ProductCategoryID
FROM Products;

ALTER TABLE Products
DROP COLUMN ProductCategory,
DROP COLUMN ProductSubcategory;

ALTER TABLE Products
ADD FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategories(ProductCategoryID),
ADD FOREIGN KEY (ProductSubcategoryID) REFERENCES ProductSubcategories(ProductSubcategoryID);


SELECT SUM(Quantity * ProductPrice) AS TotalRevenue
FROM orders
JOIN products ON orders.ProductID = products.ProductID;

SELECT YEAR(OrderDate) AS Year, SUM(ProductPrice * Quantity) AS Revenue
FROM orders
JOIN products ON orders.ProductID = products.ProductID
GROUP BY YEAR(OrderDate)
ORDER BY Year;

SELECT MONTH(OrderDate) AS Month, YEAR(OrderDate) AS Year, SUM(Quantity * ProductPrice) AS RevenueLast6Months
FROM orders
JOIN products ON orders.ProductID = products.ProductID
WHERE OrderDate >= DATE_SUB((SELECT MAX(OrderDate) FROM orders), INTERVAL 6 MONTH)
GROUP BY Year, Month;

SELECT SUM((ProductPrice - ProductCost) * Quantity) AS TotalProfit
FROM orders
JOIN products ON orders.ProductID = products.ProductID;

SELECT ProductSubcategoryID, 
       SUM((ProductPrice - ProductCost) * Quantity) / SUM(ProductPrice * Quantity) * 100 AS ProfitMargin
FROM orders
JOIN products ON orders.ProductID = products.ProductID
GROUP BY ProductSubcategoryID;

SELECT ProductCategoryID, 
       SUM(ProductPrice * Quantity) AS Revenue, 
       SUM(Quantity) AS QuantitySold
FROM orders
JOIN products ON orders.ProductID = products.ProductID
GROUP BY ProductCategoryID;

SELECT Year, ProductCategory, Revenue, QuantitySold
FROM (
    SELECT 
        YEAR(OrderDate) AS Year, 
        pc.ProductCategory,
        SUM(Quantity * ProductPrice) AS Revenue, 
        SUM(Quantity) AS QuantitySold,
        ROW_NUMBER() OVER (PARTITION BY YEAR(OrderDate) ORDER BY SUM(Quantity * ProductPrice) DESC) AS row_rank
    FROM orders
    JOIN products p ON orders.ProductID = p.ProductID
    JOIN productcategories pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY YEAR(OrderDate), pc.ProductCategory
) AS ranked_categories
WHERE row_rank = 1;

SELECT AVG(OrderTotal) AS AverageOrderValue
FROM (
    SELECT SUM(quantity * productprice) AS OrderTotal
    FROM orders
    JOIN products ON orders.ProductID = products.ProductID
    GROUP BY transactionID
) AS OrderTotals;

SELECT StoreCountry AS StoresLocation, SUM(ProductPrice * Quantity) AS Revenue
FROM orders
JOIN products ON orders.ProductID = products.ProductID
JOIN stores ON orders.StoreID = stores.StoreID
GROUP BY StoresLocation;

SELECT StoreID, StoreState, StoreCountry, SUM(ProductPrice * Quantity) AS Revenue
FROM orders
JOIN products ON orders.ProductID = products.ProductID
JOIN stores ON orders.StoreID = stores.StoreID
GROUP BY StoreID, StoreState, StoreCountry
ORDER BY Revenue DESC
LIMIT 5;

SELECT Year, StoreID, StoreState, StoreCountry, Revenue
FROM (
    SELECT 
        YEAR(OrderDate) AS Year, 
        s.StoreID, 
        s.StoreState, 
        s.StoreCountry, 
        SUM(Quantity * ProductPrice) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY YEAR(OrderDate) ORDER BY SUM(Quantity * ProductPrice) DESC) AS store_rank
    FROM orders
    JOIN stores s ON orders.StoreID = s.StoreID
    JOIN products ON orders.ProductID = products.ProductID
    GROUP BY YEAR(OrderDate), s.StoreID, s.StoreState, s.StoreCountry
) AS ranked_stores
WHERE store_rank = 1;

SELECT 
    Year, 
    COUNT(DISTINCT CustomerID) AS RepeatCustomers
FROM (
    SELECT 
        CustomerID, 
        YEAR(OrderDate) AS Year, 
        COUNT(OrderNumber) AS OrderCount
    FROM orders
    GROUP BY CustomerID, YEAR(OrderDate)
    HAVING OrderCount > 1
) AS RepeatOrders
GROUP BY Year;
