--����� �� ������ ����
CREATE PROCEDURE dbo.ConfirmInvoice
AS
BEGIN
	-- �������� �������� ��������� �� �������.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	    --�������� ��������� �� ������� ������� ��������� � ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorReportQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle WITH CLEANUP; --��� ������ ����
		
		--SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --�� ��� �����

	COMMIT TRAN; 
END