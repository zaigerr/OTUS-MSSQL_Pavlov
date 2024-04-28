/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

TODO:
;with temp as (
select	 SUBSTRING (b.CustomerName,(CHARINDEX('(',b.CustomerName))+1,(len(b.CustomerName)-CHARINDEX('(',b.CustomerName))-1) as names
		,DATEADD(mm, DATEDIFF(mm, 0, a.InvoiceDate), 0) as dat
		,month (a.InvoiceDate) as months
from Sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
where a.CustomerID between 2 and 6
)
select	FORMAT(dat,'dd.MM.yyyy') as InvoiceMonth --задаю первое (главное) поле будущего пивота, выбираю наменование столбца
		,[Sylvanite, MT]						--перечисляю заголовки столбцов будущего пивота
		,[Peeples Valley, AZ]
		,[Medicine Lodge, KS]
		,[Gasport, NY]
		,[Jessie, ND]
from 
(select a.months, a.dat,a.names from temp a) --выбираю данные из таблицы
as SourceTable
pivot
(
count (months) --агрегатная функция (основное наполнение таблицы)
for names -- указываю поле для которого считал агрегат
in([Sylvanite, MT],[Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Jessie, ND]) --перечисляю столбцы куда буду вставлять значение агрегата
)
as PivotTable
order by PivotTable.dat
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

WITH CTE AS (
	SELECT CustomerName, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
	FROM Sales.Customers
	WHERE CustomerName LIKE 'Tailspin Toys%'
	)
select CustomerName, AddressLine --указываю будущие колонки для таблицы 
from CTE 
--указываю из каких полей буду собирать 1 поле 
unpivot (AddressLine for Address_ in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2) ) as result

--стало любопытно, возможно ли создать несколько столбцов через unpivot. Можно :) 
WITH CTE AS (
	SELECT CustomerName, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
	FROM Sales.Customers
	WHERE CustomerName LIKE 'Tailspin Toys%'
	)
select CustomerName, AddressLine,AddressLine2 --указываю будущие колонки для таблицы 
from CTE 
unpivot (AddressLine for [адрес] in (PostalAddressLine1,PostalAddressLine2) ) as result
unpivot (AddressLine2 for [ещеадрес] in (DeliveryAddressLine1,DeliveryAddressLine2) ) as result1

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

/*--из занятия не сразу уловил, 1)что unpivot пишется для столбца перед for, 2) после for можно писать любой наборсимволов 3) в in пишем стоблцы для unpivot 4) аллиас в конце обязателен--*/
Select CountryId, CountryName, Code from
(select a.CountryID as CountryId, a.CountryName, a.IsoAlpha3Code, CONVERT(NVARCHAR(3), a.IsoNumericCode) as IsoNumericCode from Application.Countries a) b
unpivot (Code for [пишемвсякахрень] in (IsoAlpha3Code,IsoNumericCode)) as [аллиас_тут_обязателен]

;with cte as(
select a.CountryID as CountryId, a.CountryName, a.IsoAlpha3Code, CONVERT(NVARCHAR(3), a.IsoNumericCode) as IsoNumericCode from Application.Countries a
)
Select CountryId, CountryName, Code from cte 
unpivot (Code for temp in (IsoAlpha3Code,IsoNumericCode)) as result --аллиас обязателен


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

TODO:
USE WideWorldImporters
; with temp as (
select	 a.CustomerID 
		,b.CustomerName as cus_name
		,a.InvoiceDate as date
		,d.StockItemID
		,d.UnitPrice
		,a.InvoiceDate
		,RANK() over (partition by a.CustomerID order by d.UnitPrice desc ) as rnk
		,ROW_NUMBER () over (partition by a.CustomerID order by d.UnitPrice desc ) as rnm
		,DENSE_RANK() over (partition by a.CustomerID order by d.UnitPrice desc ) as drnk

		 from sales.Invoices a
join Sales.Customers b on a.CustomerID=b.CustomerID
join Sales.InvoiceLines d on d.InvoiceID=a.InvoiceID)

select	e.CustomerID
		,e.cus_name
		,e.StockItemID
		,e.UnitPrice
		,e.InvoiceDate
from temp  e
where e.drnk<=2 and e.rnk=e.rnm
order by e.CustomerID

----------------------------------------------------------
/*--очень замороченный и плохо читаемый запрос. Для меня было очень не просто его написать, коррелирующие подзапросы моё слабое место. 
В реальной жизни - не стал бы использовать :) Через оконные функции проще--*/
;with temp as(
select	 b.CustomerID
		,b.InvoiceDate
		,a.UnitPrice
		,a.StockItemID
		from Sales.InvoiceLines a
join Sales.Invoices b on a.InvoiceID=b.InvoiceID)

select   tab4.CustomerID
		,tab4.CustomerName
		,result.invdate
		,result.UnitPriceMAX
from Sales.Customers tab4
cross apply (
select	top 2
		 (select min (tab3.InvoiceDate) from temp tab3 where tab3.StockItemID=tab2.StockItemID and tab3.UnitPrice=tab2.UnitPriceMAX and tab3.CustomerID=tab4.CustomerID ) as invdate
		,tab2.StockItemID
		,tab2.UnitPriceMAX
		,tab4.CustomerID
from (select max (tab1.UnitPrice) as UnitPriceMAX, tab1.StockItemID from temp tab1 where tab1.CustomerID=tab4.CustomerID group by tab1.StockItemID ) tab2
order by tab2.UnitPriceMAX desc
			) as result