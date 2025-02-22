-- 7. —оздание хранимой процедуры обработки очереди TargetReportQueueWWI (создани€ отчетов)
-- ¬ этой части кода создаетс€ хранима€ процедура "CreateReport", котора€ обрабатывает очередь "TargetReportQueueWWI" и создает отчеты на основе полученных данных из запроса. 
-- ѕроцедура извлекает сообщение из очереди, извлекает данные о клиенте, начальной и конечной дате из XML-сообщени€, создает отчет на основе этих данных и отправл€ет ответное сообщение в очередь.
USE WideWorldImporters
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateReport]
AS
BEGIN

	  DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
		  @Message NVARCHAR(4000),
		  @MessageType Sysname,
		  @ReplyMessage NVARCHAR(4000),
		  @CustomerID INT,
		  @BeginDate date,
		  @EndDate date,
		  @xml XML;

	  BEGIN TRAN;

		  RECEIVE TOP(1)
			@TargetDlgHandle = Conversation_Handle,--id дл€ ответа »нициатору в диалоге, создаетс€ при начале диалога и приходит вместе с запросом 
			@Message = Message_Body,
			@MessageType = Message_Type_Name
		  FROM dbo.TargetReportQueueWWI;

		  SELECT @Message; --дл€ отладки

		  SET @xml = CAST(@Message AS XML);

		  SELECT
			@CustomerID = R.Iv.value('@CustomerID','INT'),
			@BeginDate = R.Iv.value('@BeginDate','DATE'),
			@EndDate = R.Iv.value('@EndDate','DATE')
		  FROM @xml.nodes('/RequestMessage/Sales.Customers') as R(Iv);

		  Select 
		   @CustomerID as CustomerID,
			@BeginDate  as BeginDate,
		   @EndDate  as EndDate 


		  IF @MessageType=N'//WWI/Report/RequestMessage'
		  BEGIN


				SELECT @ReplyMessage = (SELECT
					CustomerID as CustomerID,
					count(*) as Count
				  FROM [WideWorldImporters].[Sales].[Orders]
				  Where
					CustomerID = @CustomerID
					AND OrderDate between @BeginDate AND @EndDate
				  Group By
					CustomerID
				  FOR XML AUTO, root('Report'));



				SEND ON CONVERSATION @TargetDlgHandle
				MESSAGE TYPE
				[//WWI/Report/ReplyMessage]
				(@ReplyMessage);
				END CONVERSATION @TargetDlgHandle WITH CLEANUP;

		  END

  				  -- «аписываю результат запроса (ответ)
			  INSERT INTO ReportsResults (xml_data, date_report)
			  VALUES (@ReplyMessage, GETDATE())

		 -- SELECT @ReplyMessage AS SentReplyMessage; -- дл€ отладки


	 COMMIT TRAN;

END