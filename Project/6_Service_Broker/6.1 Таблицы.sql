CREATE TABLE Web.NotificationEvents (
    EventId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RequestId INT NOT NULL REFERENCES Web.RequestHead(id),
    SenderId INT NOT NULL, -- ID пользователя (заказчика или исполнителя)
    EventType NVARCHAR(50), -- 'CustomerNotify', 'ExecutorNotify'
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    IsProcessed BIT DEFAULT 0
);
ALTER TABLE Web.NotificationEvents 
ADD CONSTRAINT CHK_EventType 
CHECK (EventType IN ('CustomerNotify', 'ExecutorNotify', 'SystemAlert'));
------------------------------------------------------------------------------
CREATE TABLE Web.ErrorLogs (
    LogId INT PRIMARY KEY IDENTITY(1,1),
    ErrorMessage NVARCHAR(2000) NOT NULL,
    EventData NVARCHAR(MAX), -- Сообщение, вызвавшее ошибку
    ErrorDate DATETIME2 DEFAULT GETDATE() -- Дата и время ошибки
   
);

CREATE TABLE Web.EmailTemplates (
    TemplateId INT PRIMARY KEY,
    EventType NVARCHAR(50) NOT NULL, -- Связь с типом события
    Subject NVARCHAR(255) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL
);
INSERT INTO Web.EmailTemplates (TemplateId, EventType, Subject, Body)
VALUES (
    1, 
    'CustomerNotify', 
    'Уведомление по заказу #{OrderId}', 
    'Добрый день! Требуется ваше внимание к заказу #{OrderId}.'
),(
    2, 
    'ExecutorNotify', 
    'Уведомление по заказу #{OrderId}', 
    'Добрый день! Выполнены работы по заказу #{OrderId}.'
);