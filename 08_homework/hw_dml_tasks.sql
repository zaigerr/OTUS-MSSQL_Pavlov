/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

  insert into Purchasing.Suppliers (
       [SupplierName]
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryPostalCode]
      ,[PostalAddressLine1]
      ,[PostalPostalCode]
      ,[LastEditedBy]				) 
	  VALUES
  ('Remas',2 ,21 ,22 ,7 ,38171 ,38171 ,1 ,'(3412)222-333' ,'(3412)333-222' ,'www.remas.ru' ,'Suite 10' ,'94101' ,'PO Box 1012' ,'98253' ,1),
  (N'Газпром',2 ,21 ,22 ,7 ,38171 ,38171 ,1 ,'(495)222-333' ,'(495)333-222' ,N'www.газпром.ru' ,'Suite 10' ,'94101' ,'PO Box 1112' ,'98253' ,1),
  ('yandex',2 ,21 ,22 ,7 ,38171 ,38171 ,1 ,'01' ,'02' ,'www.yandex.ru' ,'Suite 10' ,'94101' ,'PO Box 1012' ,'98253' ,1),
  (N'ООО "Озеро"',2 ,21 ,22 ,7 ,38171 ,38171 ,1 ,'03' ,'03' ,'www.kreml.ru' ,'Suite 10' ,'94101' ,'PO Box 1112' ,'98253' ,1),
  (N'Альфа',2 ,21 ,22 ,7 ,38171 ,38171 ,1 ,'(495)55-555' ,'(495)66-77' ,N'www.ufpghjv.ru' ,'Suite 10' ,'94101' ,'PO Box 1112' ,'98253' ,1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/
;with temp as (
select top 1 * from Purchasing.Suppliers a order by a.SupplierID desc)
delete from temp


/*
3. Изменить одну запись, из добавленных через UPDATE
*/
;with temp as (
select top 1 * from Purchasing.Suppliers a order by a.ValidFrom desc)
Update temp 
set SupplierName = 'Remas'

Update Purchasing.Suppliers 
set WebsiteURL = 'www.remas.ru' where SupplierName = 'Remas'



/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
/*Подготавливаю таблицу Target*/
DROP TABLE if exists Purchasing.Suppliers_copy;

select *
into Purchasing.Suppliers_copy 
from Purchasing.Suppliers 

;with temp as (
select top 1 * from Purchasing.Suppliers_copy a order by a.SupplierID desc)
delete from temp

update Purchasing.Suppliers_copy set [FaxNumber]='' where SupplierName='Remas'

/*Работаю с Merge*/
MERGE Purchasing.Suppliers_copy as [target]
USING Purchasing.Suppliers as [source]
on [target].SupplierID=[source].SupplierID
when matched  and [source].SupplierName = 'Remas' then
UPDATE set FaxNumber = [source].FaxNumber
when not matched then insert values
([SupplierID]
      ,[SupplierName]
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[SupplierReference]
      ,[BankAccountName]
      ,[BankAccountBranch]
      ,[BankAccountCode]
      ,[BankAccountNumber]
      ,[BankInternationalCode]
      ,[PaymentDays]
      ,[InternalComments]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      ,[ValidFrom]
      ,[ValidTo])
	  OUTPUT $action, inserted.[SupplierName],inserted.[FaxNumber]--, deleted.*
;
/*любопытный  оператор, не знаю пригодится ли он мне, но буду знать, что есть такое*/

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bcp in
*/
/*--bcp вещь сама в себе. Использовать для экспорта сторонних файлов фактически не выполнимо. Ради интереса скопировал в excel результаты запроса, сохранил как txt. 
Внутри файл выглядел, как экспортированный из базы (я даже строку оставил одну и проверил вплоть до спецсимволов строку с выгруженной строкой из базы), 
но через утилиту не экспортируется, разные ошибки выдает--*/

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO 

EXEC master ..xp_cmdshell 'DIR C:\Temp\BCP\' --проверяю права доступа sql к папке

declare @out nvarchar (256)
set @out = 'bcp WideWorldImporters.Purchasing.Suppliers out "C:\Temp\BCP\test.csv" -T -S ' + @@SERVERNAME + ' -c';
PRINT @out;
EXEC master..xp_cmdshell @out

drop table  if exists Purchasing.Suppliers_copy

select *
into Purchasing.Suppliers_copy 
from Purchasing.Suppliers where 1=2

declare @in nvarchar (256)
set @in='bcp WideWorldImporters.Purchasing.Suppliers_copy IN "C:\Temp\BCP\test.csv" -T -S ' + @@SERVERNAME + ' -c';

EXEC master..xp_cmdshell @in;

/*-------- я все-таки нашел для себя как загрузить данные из csv в таблицу базы---------------*/


exec master..xp_cmdshell 'bcp WideWorldImporters.Purchasing.Suppliers out "C:\Temp\BCP\test.txt" -T -w -t;' -- почти все тоже самое, что выше. Но задаю разделитель ';' удобно для csv

/*В отличие от bcp прекрасно работает на загрузку из файла в таблицу*/

BULK INSERT Purchasing.Suppliers_copy
				FROM "C:\Temp\BCP\test-out.csv" --файл создал в эксель 
				WITH 
					(
					BATCHSIZE = 1000, 
					DATAFILETYPE = 'char', --'widechar' для unicode
					FIELDTERMINATOR = ';',
					ROWTERMINATOR ='\n',
					KEEPNULLS,
					TABLOCK        
					);