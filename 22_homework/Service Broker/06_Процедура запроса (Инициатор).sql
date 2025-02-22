-- 6. Создание хранимой процедуры формирования заявки для создания нового отчета
-- В этой части кода создается хранимая процедура "SendRequest", которая принимает три параметра: "CustomerID", "BeginDate" и "EndDate". 
-- Внутри процедуры формируется XML-запрос на основе переданных параметров, инициируется диалог между инициатором ("InitiatorService") 
-- и целью ("TargetService") с помощью контракта "//WWI/Report/Contract", и запрос отправляется в очередь для создания отчета.
USE WideWorldImporters
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SendRequest
  @CustomerID INT,
  @BeginDate date,
  @EndDate date
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @dialog_handle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);

	  BEGIN TRAN

			  SELECT @RequestMessage = (SELECT  @CustomerID as CustomerID, @BeginDate  as BeginDate, @EndDate as EndDate 
										FROM [Sales].[Customers] 
										WHERE CustomerID= @CustomerID 
										FOR XML AUTO, root('RequestMessage')
										);
			  BEGIN DIALOG @dialog_handle
			  FROM SERVICE
			  [//WWI/Report/InitiatorService]
			  TO SERVICE
			  '//WWI/Report/TargetService'
			  ON CONTRACT
			  [//WWI/Report/Contract]
			  WITH ENCRYPTION=OFF, LIFETIME = 60;

			  SEND ON CONVERSATION @dialog_handle 
			  MESSAGE TYPE
			  [//WWI/Report/RequestMessage]
			  (@RequestMessage);

			  --SELECT @RequestMessage AS SentRequestMessage;-- для отладки

	  COMMIT TRAN
END
GO