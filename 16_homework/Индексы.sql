--удаляю тестовую базу, если она есть 
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
--создаю тестовую базу
CREATE DATABASE Test_DB;
GO
USE Test_DB;

--Так как я еще не определился с проектом окончательно. Есть желание спроектировать DWH
--Но ДЗ сдать надо, буду использовать тестовую таблицу и рассуждать в контексте DWH

DROP TABLE IF EXISTS MyProducts
--создаю тестовую таблицу 

CREATE TABLE MyProducts (
			ID int IDENTITY (1,1),
			Product_Name varchar (100),
			Price money,
			Category int
			)
--в качестве наименования продукта NewID(), милисекунды -цена, категория случайны целые числа до 20
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
--Размер таблицы на диске 33mb; индексы 8kb 
--HEAP --Table Scan
--ESC=3.66 --LR = 4202

--создаю кластерный индекс по полю ID
CREATE CLUSTERED INDEX ID_PK ON MyProducts (ID)
SELECT * FROM MyProducts
WHERE ID=100
--Размер таблицы на диске 33mb
--CLUSTERED --Index SEEK
--ESC=0.003 --LR = 3; индексы 144kb

--При поиске в неиндексируемом поле результаты снова удручающие
SELECT * FROM MyProducts
WHERE Product_Name = '468DE728-1884-452A-8DBF-959A745572A8'
--Размер таблицы на диске 33mb; индексы 144kb
--Clustered Index Scan
--ESC=3.66 --LR = 4181

--Создаю NonClusterd index по полю Product_Name
CREATE NONCLUSTERED INDEX IND1 ON MyProducts (Product_Name)
SELECT * FROM MyProducts
WHERE Product_Name = '468DE728-1884-452A-8DBF-959A745572A8'
--Размер таблицы на диске 33mb; индексы 25Mb (размер сопоставим с таблицей)
--Index SEEK + Index SEEK (Так как в моем индексе нет поля Price, ищем через кластерный индекс)
--ESC=0.006 --LR = 6

--поиск в неиндексируемом поле Price
SELECT * FROM MyProducts
WHERE Price=180
--Размер таблицы на диске 33mb; индексы 25Mb
--Clustered Index Scan
--ESC=3.64 --LR = 4181

-- Логично предположить, что поможет еще один индекс по полю Price
CREATE NONCLUSTERED INDEX IND2 ON MyProducts (Price)
SELECT * FROM MyProducts
WHERE Price=180
--Размер таблицы на диске 33mb; индексы 34Mb
--Clustered Index Scan
--ESC=3.64 --LR = 4181

--Но ничего не изменилось остался по прежнему INDEX SCAN, sql server не использует созданный индекс
--Так как запрос низко селективный по статистике сервера (много товаров с одной ценой). 
--Можно быстрой найти товары с одной ценой по некласторному индексу Price, их больше 2000. 
--Но после этого понадобилось бы такое же количество INDEX SEEK по кластерному ID, чтобы получить остальные поля
--Поэтому INDEX SCAN предпочтительней, но это всё равно медленный путь 

--Исходя из этого вывод: при создании некластерных индексов нужно учитывать селективность полей в таблице
--Чем выше процент уникальных значений в поле, тем эффективней будет работать индекс. Будет смысл его создавать

--Другое решение. Используем INCLUDE, чтобы некластерные индексы были полезны на низкоселективных запросах
--Создам некластерный индекс с INCLUDE, чтобы выполнять запросы по полям отличным от кластерного индекса

DROP INDEX IND2 ON MyProducts
CREATE NONCLUSTERED INDEX IND2 ON MyProducts (Price) INCLUDE (Product_Name, Category)
SELECT * FROM MyProducts
WHERE Price=180
--Размер таблицы на диске 33mb; индексы 57Mb
--Index SEEK по индексу IND2
--ESC=0.017 --LR = 21

--Обращу ВНИМАНИЕ на размер индекса, он стал почти в 2 раза превышать таблицу. 
--Для таблицы фактов в DWH с огромным размером это может быть критично. 
--Например бекап базы может вырасти кратно в 2 и более раз 
--Одно из решений хранить такие некластерные индексы в отдельной файловой группе, которые мы не будем включать в бекап

SELECT Avg(Price) FROM MyProducts
--ESC=3.79 --LR = 3991

--Создам колоночный индекс по полю Price
CREATE NONCLUSTERED COLUMNSTORE INDEX ColInd1 ON MyProducts (Price)
SELECT Avg(Price) FROM MyProducts
--Размер таблицы на диске 33mb; индексы 57Mb - не изменилось, так как колоночный индекс хранится в сжатом виде
--ColumnStore Index Scan
--ESC=0.065 --LR = 183

--Отлично работает, если суммируем за всю историю продаж. 
--Но обычно все таки используется какая то фильтрация
SELECT Category, Avg(Price) FROM MyProducts GROUP BY Category
-- Index Scan NonClustered IND2
--ESC=4.03 --LR = 3991
--Как видим колоночный индекс перестал работать. 

--Логично, что надо в него добавить поле Category
DROP INDEX ColInd1 ON MyProducts --для чистоты эксперимента удалю предыдущий индекс
CREATE NONCLUSTERED COLUMNSTORE INDEX ColInd2 ON MyProducts (Category, Price)

SELECT Category, Avg(Price) FROM MyProducts GROUP BY Category
--Размер таблицы на диске 33mb; индексы 57Mb - не изменилось
--ColumnStore Index Scan
--ESC=0.396 --LR = 393

-- Еще характерный запрос для DWH 
SELECT Avg(Price) FROM MyProducts WHERE Category=1
--ColumnStore Index Scan
--ESC=0.086 --LR = 187

/*
Индексы ускоряют селекты, но замедляют загрузку данных в хранилище
Бороться можно подбирать FillFactor для индексов, чтобы страницы были более разреженными для вставки новых значений
И обязательно использовать автоинкрементный кластерный индекс, тогда не придется делать вставки в существующие страницы
Колоночные индексы хороши для арифметических подсчетов по полю.
На моём примере Индексы заняли объем в 2 раза больше самой таблицы. При проектировании сервера для хранилища, 
я бы рекомендовал хранить индексы в отдельной файловой группе, чтобы исключить их бекап. 
При подъеме базы пересоздать требуемые индексы задача, которая отнимет какое-то время, 
но сама база поднимется быстро и можно хранить несколько бекапов за разные периоды
*/