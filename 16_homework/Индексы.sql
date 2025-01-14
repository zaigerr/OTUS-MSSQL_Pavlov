--������ �������� ����, ���� ��� ���� 
USE master; 
GO 
IF DB_ID (N'Test_DB') IS NOT NULL
begin
DECLARE @DatabaseName nvarchar(50)
SET @DatabaseName = N'TestDB'

DECLARE @SQL varchar(max)

SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
FROM MASTER..SysProcesses
WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId

EXEC(@SQL)
DROP DATABASE Test_DB;  
end
GO
--������ �������� ����
CREATE DATABASE Test_DB;
GO
USE Test_DB;

--��� ��� � ��� �� ����������� � �������� ������������. ���� ������� �������������� DWH
--�� �� ����� ����, ���� ������������ �������� ������� � ���������� � ��������� DWH

DROP TABLE IF EXISTS MyProducts
--������ �������� ������� 

CREATE TABLE MyProducts (
			ID int IDENTITY (1,1),
			Product_Name varchar (100),
			Price money,
			Category int
			)
--� �������� ������������ �������� NewID(), ����������� -����, ��������� �������� ����� ����� �� 20
DECLARE	@counter int =1
WHILE	@counter<=500000
BEGIN 
INSERT INTO MyProducts (Product_Name, Price, Category)
VALUES (NewID(), DATEPART (millisecond, GETDATE()), ROUND(RAND() * 20, 0) )
SET @counter+=1;
END

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT * FROM MyProducts
WHERE ID=100
--������ ������� �� ����� 33mb; ������� 8kb 
--HEAP --Table Scan
--ESC=3.66 --LR = 4202

--������ ���������� ������ �� ���� ID
CREATE CLUSTERED INDEX ID_PK ON MyProducts (ID)
SELECT * FROM MyProducts
WHERE ID=100
--������ ������� �� ����� 33mb
--CLUSTERED --Index SEEK
--ESC=0.003 --LR = 3; ������� 144kb

--��� ������ � ��������������� ���� ���������� ����� ����������
SELECT * FROM MyProducts
WHERE Product_Name = '468DE728-1884-452A-8DBF-959A745572A8'
--������ ������� �� ����� 33mb; ������� 144kb
--Clustered Index Scan
--ESC=3.66 --LR = 4181

--������ NonClusterd index �� ���� Product_Name
CREATE NONCLUSTERED INDEX IND1 ON MyProducts (Product_Name)
SELECT * FROM MyProducts
WHERE Product_Name = '468DE728-1884-452A-8DBF-959A745572A8'
--������ ������� �� ����� 33mb; ������� 25Mb (������ ���������� � ��������)
--Index SEEK + Index SEEK (��� ��� � ���� ������� ��� ���� Price, ���� ����� ���������� ������)
--ESC=0.006 --LR = 6

--����� � ��������������� ���� Price
SELECT * FROM MyProducts
WHERE Price=180
--������ ������� �� ����� 33mb; ������� 25Mb
--Clustered Index Scan
--ESC=3.64 --LR = 4181

-- ������� ������������, ��� ������� ��� ���� ������ �� ���� Price
CREATE NONCLUSTERED INDEX IND2 ON MyProducts (Price)
SELECT * FROM MyProducts
WHERE Price=180
--������ ������� �� ����� 33mb; ������� 34Mb
--Clustered Index Scan
--ESC=3.64 --LR = 4181

--�� ������ �� ���������� ������� �� �������� INDEX SCAN, sql server �� ���������� ��������� ������
--��� ��� ������ ����� ����������� �� ���������� ������� (����� ������� � ����� �����). 
--����� ������� ����� ������ � ����� ����� �� ������������� ������� Price, �� ������ 2000. 
--�� ����� ����� ������������ �� ����� �� ���������� INDEX SEEK �� ����������� ID, ����� �������� ��������� ����
--������� INDEX SCAN ����������������, �� ��� �� ����� ��������� ���� 

--������ �� ����� �����: ��� �������� ������������ �������� ����� ��������� ������������� ����� � �������
--��� ���� ������� ���������� �������� � ����, ��� ����������� ����� �������� ������. ����� ����� ��� ���������

--������ �������. ���������� INCLUDE, ����� ������������ ������� ���� ������� �� ���������������� ��������
--������ ������������ ������ � INCLUDE, ����� ��������� ������� �� ����� �������� �� ����������� �������

DROP INDEX IND2 ON MyProducts
CREATE NONCLUSTERED INDEX IND2 ON MyProducts (Price) INCLUDE (Product_Name, Category)
SELECT * FROM MyProducts
WHERE Price=180
--������ ������� �� ����� 33mb; ������� 57Mb
--Index SEEK �� ������� IND2
--ESC=0.017 --LR = 21

--������ �������� �� ������ �������, �� ���� ����� � 2 ���� ��������� �������. 
--��� ������� ������ � DWH � �������� �������� ��� ����� ���� ��������. 
--�������� ����� ���� ����� ������� ������ � 2 � ����� ��� 
--���� �� ������� ������� ����� ������������ ������� � ��������� �������� ������, ������� �� �� ����� �������� � �����

SELECT Avg(Price) FROM MyProducts
--ESC=3.79 --LR = 3991

--������ ���������� ������ �� ���� Price
CREATE NONCLUSTERED COLUMNSTORE INDEX ColInd1 ON MyProducts (Price)
SELECT Avg(Price) FROM MyProducts
--������ ������� �� ����� 33mb; ������� 57Mb - �� ����������, ��� ��� ���������� ������ �������� � ������ ����
--ColumnStore Index Scan
--ESC=0.065 --LR = 183

--������� ��������, ���� ��������� �� ��� ������� ������. 
--�� ������ ��� ���� ������������ ����� �� ����������
SELECT Category, Avg(Price) FROM MyProducts GROUP BY Category
-- Index Scan NonClustered IND2
--ESC=4.03 --LR = 3991
--��� ����� ���������� ������ �������� ��������. 

--�������, ��� ���� � ���� �������� ���� Category
DROP INDEX ColInd1 ON MyProducts --��� ������� ������������ ����� ���������� ������
CREATE NONCLUSTERED COLUMNSTORE INDEX ColInd2 ON MyProducts (Category, Price)

SELECT Category, Avg(Price) FROM MyProducts GROUP BY Category
--������ ������� �� ����� 33mb; ������� 57Mb - �� ����������
--ColumnStore Index Scan
--ESC=0.396 --LR = 393

-- ��� ����������� ������ ��� DWH 
SELECT Avg(Price) FROM MyProducts WHERE Category=1
--ColumnStore Index Scan
--ESC=0.086 --LR = 187

/*
������� �������� �������, �� ��������� �������� ������ � ���������
�������� ����� ��������� FillFactor ��� ��������, ����� �������� ���� ����� ������������ ��� ������� ����� ��������
� ����������� ������������ ���������������� ���������� ������, ����� �� �������� ������ ������� � ������������ ��������
���������� ������� ������ ��� �������������� ��������� �� ����.
�� ��� ������� ������� ������ ����� � 2 ���� ������ ����� �������. ��� �������������� ������� ��� ���������, 
� �� ������������ ������� ������� � ��������� �������� ������, ����� ��������� �� �����. 
��� ������� ���� ����������� ��������� ������� ������, ������� ������� �����-�� �����, 
�� ���� ���� ���������� ������ � ����� ������� ��������� ������� �� ������ �������
*/