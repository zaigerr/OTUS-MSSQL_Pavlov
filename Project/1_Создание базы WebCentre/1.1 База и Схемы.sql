USE master; 
GO 
IF DB_ID (N'WebCentre') IS NOT NULL
begin
DECLARE @DatabaseName nvarchar(50)
SET @DatabaseName = N'WebCentre'

DECLARE @SQL varchar(max)

SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
FROM MASTER..SysProcesses
WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId

EXEC(@SQL)
DROP DATABASE WebCentre;  
end


CREATE DATABASE WebCentre;
GO	
Use WebCentre;
GO
CREATE SCHEMA [Web];
GO
CREATE SCHEMA [Application];
GO

/*--��� BSJobs--*/
-- ��� 1: �������� �������������� ������� (���� ��� ���)
CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;

-- ��� 2: �������, ��� ������� ����� ���������������� ������
-- (������: ���� ���������������� ������ �� ������)
--CREATE CLUSTERED INDEX PK_BSProduct ON [BSJobs].[admin].[BSProduct] (Id);

-- ��� 3: ������ �������������� ������
CREATE FULLTEXT INDEX ON [BSJobs].[admin].[BSProduct] 
(
    Descr -- ��������� �������
    , Prodid -- ��������� ������� (��������, NVARCHAR)
) 
KEY INDEX PK__BSProduc__Id -- ��� ����������������� �������
ON ftCatalog; -- ��� ��������