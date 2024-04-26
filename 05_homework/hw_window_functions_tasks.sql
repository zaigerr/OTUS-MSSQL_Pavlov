/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
/*Запрос работает, но медленно, на моём компьтере выполняется за 2мин12сек
 SQL Server Execution Times: CPU time = 126593 ms,  elapsed time = 135652 ms.*/
set statistics time, io on
TODO:

;WITH RANGE_MONTH as (
select	 DATEDIFF(MONTH, '2015-01-01', a.InvoiceDate)as rang_month
		,sum (b.ExtendedPrice-b.TaxAmount) as sum_month -- ExtendedPrice-TaxAmount (сумма с налогом - налог) = UnitPrice*b.Quantity (цена*количество), ради разнообразия использовал другие столбцы для подсчета
from Sales.Invoices a
join Sales.InvoiceLines b on a.InvoiceID = b.InvoiceID
where a.InvoiceDate >= '2015-01-01'
group by DATEDIFF(MONTH, '2015-01-01', a.InvoiceDate)
)
, SUMM  as (
select	 a.InvoiceID as InvoiceID
		,c.CustomerName as CustomerName
		,a.InvoiceDate as InvoiceDate
		,(b.ExtendedPrice-b.TaxAmount) as Invoice_Sum
		,FORMAT(a.InvoiceDate, 'MMyy') as MMyy
		,DATEDIFF(MONTH, '2015-01-01', a.InvoiceDate) as rang_month
from Sales.Invoices a
join Sales.InvoiceLines b on a.InvoiceID = b.InvoiceID
join Sales.Customers c on a.CustomerID = c.CustomerID
where a.InvoiceDate >= '2015-01-01'
)
, result as (
select	 e.InvoiceID
		,e.InvoiceDate
		,e.CustomerName
		,e.Invoice_Sum
		,e.rang_month
		,f.sum_month
from SUMM e
join RANGE_MONTH f on e.rang_month=f.rang_month
)
select	 g.InvoiceID
		,g.InvoiceDate
		,g.CustomerName
		,g.Invoice_Sum
		,g.sum_month
		,(select sum (h.Invoice_Sum) from result h where h.rang_month<=g.rang_month) as [нарастающий итог]
from result g;
set statistics time, io off

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
/*SQL Server Execution Times: CPU time = 1250 ms,  elapsed time = 3391 ms.*/
set statistics time, io on
TODO:
select	 a.InvoiceID as InvoiceID
		,c.CustomerName as CustomerName
		,a.InvoiceDate as InvoiceDate
		,(b.ExtendedPrice-b.TaxAmount) as Invoice_Sum 
		--,FORMAT(a.InvoiceDate, 'yy-MM') as yyMM -- форматирую дату год-месяц. Это важно, так как при работе оконной фунции происходит сортировка сток, если задать месяц год, то нарастающий итог выйдет не по ходу времени
		,sum (b.UnitPrice*b.Quantity) OVER (PARTITION BY FORMAT(a.InvoiceDate, 'yy-MM')) as sum_month -- 1)задаю агрегатную функцию 2) открываю окно при помощи OVER 3) Задаю размер окна через PARTITION BY 4) Сортировку не задаю, так как мне нужно работать со всем набором строк окна
		,sum (b.UnitPrice*b.Quantity) OVER (order by  FORMAT(a.InvoiceDate, 'yy-MM')) as [нарастающий итог] -- 1)задаю агрегатную функцию 2) открываю окно при помощи OVER 3) Размер окна не указываю, работаю со всеми строками таблицы 4) задаю сортировку по полю, в этом случае считается нарастающий итог
		
from Sales.Invoices a
join Sales.InvoiceLines b on a.InvoiceID = b.InvoiceID
join Sales.Customers c on a.CustomerID = c.CustomerID
where a.InvoiceDate >= '2015-01-01'
order by a.InvoiceID
set statistics time, io off
/*--Наглядно и убедительно! Второй запрос в 40 раз быстрей! Использовать оконные функции буду :) --*/

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

TODO:
USE WideWorldImporters
;WITH SUMQUANT as (
select sum (b.Quantity) as summ
		,month(a.InvoiceDate) as month_
		,b.StockItemID 
from Sales.Invoices a
join Sales.InvoiceLines b on a.InvoiceID = b.InvoiceID

where (a.InvoiceDate between '2016-01-01' and '2016-12-31') --and b.StockItemID=211
group by month(a.InvoiceDate),b.StockItemID
)
,sortsum as (select	c.StockItemID 
		,c.summ 
		,c.month_
		,d.StockItemName
		,ROW_NUMBER () over (partition by month_ order by c.summ desc) as num
from SUMQUANT c
join Warehouse.StockItems d on c.StockItemID=d.StockItemID
)
select	 e.num 
		,e.StockItemName
		, case e.month_ when 1 then N'январь'
						when 2 then N'февраль'
						when 3 then N'март'
						when 4 then N'апрель'
						when 5 then N'май' end
		 from sortsum e where num <=2
