-- 5. Создание таблицы для хранения отчетов
-- В этой части кода создается таблица "ReportsResults"
-- с тремя столбцами: "id" (первичный ключ) и "xml_data" (XML-данные отчета) и датой ответа "date_report"
-- Эта таблица будет использоваться для хранения сформированных отчетов.
USE WideWorldImporters
CREATE TABLE ReportsResults	(
							id INT PRIMARY KEY IDENTITY(1,1)
							,xml_data XML NOT NULL
							,date_report datetime2
							);
