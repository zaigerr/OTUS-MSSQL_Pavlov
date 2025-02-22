-- 1. ��������� ������� ��������� ��� ���� ������ "WideWorldImporters". 
-- ������� ��������������� ������������ ����� ����������� � ���� ������ � ���������� ��� �������� ����������. 
-- ����� ���������� ������ ���������, � � ����� ��������������� ��������������������� ����� �����������.
USE WideWorldImporters
ALTER DATABASE [WideWorldImporters] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [WideWorldImporters] SET ENABLE_BROKER
ALTER DATABASE [WideWorldImporters] SET MULTI_USER

--�� ������ ��������������� �� ����� ����������� ������!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--�������� ��� ����� �������� �������� ��� ������������� ������������ ����� �������� ����� ���������� 
--�� � ����������(���������� ������� �������, ��� ���� �� ����� ��������)
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;