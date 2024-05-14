/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
 
/* Предварительно создам копию таблицы, чтобы можно было откатываться назад 
DROP TABLE IF EXISTS  Warehouse.StockItems_copy

SELECT * INTO Warehouse.StockItems_copy
FROM Warehouse.StockItems
----------------------------------------------------------------------
--Заготовка, для отката таблицы в исходное состояние через копию таблицы
 UPDATE Warehouse.StockItems SET 
		SupplierID=a.SupplierID
		,StockItemName=a.StockItemName
		,UnitPackageID=a.UnitPackageID
		,OuterPackageID=a.OuterPackageID
		,QuantityPerOuter=a.QuantityPerOuter
		,TypicalWeightPerUnit=a.TypicalWeightPerUnit
		,LeadTimeDays=a.LeadTimeDays
		,IsChillerStock=a.IsChillerStock
		,TaxRate=a.TaxRate
		,UnitPrice=a.UnitPrice
		,LastEditedBy=a.LastEditedBy
FROM Warehouse.StockItems b
join Warehouse.StockItems_copy a on a.StockItemID=b.StockItemID
where b.LastEditedBy=9

DELETE Warehouse.StockItems where LastEditedBy=8
*/
--Вариант через OPENXML

-- загружаю данные файла в sql 
 DECLARE @temp_xml XML;
 SET @temp_xml = (
 SELECT * FROM OPENROWSET
 (BULK 'C:\Users\PDA\Documents\OTUS-MSSQL_Pavlov\09_homework\StockItems.xml', SINGLE_BLOB) as StockItems
 )
 --SELECT @temp_xml --проверка, что загрузилось
 -- Делаю из строки XML таблицу через OPENXML
 DECLARE @XML_Doc_Handle INT;
 EXEC sp_xml_preparedocument @XML_Doc_Handle OUTPUT, @temp_xml;

MERGE Warehouse.StockItems as [target]
USING (
SELECT * FROM OPENXML (@XML_Doc_Handle,'/StockItems/Item',3 )
WITH	(SupplierID int
		,StockItemName nvarchar(100) '@Name'
		,UnitPackageID int '/StockItems/Item/Package/UnitPackageID'
		,OuterPackageID int '/StockItems/Item/Package/OuterPackageID'
		,QuantityPerOuter int '/StockItems/Item/Package/QuantityPerOuter'
		,TypicalWeightPerUnit decimal (18,3) '/StockItems/Item/Package/TypicalWeightPerUnit'
		,LeadTimeDays int
		,IsChillerStock bit
		,TaxRate decimal (18,3)
		,UnitPrice decimal (18,2)
		) 
		) as [source] 
		(SupplierID
		,StockItemName
		,UnitPackageID
		,OuterPackageID
		,QuantityPerOuter
		,TypicalWeightPerUnit
		,LeadTimeDays
		,IsChillerStock
		,TaxRate
		,UnitPrice) on ([target].StockItemName=[source].StockItemName)
WHEN matched THEN UPDATE SET 
		[target].SupplierID=[source].SupplierID
		,[target].StockItemName=[source].StockItemName
		,[target].UnitPackageID=[source].UnitPackageID
		,[target].OuterPackageID=[source].OuterPackageID
		,[target].QuantityPerOuter=[source].QuantityPerOuter
		,[target].TypicalWeightPerUnit=[source].TypicalWeightPerUnit
		,[target].LeadTimeDays=[source].LeadTimeDays
		,[target].IsChillerStock=[source].IsChillerStock
		,[target].TaxRate=[source].TaxRate
		,[target].UnitPrice=[source].UnitPrice
		,[target].LastEditedBy=9
WHEN not matched THEN INSERT (
		SupplierID
		,StockItemName
		,UnitPackageID
		,OuterPackageID
		,QuantityPerOuter
		,TypicalWeightPerUnit
		,LeadTimeDays
		,IsChillerStock
		,TaxRate
		,UnitPrice
		,LastEditedBy) 
