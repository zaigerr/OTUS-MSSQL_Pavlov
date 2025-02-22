USE WideWorldImporters
EXEC dbo.SendRequest 12, '2013-01-01', '2014-01-01'

--��������� � �������
SELECT CAST(message_body AS XML),*
FROM dbo.TargetReportQueueWWI;

--������(�������� ���������)=������� ��������� ������������� ���������
EXEC dbo.CreateReport

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorReportQueueWWI;

EXEC ConfirmInvoice

--������ ��������
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --������������� ��������(���������� ���������) ����� �� �� ����������� - --������ ��������� ������ �� �������� ������� ���������
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;

exec [dbo].[CleanupClosedConversations]