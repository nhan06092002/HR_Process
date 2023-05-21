--FactQuota
SELECT SOH.SalesPersonID, 
       SPQH.QuotaDate,
       CONVERT(VARCHAR(8), SPQH.QuotaDate, 112) AS datekey,
       SUM(SOH.TotalDue) AS TotalSales, 
       SPQH.SalesQuota AS SalesTarget, 
       (SUM(SOH.TotalDue) / SPQH.SalesQuota) AS SalesTargetAttainment
FROM Sales.SalesOrderHeader SOH
INNER JOIN Sales.SalesPerson SP 
  ON SOH.SalesPersonID = SP.BusinessEntityID
INNER JOIN Sales.SalesPersonQuotaHistory SPQH 
  ON SP.BusinessEntityID = SPQH.BusinessEntityID
  AND SOH.OrderDate >= SPQH.QuotaDate
  AND SOH.OrderDate < DATEADD(QUARTER, 1, SPQH.QuotaDate)
GROUP BY SOH.SalesPersonID, SPQH.QuotaDate, CONVERT(VARCHAR(8), SPQH.QuotaDate, 112), SPQH.SalesQuota
ORDER BY SOH.SalesPersonID, SPQH.QuotaDate;

--FactSales
SELECT 
    DISTINCT(h.SalesOrderID), 
    h.SalesOrderNumber,
    h.OrderDate as OrderDateKey, 
    h.DueDate as DueDateKey,
    h.ShipDate as ShipDateKey,
    h.TerritoryID as SalesTerritoryID,
    h.TotalDue,
    h.SubTotal,
    h.TaxAmt,
    h.Freight,
    h.CustomerID,
    d.ProductID,
    h.SalesPersonID as SalesEmployeeID,
    d.UnitPrice,
    d.OrderQty, 
    da.DateKey,
    d.LineTotal
FROM 
    Sales.SalesOrderHeader h
    LEFT JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    LEFT JOIN DimDate da ON h.OrderDate = da.FullDate

--DimDate
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY, FullDate DATE, DayName NVARCHAR(10),
    DayOfMonth TINYINT, DayOfYear SMALLINT, Weekday TINYINT,  WeekOfMonth TINYINT,
    MonthName NVARCHAR(10),
    MonthOfYear TINYINT,  CalendarQuarter TINYINT,  CalendarYear SMALLINT,
    CalendarSemester TINYINT,  FiscalQuarter TINYINT, FiscalYear SMALLINT,
    FiscalSemester TINYINT
);

-- Tạo dữ liệu cho bảng DimDate
DECLARE @date DATE = '20110101';

WHILE @date <= '20161231'
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, DayName, DayOfMonth, DayOfYear, Weekday, WeekOfMonth, MonthName, MonthOfYear, CalendarQuarter, CalendarYear, CalendarSemester, FiscalQuarter, FiscalYear, FiscalSemester)
    VALUES (
        CONVERT(INT, FORMAT(@date, 'yyyyMMdd')),
        @date,
        DATENAME(WEEKDAY, @date),
        DATEPART(DAY, @date),
        DATEPART(DAYOFYEAR, @date),
        DATEPART(WEEKDAY, @date),
        DATEPART(WEEK, @date) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, @date), 0)) + 1,
        DATENAME(MONTH, @date),
        DATEPART(MONTH, @date),
        DATEPART(QUARTER, @date),
        DATEPART(YEAR, @date),
        CASE WHEN DATEPART(MONTH, @date) IN (1, 2) THEN 1 ELSE 2 END,
        CASE WHEN DATEPART(MONTH, @date) IN (1, 2, 3) THEN DATEPART(QUARTER, @date) ELSE DATEPART(QUARTER, DATEADD(MONTH, -3, @date)) + 2 END,
        DATEPART(YEAR, @date),
        CASE WHEN DATEPART(MONTH, @date) IN (1, 2) THEN 2 ELSE 1 END
    );
    SET @date = DATEADD(DAY, 1, @date);
END;

--DimSalesPerson
Select sp.BusinessEntityID as SalesPersonID,pp. FirstName,he.HireDate,he.Gender
from Sales.SalesPerson sp
left join Person.Person pp on sp.BusinessEntityID=pp.BusinessEntityID 
left join HumanResources.Employee he on sp.BusinessEntityID=he.BusinessEntityID
order by 1

-- dimCustomer
select c.CustomerID as CustomerID, concat(p.FirstName,' ' , p.LastName) as FullName
from Sales.Customer c
left join Person.Person p on c.CustomerID=p.BusinessEntityID


--DimTerritory
select TerritoryID,Name
from Sales.SalesTerritory