VALUES (
		 [source].SupplierID
		,[source].StockItemName
		,[source].UnitPackageID
		,[source].OuterPackageID
		,[source].QuantityPerOuter
		,[source].TypicalWeightPerUnit
		,[source].LeadTimeDays
		,[source].IsChillerStock
		,[source].TaxRate
		,[source].UnitPrice
		,8)
OUTPUT $action, inserted.*, deleted.*;
 
EXEC sp_xml_removedocument @XML_Doc_Handle;

--------------------------------------------------
/*2 Вариант через Методы типа данных XML. Не уверен, что это XQuery
Мне казалось, что XQuery это свой язык программирования. А вот 
методы типа данных XML принимают на вход выражение XPath  или запрос XQuery.
Я не придумал, как тут использовать запросы XQuery, буду работать через XPath
*/
 DECLARE @temp_xml1 XML;
 SET @temp_xml1 = (
 SELECT * FROM OPENROWSET
 (BULK 'C:\Users\PDA\Documents\OTUS-MSSQL_Pavlov\09_homework\StockItems.xml', SINGLE_BLOB) as StockItems
 )
MERGE Warehouse.StockItems as [target]
USING (
SELECT	 a.Item.value ('SupplierID[1]', 'int') as SupplierID -- [1] в каждом узле ищем первое (одно) значение
		,a.Item.value ('@Name[1]','nvarchar(100)') as StockItemName
		,a.Item.value ('Package[1]/UnitPackageID[1]', 'int') as UnitPackageID
		,a.Item.value ('Package[1]/OuterPackageID[1]', 'int') as OuterPackageID
		,a.Item.value ('Package[1]/QuantityPerOuter[1]', 'int') as QuantityPerOuter
		,a.Item.value ('Package[1]/TypicalWeightPerUnit[1]', 'decimal(18,3)') as TypicalWeightPerUnit
		,a.Item.value ('LeadTimeDays[1]', 'int') as LeadTimeDays
		,a.Item.value ('IsChillerStock[1]', 'int') as IsChillerStock
		,a.Item.value ('TaxRate[1]', 'decimal(18,3)') as TaxRate
		,a.Item.value ('SupplierID[1]', 'decimal(18,2)') as SupplierID
FROM  @temp_xml1.nodes ('/StockItems/Item') a(Item)-- разбиваем по узлам Item
		) as [source] 
		(SupplierID
		,StockItemName
		,UnitPackageID
		,OuterPackageID
		,QuantityPerOuter
		,TypicalWeightPerUnit
		,LeadTimeDays
		,IsChillerStock
		,TaxRate
		,UnitPrice) on ([target].StockItemName=[source].StockItemName)
WHEN matched THEN UPDATE SET 
		[target].SupplierID=[source].SupplierID
		,[target].StockItemName=[source].StockItemName
		,[target].UnitPackageID=[source].UnitPackageID
		,[target].OuterPackageID=[source].OuterPackageID
		,[target].QuantityPerOuter=[source].QuantityPerOuter
		,[target].TypicalWeightPerUnit=[source].TypicalWeightPerUnit
		,[target].LeadTimeDays=[source].LeadTimeDays
		,[target].IsChillerStock=[source].IsChillerStock
		,[target].TaxRate=[source].TaxRate
		,[target].UnitPrice=[source].UnitPrice
		,[target].LastEditedBy=9
WHEN not matched THEN INSERT (
		SupplierID
		,StockItemName
		,UnitPackageID
		,OuterPackageID
		,QuantityPerOuter
		,TypicalWeightPerUnit
		,LeadTimeDays
		,IsChillerStock
		,TaxRate
		,UnitPrice
		,LastEditedBy) 
VALUES (
		 [source].SupplierID
		,[source].StockItemName
		,[source].UnitPackageID
		,[source].OuterPackageID
		,[source].QuantityPerOuter
		,[source].TypicalWeightPerUnit
		,[source].LeadTimeDays
		,[source].IsChillerStock
		,[source].TaxRate
		,[source].UnitPrice
		,8)
