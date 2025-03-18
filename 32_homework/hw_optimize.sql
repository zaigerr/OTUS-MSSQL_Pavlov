SET STATISTICS IO, TIME ON;
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
-----Этот JOIN не используется-----------------------------		
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
-----------------------------------------------------------
WHERE Inv.BillToCustomerID != ord.CustomerID
-----Позапросы в Where плохая идея--------------------------
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
-----Очень странный способ сравнивать даты------------------
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

/*SQL Server Execution Times:CPU time = 187 ms,  elapsed time = 736 ms.*/

-------------------------------------------------------------------------------------------------------------------------
-----Правильней сначала агрегировать данные отфильтровав их, а потом уже соединять

-- Использую CTE для предварительного агрегирования данных
;WITH CustomerTotalSales AS (
    SELECT 
        ordTotal.CustomerID,
        SUM(Total.UnitPrice * Total.Quantity) AS TotalSales
    FROM Sales.OrderLines AS Total
    JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    GROUP BY ordTotal.CustomerID
),
-- Фильтрую по SupplierID = 12
FilterStockItems AS (
    SELECT StockItemID
    FROM Warehouse.StockItems
    WHERE SupplierID = 12
)
SELECT 
    ord.CustomerID, 
    det.StockItemID, 
    SUM(det.UnitPrice) AS TotalUnitPrice, 
    SUM(det.Quantity) AS TotalQuantity, 
    COUNT(ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
INNER JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
INNER JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
INNER JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
INNER JOIN FilterStockItems AS It ON It.StockItemID = det.StockItemID -- присоединяю фильтрованную таблицу
INNER JOIN CustomerTotalSales AS cts ON cts.CustomerID = Inv.CustomerID -- соединяю агрегированную таблицу
WHERE 
    Inv.BillToCustomerID <> ord.CustomerID
    AND CAST(Inv.InvoiceDate AS DATE) = CAST(ord.OrderDate AS DATE) -- сравниваю даты
    AND cts.TotalSales > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;

/*SQL Server Execution Times: CPU time = 188 ms,  elapsed time = 373 ms.*/

-- Если уж совсем подходить к вопросу по-взрослому, то можно еще создать индексы
-- но надо понимать, что у этого действия есть побочный эффект в виде увеличения размера базы и времени вставки в таблицы
-- для разового запроса нет смысла. Но для эксперимента результат ниже 
CREATE INDEX IX_Orders_OrderID_CustomerID ON Sales.Orders(OrderID) INCLUDE (CustomerID, OrderDate);
CREATE INDEX IX_Invoices_OrderID_CustomerID ON Sales.Invoices(OrderID) INCLUDE (CustomerID, InvoiceDate, BillToCustomerID);
CREATE INDEX IX_OrderLines_OrderID_StockItemID ON Sales.OrderLines(OrderID) INCLUDE (StockItemID, UnitPrice, Quantity);

/* SQL Server Execution Times: CPU time = 47 ms,  elapsed time = 167 ms.*/