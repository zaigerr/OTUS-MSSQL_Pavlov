/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "04 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
select a.PersonID, a.FullName from Application.People a
where a.IsSalesperson=1 
and not exists 
(select * from Sales.Invoices b where a.PersonID=b.SalespersonPersonID and b.InvoiceDate='2015-07-04')

/*--наконец то! нашел, где можно применить оператор EXCEPT. :) Не смог пройти мимо--*/
; WITH TEMP AS
(select a.PersonID, a.FullName from Sales.Invoices b 
							   join Application.People a 
on a.PersonID=b.SalespersonPersonID and b.InvoiceDate='2015-07-04') 
select a.PersonID, a.FullName from Application.People a where a.IsSalesperson=1
except
select * from TEMP b

/*--оптимальный запрос с WITH--*/
; WITH TEMP1 AS
(select distinct b.SalespersonPersonID from Sales.Invoices b where b.InvoiceDate='2015-07-04')
select a.PersonID, a.FullName from Application.People a 
where a.IsSalesperson=1 and a.PersonID not in (select c.SalespersonPersonID from TEMP1 c)

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 
select * from Warehouse.StockItems a
where a.UnitPrice in (select min (UnitPrice) from Warehouse.StockItems)

/*--задание на внимательность. из разряда смотрел ли ты материалы урока :) --*/
select * from Warehouse.StockItems a
where a.UnitPrice <= all  (select UnitPrice from Warehouse.StockItems)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
TODO: 
/*--не совсем понятно из задания, нужно вывести уникальные имена клиентов входящих в ТОП 5  или 5 самых больших платежей, даже если максимальный платеж был от одного клиента--*/
/*--1 вариант показываю все платежи и имена клиентов--*/
select top 5 with ties b.CustomerName, a.TransactionDate, a.TransactionAmount from Sales.CustomerTransactions a 
join Sales.Customers b on a.CustomerID=b.CustomerID order by a.TransactionAmount desc

;WITH TEMPcte AS (
select top 5 with ties b.CustomerName, a.TransactionDate, a.TransactionAmount from Sales.CustomerTransactions a
join Sales.Customers b on a.CustomerID=b.CustomerID order by a.TransactionAmount desc
)
Select  c.CustomerName, c.TransactionDate, c.TransactionAmount from TEMPcte c order by c.TransactionDate

/*--2 вариант только уникальные имена клиентов из ТОП 5 --*/
select a.CustomerName from Sales.Customers a 
where a.CustomerID in (select top 5 with ties b.CustomerID from Sales.CustomerTransactions b order by b.TransactionAmount desc)

;WITH TEMPcte1 AS(
select top 5 with ties b.CustomerID from Sales.CustomerTransactions b order by b.TransactionAmount desc
)
select distinct c.CustomerID, c.CustomerName from TEMPcte1 a
join Sales.Customers c on c.CustomerID=a.CustomerID


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

/*--1 вариант--*/
TODO: 
;WITH tempcte2 as (
select d.CustomerID, d.PackedByPersonID from Sales.Invoices d where d.OrderID in (
select b.OrderID from Sales.OrderLines b where b.StockItemID in (
select top 3 a.StockItemID from Warehouse.StockItems a order by a.UnitPrice desc)
)
)
select Distinct f.DeliveryCityID,g.CityName,h.FullName from tempcte2 e 
join Sales.Customers f on e.CustomerID=f.CustomerID
join Application.Cities g on g.CityID=f.DeliveryCityID
join Application.People h on h.PersonID=e.PackedByPersonID

/*--2 вариант--*/
;WITH tempcte3 as (
select top 3 a.StockItemID from Warehouse.StockItems a order by a.UnitPrice desc
)
, tempcte4 as
(select distinct d.DeliveryCityID,c.PackedByPersonID,b.StockItemID from Sales.OrderLines b
join Sales.Invoices c on b.OrderID=c.OrderID
join Sales.Customers d on d.CustomerID=c.CustomerID
)
select distinct f.DeliveryCityID,g.CityName,h.FullName from tempcte3 e
join tempcte4 f on e.StockItemID=f.StockItemID
join Application.Cities g on g.CityID=f.DeliveryCityID
join Application.People h on h.PersonID=f.PackedByPersonID

