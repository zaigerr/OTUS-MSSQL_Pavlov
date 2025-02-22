-- 6. �������� �������� ��������� ������������ ������ ��� �������� ������ ������
-- � ���� ����� ���� ��������� �������� ��������� "SendRequest", ������� ��������� ��� ���������: "CustomerID", "BeginDate" � "EndDate". 
-- ������ ��������� ����������� XML-������ �� ������ ���������� ����������, ������������ ������ ����� ����������� ("InitiatorService") 
-- � ����� ("TargetService") � ������� ��������� "//WWI/Report/Contract", � ������ ������������ � ������� ��� �������� ������.
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

			  --SELECT @RequestMessage AS SentRequestMessage;-- ��� �������

	  COMMIT TRAN
END
GO