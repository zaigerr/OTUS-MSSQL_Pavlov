-- 2. Создание типов сообщений
-- В этой части кода создаются два типа сообщений: "//WWI/Report/RequestMessage" и "//WWI/Report/ReplyMessage". 
-- Каждый тип сообщения имеет валидацию в формате WELL_FORMED_XML.
USE WideWorldImporters
-- Для запроса
CREATE MESSAGE TYPE
[//WWI/Report/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- Для ответа
CREATE MESSAGE TYPE
[//WWI/Report/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 