/*--3 вариант--*/
;WITH stock_id as (
 select top 3 a.StockItemID from Warehouse.StockItems a order by a.UnitPrice desc)
,order_id as (
 select c.OrderID from stock_id b join Sales.OrderLines c on b.StockItemID=c.StockItemID)
 ,cus_id as (
 select  e.CustomerID, e.PackedByPersonID from order_id d join Sales.Invoices e on d.OrderID=e.OrderID)
,delivery_id as (
 select distinct g.DeliveryCityID, f.PackedByPersonID from cus_id f join Sales.Customers g on f.CustomerID=g.CustomerID)
,final as (
 select h.DeliveryCityID, i.CityName,j.FullName from delivery_id h join  Application.Cities i on h.DeliveryCityID=i.CityID
																  join Application.People j on h.PackedByPersonID=j.PersonID)
select * from final


--Во все вариантах, в плане запроса какое то предупреждение! Не понимаю, что не устраивает SQL SERVER

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

/*--запрос выводит номер накладной, дату накладной, имя менеджера продаж, Общую сумму, полученную из строк заказа, Общую сумму по строкам товаров в накладной 
В вывод попадают накладные сумма которых > 27000 (считаем количество * цену), группируем по номеру накладной
--*/

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

/*--Попробую оптимизировать этот запрос.
Для начала оптимизировать буду по синтаксису,
может получится и по производительности, если убрать тройную вложенность в оригинале.

На предыдущих занятиях говорили, что стараться избегать в условиях запроса (where) использовать функции. 
Предположу, что это распространяется и на подзапросы

Буду использовать CTE. И сразу же в первой таблице постараюсь в запросе максимально сократить количество строк, чтобы 
последующие объединения не "лопатили" весь объем таблиц. Также в запросе буду всегда ограничивать на вывод число полей до минимального
Других идей нет :)
--*/

TODO: 
;WITH SalesTotals as (
SELECT	 InvoiceId
		,SUM(Quantity*UnitPrice) AS TotalSummByInvoice
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)

,SalesTotals1 as(
select	 b.InvoiceID
		,b.InvoiceDate
		,a.TotalSummByInvoice
		,b.SalespersonPersonID
		,b.OrderID
from SalesTotals a
join Sales.Invoices b on a.InvoiceID=b.InvoiceID)

,SalesTotals2 as(
select  c.InvoiceID
		,c.InvoiceDate
		,d.FullName as SalesPersonName
		,c.TotalSummByInvoice
		,c.OrderID 
from SalesTotals1 c
join Application.People d on c.SalespersonPersonID=d.PersonID)

,SalesTotals3 as(
select e.OrderID, SUM(f.PickedQuantity*f.UnitPrice) AS TotalSummForPickedItems 
from SalesTotals2 e
join Sales.OrderLines f on e.OrderID=f.OrderID
group by e.OrderID)

select	 h.InvoiceID
		,h.InvoiceDate
		,h.SalesPersonName
		,h.TotalSummByInvoice
		,g.TotalSummForPickedItems
		from SalesTotals3 g
join SalesTotals2 h on g.OrderID=h.OrderID
order by h.TotalSummByInvoice desc

/*--Я пробовал использовать SET STATISTICS IO, TIME ON, но так и не понял, как сравнивать два запроса, 
очень много значений времени в выводе, у меня два запроса, а результатов больше, на какой смотреть?
Решил использовать план запросов. Использую его чисто интуитивно, ранее не работал, вероятно чтобы сравнивать надо запускать два запроса одновременнно, 
так как если запускать по одному, то выдает всегда 100%
План прилагаю--*/