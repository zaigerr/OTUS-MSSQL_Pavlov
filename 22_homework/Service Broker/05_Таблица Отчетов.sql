-- 5. �������� ������� ��� �������� �������
-- � ���� ����� ���� ��������� ������� "ReportsResults"
-- � ����� ���������: "id" (��������� ����) � "xml_data" (XML-������ ������) � ����� ������ "date_report"
-- ��� ������� ����� �������������� ��� �������� �������������� �������.
USE WideWorldImporters
CREATE TABLE ReportsResults	(
							id INT PRIMARY KEY IDENTITY(1,1)
							,xml_data XML NOT NULL
							,date_report datetime2
							);
