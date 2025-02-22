-- 3. Создание контракта
-- В этой части кода создается контракт "//WWI/Report/Contract", который определяет типы сообщений, отправляемые и принимаемые в рамках контракта. 
-- Контракт указывает, что тип сообщения "//WWI/Report/RequestMessage" отправляется инициатором, а тип сообщения "//WWI/Report/ReplyMessage" отправляется целью.
USE WideWorldImporters
CREATE CONTRACT [//WWI/Report/Contract]
      ([//WWI/Report/RequestMessage] SENT BY INITIATOR,
       [//WWI/Report/ReplyMessage] SENT BY TARGET
      );