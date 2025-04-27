USE WideWorldImporters
/* 1. Выбрать таблицу для секционирования
Возьмем запрос и выберем таблицы с мак количеством строк */
SELECT 
	t.NAME AS TableName,
	s.Name AS SchemaName,
	p.rows AS RowCounts
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
	AND p.partition_number = 1
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    p.rows desc, t.name

--выбираю Warehouse.StockItemTransactions и делаю дубль в [Test_DB].[dbo].test_partition
create database Test_DB
/*
use Test_DB 
drop table if exists test_partition
drop table if exists stage
drop partition scheme pshem_date
drop partition function pfunc_date
*/
SELECT [StockItemTransactionID]
      ,[StockItemID]
      ,[TransactionTypeID]
      ,[CustomerID]
      ,[InvoiceID]
      ,[SupplierID]
      ,[PurchaseOrderID]
      ,[TransactionOccurredWhen]
      ,[Quantity]
      ,[LastEditedBy]
      ,[LastEditedWhen]
INTO [Test_DB].[dbo].[test_partition]
FROM [WideWorldImporters].[Warehouse].[StockItemTransactions]

use Test_DB 

--Выбираю граничный точки
SELECT year (a.TransactionOccurredWhen) as years FROM [Test_DB].[dbo].[test_partition] a
GROUP BY year (a.TransactionOccurredWhen)
ORDER BY 1

use [master]
alter database Test_DB add filegroup Test_DB_2013
alter database Test_DB add filegroup Test_DB_2014
alter database Test_DB add filegroup Test_DB_2015
alter database Test_DB add filegroup Test_DB_2016
go
alter database Test_DB add file (name = 'Test_DB_2013', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Test_DB_2013.ndf') to filegroup Test_DB_2013
alter database Test_DB add file (name = 'Test_DB_2014', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Test_DB_2014.ndf') to filegroup Test_DB_2014
alter database Test_DB add file (name = 'Test_DB_2015', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Test_DB_2015.ndf') to filegroup Test_DB_2015
alter database Test_DB add file (name = 'Test_DB_2016', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Test_DB_2016.ndf') to filegroup Test_DB_2016

use Test_DB 
--функция партиционирования
create partition function pfunc_date(datetime2(7)) 
as 
	range right for values ( '2014-01-01', '2015-01-01', '2016-01-01')
go
-- схема партиционирования
create partition scheme pshem_date
as 
	partition pfunc_date to (Test_DB_2013, Test_DB_2014, Test_DB_2015, Test_DB_2016)
go

--создам PK на схеме секционирования - добавим в индекс ключ секционирования
alter table test_partition add constraint pk_main_my primary key (TransactionOccurredWhen, StockItemTransactionID) on pshem_date(TransactionOccurredWhen)

-- как расположены данные
select $partition.pfunc_date(TransactionOccurredWhen) as section, min(TransactionOccurredWhen) as [min], max(TransactionOccurredWhen) as [max],
    count(*) as qty, fg.name as fg
from test_partition
join sys.partitions p on $partition.pfunc_date(TransactionOccurredWhen) = p.partition_number
join sys.destination_data_spaces dds on p.partition_number = dds.destination_id
join sys.filegroups fg on dds.data_space_id = fg.data_space_id
where p.object_id = object_id('test_partition') -- указываем имя таблицы
group by $partition.pfunc_date(TransactionOccurredWhen), fg.name
order by section

-- вся инфа по секционированию
select f.name
	, iif(f.boundary_value_on_right = 0, 'left', 'right') as LeftORRight
	, v.value
	, v.boundary_id
	, t.name 
from sys.partition_functions f
inner join  sys.partition_range_values v on f.function_id = v.function_id
inner join sys.partition_parameters p on f.function_id = p.function_id
inner join sys.types t on t.system_type_id = p.system_type_id
order by f.name, boundary_id

-- распределение по диапазонам: $partition.имя_функции_секционирования(ключ секционирования) 
select $partition.pfunc_date(TransactionOccurredWhen) as num_partition
	, count(*) as qty
	, min(TransactionOccurredWhen) as min_
	, max(TransactionOccurredWhen) as max_ 
from test_partition
group by $partition.pfunc_date(TransactionOccurredWhen)
order by 1
