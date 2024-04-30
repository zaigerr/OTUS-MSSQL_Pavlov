/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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
-- ---------------------------------------------------------------------------



/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/
/*--первый вариант с временной таблицей. Не самый удачный--*/
USE WideWorldImporters
TODO:
declare @columname nvarchar(max)
		,@dml nvarchar(max)

CREATE table ##temp  (cus_names nvarchar (30)
					,date_ date
					,month_ int
					)
INSERT INTO ##temp (cus_names,date_,month_)
(select	 SUBSTRING (b.CustomerName,(CHARINDEX('(',b.CustomerName))+1,(len(b.CustomerName)-CHARINDEX('(',b.CustomerName))-1) as names
		,DATEADD(mm, DATEDIFF(mm, 0, a.InvoiceDate), 0) as dat
		,month (a.InvoiceDate) as months
from Sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
)


select @columname = ISNULL(@columname+',','')+QUOTENAME(a.cus_names) from (
select	DISTINCT cus_names from ##temp
) a order by a.cus_names


set @dml = N' select date_ as InvoiceMonth,' +@columname+ '
			from ##temp as SourceTable pivot
(count (month_) 
for cus_names in('+@columname+')) as PivotTable 
order by PivotTable.date_'

EXEC sp_executesql @dml

DROP table ##temp;
/*-----второй вариант через CTE в строке-------*/

declare @cus_list nvarchar(max)
		,@dml1 nvarchar(max)

select @cus_list= ISNULL(@cus_list+',','')+QUOTENAME(b.CustomerName) 
		from Sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
group by b.CustomerName
order by b.CustomerName


set @dml1 = '
;with temp as (
select	b.CustomerName as names,
		DATEADD(mm, DATEDIFF(mm, 0, a.InvoiceDate), 0) as dat
		,month (a.InvoiceDate) as months
from Sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
)
select FORMAT(result.dat,''dd.MM.yyyy'')as InvoiceMonth,'+@cus_list+
'from temp as source 
pivot (count (months) for names in ('+@cus_list+' )) as result
order by result.dat'

EXEC (@dml1) --в отличие от 'EXEC sp_executesql' надо писать в скобках обязательно, иначе ошибку выдает невнятную

/*-----третий вариант Нашел STRING_AGG, попробовал через него и для разнообразия с подзапросовм----------*/

declare  @custlist nvarchar(max)
		,@command nvarchar(max)
select @custlist= STRING_AGG (CAST (QUOTENAME (b.CustomerName) as nvarchar(max)), ',') WITHIN GROUP (ORDER BY b.CustomerName) from Sales.Customers b

set @command = 'select FORMAT(result.dat,''dd.MM.yyyy'') as InvoiceMonth,'
+ @custlist +
'from (
select DATEADD(mm, DATEDIFF(mm, 0, a.InvoiceDate), 0) as dat
		,month (a.InvoiceDate) as months
		,b.CustomerName as names
from Sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
)as source
pivot (count (months) for names in ('
+@custlist+
' )) as result
order by result.dat'
EXEC sp_executesql @command
