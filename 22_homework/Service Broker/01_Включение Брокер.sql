-- 1. Включение брокера сообщений для базы данных "WideWorldImporters". 
-- Сначала устанавливается односеансный режим подключения к базе данных и отменяются все активные транзакции. 
-- Затем включается брокер сообщений, и в конце устанавливается многопользовательский режим подключения.
USE WideWorldImporters
ALTER DATABASE [WideWorldImporters] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [WideWorldImporters] SET ENABLE_BROKER
ALTER DATABASE [WideWorldImporters] SET MULTI_USER

--БД должна функционировать от имени технической учетки!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--Включите это чтобы доверять сервисам без использования сертификатов когда работаем между различными 
--БД и инстансами(фактически говорим серверу, что этой БД можно доверять)
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;