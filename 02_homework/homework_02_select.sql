/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
use WideWorldImporters
select a.StockItemID, a.StockItemName
from Warehouse.StockItems a
where a.StockItemName like '%urgent%' or a.StockItemName like'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
select a.SupplierID, a.SupplierName
from Purchasing.Suppliers a
left join Purchasing.PurchaseOrders b on a.SupplierID=b.SupplierID where  b.PurchaseOrderID is NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select	 a.OrderID
		,format (a.OrderDate,'dd-MM-yyyy') as [Дата заказа]
		,format (a.OrderDate,'MMMM', 'ru-ru') as [месяц]
		,datepart(quarter, a.OrderDate) as [Квартал]
		,CEILING (month(a.OrderDate)/4.0)  as [треть года] --оказывается, если 1 разделить на целое число, то SQL выдаст целое число = 0. Чтобы получить дробное, надо делить на дробное 1/4.0=0.25 --Важно для CEILING
		,b.CustomerName as [имя заказчика]
from		  Sales.Orders a
		 join Sales.Customers b on a.CustomerID=b.CustomerID
	left join Sales.OrderLines c on a.OrderID=c.OrderID
where (c.UnitPrice>100 or c.Quantity>20) and c.PickingCompletedWhen is not null
order by [Квартал], [треть года], [Дата заказа]

/*--вариант этого запроса с постраничной выборкой--*/

DECLARE @pagesize BIGINT = 100, -- Размер страницы
		@pagenum BIGINT = 1000; -- Номер страницы
select	 a.OrderID
		,format (a.OrderDate,'dd-MM-yyyy') as [Дата заказа]
		,format (a.OrderDate,'MMMM', 'ru-ru') as [месяц]
		,datepart(quarter, a.OrderDate) as [Квартал]
		,CEILING (month(a.OrderDate)/4.0)  as [треть года] 
		,b.CustomerName as [имя заказчика]
from		  Sales.Orders a
		 join Sales.Customers b on a.CustomerID=b.CustomerID
	left join Sales.OrderLines c on a.OrderID=c.OrderID
where (c.UnitPrice>100 or c.Quantity>20) and c.PickingCompletedWhen is not null
order by [Квартал], [треть года], [Дата заказа]
OFFSET @pagenum ROWS FETCH NEXT @pagesize ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select	 c.DeliveryMethodName
		,a.ExpectedDeliveryDate
		,b.SupplierName,d.FullName as [основное контактн лицо получателя]
		,e.FullName as [основное контакт лицо поставщика] --в задании это поле не требуется, но стало любопытно контактное лицо поставщика
from Purchasing.PurchaseOrders a
join Purchasing.Suppliers b on a.SupplierID=b.SupplierID
join Application.DeliveryMethods c on c.DeliveryMethodID=a.DeliveryMethodID
join Application.People d on d.PersonID=a.ContactPersonID
join Application.People e on e.PersonID=b.PrimaryContactPersonID
where		a.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31' 
		and (c.DeliveryMethodName like 'Air Freight' or c.DeliveryMethodName like 'Refrigerated Air Freight')
		and a.IsOrderFinalized !=0

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
select top 10 a.OrderDate as [дата заказа]
			, c.FullName as [имя клиента]
			, b.FullName as [имя сотрудника]
			from Sales.Orders a
join Application.People b on a.SalespersonPersonID=b.PersonID
join Application.People c on a.ContactPersonID=c.PersonID
order by a.OrderDate desc


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select DISTINCT (d.PersonID)
				,d.FullName
				,d.PhoneNumber
from Warehouse.StockItems a
join Sales.OrderLines b on a.StockItemID=b.StockItemID
join Sales.Orders c on c.OrderID=b.OrderID
join Application.People d on c.ContactPersonID=d.PersonID
where a.StockItemName like '%Chocolate frogs 250g%'
order by d.FullName
