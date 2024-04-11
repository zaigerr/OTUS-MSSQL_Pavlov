/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

  SELECT year (a.InvoiceDate) as [год]
		,month (a.InvoiceDate) as [месяц]
		,avg(b.UnitPrice) as [средняя цена]
		,sum(b.UnitPrice*b.Quantity) as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by year (a.InvoiceDate), month (a.InvoiceDate)
  order by [год],[месяц]

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

 SELECT year (a.InvoiceDate) as [год]
		,month (a.InvoiceDate) as [месяц]
		,sum(b.UnitPrice*b.Quantity) as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by year (a.InvoiceDate), month (a.InvoiceDate)
  having sum(b.UnitPrice*b.Quantity)>4600000
  order by [год],[месяц]

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

 SELECT year (a.InvoiceDate) as [год]
		,month (a.InvoiceDate) as [месяц]
		,c.StockItemName
		,sum(b.UnitPrice*b.Quantity) as [сумма]
		,min(a.InvoiceDate) as [дата первой продажи]
		,sum(b.Quantity) as [Количество проданного]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  join Warehouse.StockItems c on b.StockItemID=c.StockItemID
  group by year (a.InvoiceDate), month (a.InvoiceDate), c.StockItemName
  having sum(b.Quantity)<50
  order by [год],[месяц]
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
 SELECT year (a.InvoiceDate) as [год]
		,month (a.InvoiceDate) as [месяц]
		,CASE WHEN sum(b.UnitPrice*b.Quantity)>4600000  THEN sum(b.UnitPrice*b.Quantity) ELSE 0 end  as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by year (a.InvoiceDate), month (a.InvoiceDate)
  order by [год],[месяц]

/*--------третье задание---------------------------------------*/

   SELECT year (a.InvoiceDate) as [год]
		,FORMAT (a.InvoiceDate,'MMMM', 'ru-ru') as [месяц]
		,c.StockItemName
		,sum(b.UnitPrice*b.Quantity) as [сумма]
		,FORMAT (min(a.InvoiceDate), 'dd.MM.yyyy') as [дата первой продажи]
		,CASE WHEN sum(b.Quantity)<50 THEN sum(b.Quantity) ELSE 0 end as [Количество проданного <50]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  join Warehouse.StockItems c on b.StockItemID=c.StockItemID
  group by year (a.InvoiceDate), FORMAT (a.InvoiceDate,'MMMM', 'ru-ru'), c.StockItemName
  order by [год],[месяц]

/*--вариация третьего задания (так смотрится эстетичней)--*/
    SELECT year (a.InvoiceDate) as [год]
		,FORMAT (a.InvoiceDate,'MMMM', 'ru-ru') as [месяц]
		,CASE WHEN sum(b.Quantity)<50 THEN c.StockItemName ELSE '' end as [наименование товара]
		,CASE WHEN sum(b.Quantity)<50 THEN sum(b.UnitPrice*b.Quantity) ELSE 0 end as [сумма]
		,CASE WHEN sum(b.Quantity)<50 THEN FORMAT (min(a.InvoiceDate), 'dd.MM.yyyy') ELSE '' end as [дата первой продажи]
		,CASE WHEN sum(b.Quantity)<50 THEN sum(b.Quantity) ELSE 0 end as [Количество проданного <50]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  join Warehouse.StockItems c on b.StockItemID=c.StockItemID
  group by year (a.InvoiceDate), FORMAT (a.InvoiceDate,'MMMM', 'ru-ru'), c.StockItemName
  order by [Количество проданного <50] desc, [год],[месяц]
--------------------------------------------------------------------------------------------
  /*Придумал сам себе задание для ROLLUP. Есть вопросы в последнем запросе...*/

    /*--ROLLUP вывод без переименования--*/
  SELECT year (a.InvoiceDate) as [год]
		,month (a.InvoiceDate) as [месяц]
		,sum(b.UnitPrice*b.Quantity) as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by rollup (year (a.InvoiceDate), month (a.InvoiceDate))
  having sum(b.UnitPrice*b.Quantity)>4600000
  order by [год],[месяц]


  /*--ROLLUP вывод с переименования--*/
 SELECT ISNULL (cast (year (a.InvoiceDate) as nvarchar (64)), case when grouping (year (a.InvoiceDate))=1 and grouping (month (a.InvoiceDate))=1 then 'all years' else '' end ) as [год]
		,ISNULL (cast (month (a.InvoiceDate) as nvarchar (64)), case when grouping (year (a.InvoiceDate))=1 and grouping (month (a.InvoiceDate))=1 then 'all month' else 'subtotals' end ) as [месяц]
  		,sum(b.UnitPrice*b.Quantity) as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by rollup (year (a.InvoiceDate), month (a.InvoiceDate))
 -- having sum(b.UnitPrice*b.Quantity)>4600000


   /*--ROLLUP вывод с переименования по русски--*/ --Так и не получается! На выводе знаки вопроса. Как исправить?
 SELECT ISNULL (cast (year (a.InvoiceDate) as nvarchar (64)), case when grouping (year (a.InvoiceDate))=1 and grouping (month (a.InvoiceDate))=1 then 'все года' else '' end ) as [год]
		,ISNULL (cast (month (a.InvoiceDate) as nvarchar (64)), case when grouping (year (a.InvoiceDate))=1 and grouping (month (a.InvoiceDate))=1 then 'все месяцы' else 'промежуточные итоги' end ) as [месяц]
  		,sum(b.UnitPrice*b.Quantity) as [сумма]
  FROM Sales.Invoices a
  join Sales.InvoiceLines b on a.InvoiceID=b.InvoiceID
  group by rollup (year (a.InvoiceDate), month (a.InvoiceDate))
 -- having sum(b.UnitPrice*b.Quantity)>4600000

  --collate Cyrillic_General_CI_AS
  --collate Cyrillic_General_BIN