order by e.month_, e.summ desc

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

TODO:
USE WideWorldImporters
select	 a.StockItemID
		,a.StockItemName
		,a.Brand 
		,a.UnitPrice
		,ROW_NUMBER() over (partition by left (a.StockItemName,1) order by a.StockItemID)
		,count (*) over () as TotalQuant
		,count (*) over (partition by left (a.StockItemName,1)) as firstsymbol_quant
		,LEAD (a.StockItemID) over (order by a.StockItemName) as [lead]
		,LAG (a.StockItemID,1,0) over (order by a.StockItemName) as [lag]
		,LAG (a.StockItemName,2,'No Items') over (order by a.StockItemName) as [lag2name]
		,a.TypicalWeightPerUnit
		,ntile (30) over (order by a.TypicalWeightPerUnit) -- очень странно разделила эта функция по группам, товар с одним весом распределила в разные группы. Возможно от большого количества заданных групп
		from Warehouse.StockItems a

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

/*--два запроса. А вывод разный. обратите внимание на SalespersonPersonID = 6 в одном выоде =1014, в другом =42
Сортировка по полю InvoiceDate не содержит часов и минут, в одну дату у одного менеджера может быть несколько "последних русских" © --*/
TODO:
USE WideWorldImporters
;With temp as (select	 a.SalespersonPersonID
		,c.FullName as sales_name
		,a.InvoiceID
		,a.CustomerID 
		,b.FullName as cus_name
		,a.InvoiceDate
		,sum (e.UnitPrice*e.Quantity) over (partition by e.InvoiceID) as inv_total
		--,LAST_VALUE (a.CustomerID) over (partition by a.SalespersonPersonID order by a.InvoiceDate) as last_
		,ROW_NUMBER () over (partition by a.SalespersonPersonID order by a.InvoiceDate desc) as num
		
		 from sales.Invoices a
join Application.People b on a.CustomerID=b.PersonID
join Application.People c on a.SalespersonPersonID=c.PersonID
join Sales.InvoiceLines e on e.InvoiceID=a.InvoiceID
)
select	d.SalespersonPersonID
		,d.sales_name
		,d.InvoiceID
		,d.CustomerID
		,d.cus_name
		,d.InvoiceDate
		,d.inv_total
		from temp d where d.num=1
order by d.SalespersonPersonID

select top 1 with ties 
		a.SalespersonPersonID
		,c.FullName as sales_name
		,a.InvoiceID
		,a.CustomerID 
		,b.FullName as cus_name
		,a.InvoiceDate
		,sum (e.UnitPrice*e.Quantity) over (partition by e.InvoiceID) as inv_total

		 from sales.Invoices a
join Application.People b on a.CustomerID=b.PersonID
join Application.People c on a.SalespersonPersonID=c.PersonID
join Sales.InvoiceLines e on e.InvoiceID=a.InvoiceID
order by ROW_NUMBER () over (partition by a.SalespersonPersonID order by a.InvoiceDate desc)

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиеyта, его название, ид товара, цена, дата покупки.
*/

TODO:
USE WideWorldImporters
; with temp as (
select	--top 3 with ties 
         a.CustomerID 
		,b.FullName as cus_name
		,a.InvoiceDate as date
		,d.StockItemID
		,d.UnitPrice
		,a.InvoiceDate
		,RANK() over (partition by a.CustomerID order by d.UnitPrice desc ) as rnk
		,ROW_NUMBER () over (partition by a.CustomerID order by d.UnitPrice desc ) as rnm
		,DENSE_RANK() over (partition by a.CustomerID order by d.UnitPrice desc ) as drnk

		 from sales.Invoices a
join Application.People b on a.CustomerID=b.PersonID
join Application.People c on a.SalespersonPersonID=c.PersonID
join Sales.InvoiceLines d on d.InvoiceID=a.InvoiceID)

select	e.CustomerID
		,e.cus_name
		,e.StockItemID
		,e.UnitPrice
		,e.InvoiceDate
from temp  e
where e.drnk<=2 and e.rnk=e.rnm
order by e.CustomerID

/*--использую следующую закономерность. (Номер строки) = (рангу строки) по одному полю всегда будет выдавать одно уникальное значение
Фильтрация по полю dense ранг отфильтрует только требуемое количество товаров из top2--*/

/*--Не укладываюсь по времени. Рассчитываю, что к опциональному заданию смогу вернуться позже--*/	


Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 