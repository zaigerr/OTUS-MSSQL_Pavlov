-- 4. Создание очередей и сервисов (службы)
-- В этой части кода создаются две очереди: "TargetReportQueueWWI" и "InitiatorReportQueueWWI". 
-- Каждая очередь связывается с соответствующим сервисом, который использует созданный контракт "//WWI/Report/Contract".
-- Службы в Service Broker связывают очередь с контрактом, определяя правила для обмена сообщениями между инициатором и целью
USE WideWorldImporters
-- Первая очередь: 
CREATE QUEUE InitiatorReportQueueWWI;
-- Служба Инициатор (Отправляет первое сообщение в диалог)
CREATE SERVICE [//WWI/Report/InitiatorService]
       ON QUEUE InitiatorReportQueueWWI
       ([//WWI/Report/Contract]);
GO

-- Вторая очередь:
CREATE QUEUE TargetReportQueueWWI;

-- Получает сообщения от инициаторской службы. Обрабатывает запросы и может отправлять ответы.
CREATE SERVICE [//WWI/Report/TargetService]
       ON QUEUE TargetReportQueueWWI
       ([//WWI/Report/Contract]);