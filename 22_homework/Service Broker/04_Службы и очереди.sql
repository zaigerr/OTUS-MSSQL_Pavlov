-- 4. �������� �������� � �������� (������)
-- � ���� ����� ���� ��������� ��� �������: "TargetReportQueueWWI" � "InitiatorReportQueueWWI". 
-- ������ ������� ����������� � ��������������� ��������, ������� ���������� ��������� �������� "//WWI/Report/Contract".
-- ������ � Service Broker ��������� ������� � ����������, ��������� ������� ��� ������ ����������� ����� ����������� � �����
USE WideWorldImporters
-- ������ �������: 
CREATE QUEUE InitiatorReportQueueWWI;
-- ������ ��������� (���������� ������ ��������� � ������)
CREATE SERVICE [//WWI/Report/InitiatorService]
       ON QUEUE InitiatorReportQueueWWI
       ([//WWI/Report/Contract]);
GO

-- ������ �������:
CREATE QUEUE TargetReportQueueWWI;

-- �������� ��������� �� ������������� ������. ������������ ������� � ����� ���������� ������.
CREATE SERVICE [//WWI/Report/TargetService]
       ON QUEUE TargetReportQueueWWI
       ([//WWI/Report/Contract]);