OUTPUT $action, inserted.*, deleted.*;
/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
---Просто XML из таблицы по заданию --------------------
SELECT 
StockItemName as [@Name],
SupplierID ,
UnitPackageID as [Package/UnitPackageID],
OuterPackageID as [Package/OuterPackageID],
QuantityPerOuter as [Package/QuantityPerOuter],
TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
LeadTimeDays,
IsChillerStock,
TaxRate,
UnitPrice
from Warehouse.StockItems as Item
FOR XML PATH ('Item'),TYPE, ELEMENTS, ROOT ('StockItems')
------------------------------------------------------------
/*---долго мучался но нашел, запрос должен быть одной строкой, ни каких табуляций и обязательно в кавычках---*/

EXEC master..xp_cmdshell 'bcp "USE WideWorldImporters; SELECT StockItemName as [@Name],SupplierID,UnitPackageID as [Package/UnitPackageID],OuterPackageID as [Package/OuterPackageID],QuantityPerOuter as [Package/QuantityPerOuter],TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],LeadTimeDays,IsChillerStock,TaxRate,UnitPrice from Warehouse.StockItems as Item FOR XML PATH (''Item''), ELEMENTS, ROOT (''StockItems'')" queryout "C:\Temp\BCP\test3.xml" -T -w -t;' 

--------Вот так еще, через создание таблицы. Кстати, xml из таблицы получается более удобно читаемой после форматирования--------------------------------------
declare @out1 nvarchar (256),
		@xml nvarchar (max)
SET @xml = (SELECT 
StockItemName as [@Name],
SupplierID ,
UnitPackageID as [Package/UnitPackageID],
OuterPackageID as [Package/OuterPackageID],
QuantityPerOuter as [Package/QuantityPerOuter],
TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
LeadTimeDays,
IsChillerStock,
TaxRate,
UnitPrice
from Warehouse.StockItems as Item
FOR XML PATH ('Item'), ELEMENTS, ROOT ('StockItems')
)

DROP table if exists temp
CREATE table temp (col_xml nvarchar(max))
insert into temp select @xml

set @out1 = 'bcp WideWorldImporters.dbo.temp out "C:\Temp\BCP\StockItems.xml" -T -S ' + @@SERVERNAME + ' -c';
--select @out1
PRINT @out1;
EXEC master..xp_cmdshell @out1
DROP table if exists temp


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
SELECT	 StockItemID
		,StockItemName
		,JSON_VALUE (CustomFields, '$.CountryOfManufacture' ) as Country
		,JSON_VALUE (CustomFields, '$.Tags[0]') as Tags
from Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT	 StockItemID
		,StockItemName
from Warehouse.StockItems 
cross APPLY OPENJSON(CustomFields, '$.Tags') as qw
where qw.value= 'Vintage'


--(опционально) все теги (из CustomFields) через запятую в одном поле

/*В целом запрос получился кривой. 
Работает только, если есть where. 
Если закомментарить where 'условие', то на строках, где было >2 значений тега и строк выводится столько же. 
Как в старом анекдоте: ложечки нашлись, осадочек остался © 
Не понимаю почему? Также еще пришлось использовать из-за оператора STRING_AGG  GROUP BY - тоже не понимаю почему?*/
SELECT	 StockItemID
		,StockItemName
		,STRING_AGG (qw1.value, ', ') as [str]
from Warehouse.StockItems 
cross APPLY OPENJSON(CustomFields, '$.Tags') as qw
cross APPLY OPENJSON(CustomFields, '$.Tags') as qw1
--where qw.value= 'Vintage'
GROUP BY StockItemID
		,StockItemName
ORDER BY StockItemID

/*Запрос с XML работает более правильно. Но сам метод, который через конструкцию FOR XML делает строку
для меня наполнен магией. Я его переписал с урока, но не понимаю, как оно работает
 */

SELECT	 StockItemID
		,StockItemName
		,(SELECT qw1.value + ',' AS 'data()' -- что здесь сделает 'data()' ? Что это? откуда, зачем и почему? Вроде и без нее работает
			FROM OPENJSON(CustomFields, '$.Tags') as qw1
			FOR XML PATH(''))  as [str] -- PATH('') пустой потому что у нас не XML? 
from Warehouse.StockItems 
cross APPLY OPENJSON(CustomFields, '$.Tags') as qw
where qw.value= 'Vintage'