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

/*--Для BSJobs--*/
-- Шаг 1: Создайте полнотекстовый каталог (если его нет)
CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;

-- Шаг 2: Убедись, что таблица имеет кластеризованный индекс
-- (Пример: если кластеризованный индекс не создан)
--CREATE CLUSTERED INDEX PK_BSProduct ON [BSJobs].[admin].[BSProduct] (Id);

-- Шаг 3: Создай полнотекстовый индекс
CREATE FULLTEXT INDEX ON [BSJobs].[admin].[BSProduct] 
(
    Descr -- Текстовый столбец
    , Prodid -- Текстовый столбец (например, NVARCHAR)
) 
KEY INDEX PK__BSProduc__Id -- Имя кластеризованного индекса
ON ftCatalog; -- Имя каталога