--ответ на первое ПОКА
CREATE PROCEDURE dbo.ConfirmInvoice
AS
BEGIN
	-- Получаем ответное сообщение от таргета.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	    --Получаем сообщение от таргета которое находится у инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorReportQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle WITH CLEANUP; --ЭТО второй ПОКА
		
		--SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --не для прода

	COMMIT TRAN; 
END