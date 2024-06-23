/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
--из задания непонятно нужно наибольшая сумма одно покупки или валовая сумма покупки. Сделал для одной

CREATE FUNCTION Sales.getNameCustomer_MAX_pursh()
RETURNS nvarchar(64) as 
begin
declare @result nvarchar(64)
SELECT @result =(
select top 1 c.CustomerName  from Sales.Invoices (nolock) a
join Sales.InvoiceLines (nolock) b on a.InvoiceID=b.InvoiceID
join Sales.Customers (nolock) c on c.CustomerID=a.CustomerID
group by c.CustomerName, a.InvoiceID
order by SUM (b.UnitPrice*b.Quantity) desc
				)
return @result
end

select Sales.getNameCustomer_MAX_pursh()

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
create procedure Sales.getSummSalesCusid (@cusid int)
as
set nocount on
select SUM (b.UnitPrice*b.Quantity)  from Sales.Invoices (nolock) a
join Sales.InvoiceLines (nolock) b on a.InvoiceID=b.InvoiceID
join Sales.Customers (nolock) c on c.CustomerID=a.CustomerID
where c.CustomerID=@cusid
group by c.CustomerName

exec Sales.getSummSalesCusid @cusid=100

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

create function Sales.FgetSummSalesCusid (@cusid int)
returns decimal(25,3) as 
begin

return (
select SUM (b.UnitPrice*b.Quantity)  from Sales.Invoices (nolock) a
join Sales.InvoiceLines (nolock) b on a.InvoiceID=b.InvoiceID
join Sales.Customers (nolock) c on c.CustomerID=a.CustomerID
where c.CustomerID=@cusid
group by c.CustomerName
		)
end

SET STATISTICS TIME ON
select Sales.FgetSummSalesCusid (100)
exec Sales.getSummSalesCusid @cusid=100



/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
create function Sales.tableFgetSummSalesCusid (@cusid int)
RETURNS TABLE 
AS
RETURN 
select SUM (b.UnitPrice*b.Quantity) SumSaleCusid
,a.InvoiceID 
from Sales.Invoices (nolock) a
join Sales.InvoiceLines (nolock) b on a.InvoiceID=b.InvoiceID
join Sales.Customers (nolock) c on c.CustomerID=a.CustomerID
where c.CustomerID=@cusid
group by a.InvoiceID
		
select * from Sales.tableFgetSummSalesCusid (2)

select a.CustomerName
		,b.InvoiceID
		,b.SumSaleCusid
from Sales.Customers a
cross apply Sales.tableFgetSummSalesCusid (a.CustomerID) b
order by a.CustomerName, b.InvoiceID

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
/*во всех всех процедурах я бы использовал уровень изоляции по умолчанию Read Committed, так как требуется лишь исключить Dirty read,
ниже запрос проверить, какой уровень изоляции установлен*/

SELECT 
    session_id,
    CASE transaction_isolation_level 
        WHEN 0 THEN 'Unspecified' 
        WHEN 1 THEN 'Read Uncommitted' 
        WHEN 2 THEN 'Read Committed' 
        WHEN 3 THEN 'Repeatable Read' 
        WHEN 4 THEN 'Serializable' 
        WHEN 5 THEN 'Snapshot' 
    END AS TRANSACTION_ISOLATION_LEVEL 
FROM sys.dm_exec_sessions 
WHERE session_id = @@SPID;