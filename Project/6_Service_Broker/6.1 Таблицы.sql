CREATE TABLE Web.NotificationEvents (
    EventId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RequestId INT NOT NULL REFERENCES Web.RequestHead(id),
    SenderId INT NOT NULL, -- ID ������������ (��������� ��� �����������)
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
    EventData NVARCHAR(MAX), -- ���������, ��������� ������
    ErrorDate DATETIME2 DEFAULT GETDATE() -- ���� � ����� ������
   
);

CREATE TABLE Web.EmailTemplates (
    TemplateId INT PRIMARY KEY,
    EventType NVARCHAR(50) NOT NULL, -- ����� � ����� �������
    Subject NVARCHAR(255) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL
);
INSERT INTO Web.EmailTemplates (TemplateId, EventType, Subject, Body)
VALUES (
    1, 
    'CustomerNotify', 
    '����������� �� ������ #{OrderId}', 
    '������ ����! ��������� ���� �������� � ������ #{OrderId}.'
),(
    2, 
    'ExecutorNotify', 
    '����������� �� ������ #{OrderId}', 
    '������ ����! ��������� ������ �� ������ #{OrderId}.'
);