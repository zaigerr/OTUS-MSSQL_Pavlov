CREATE TABLE [Web].[RequestHead] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [NameRequest] nvarchar(255) NULL,
  [id_customer] int  NOT NULL,
  [Creator] int  NOT NULL,
  [Editor] int  NOT NULL,
  [CreationDate] datetime2(7)  DEFAULT GETDATE() NOT NULL,
  [LastActorDate] datetime2(7)  NOT NULL,
  [status] int NOT NULL
  CONSTRAINT [id_RequesHead] PRIMARY KEY CLUSTERED ([id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
  CONSTRAINT [FK_Request_Users] FOREIGN KEY ([Creator]) REFERENCES [Web].[Users] ([id]),
  CONSTRAINT [status] CHECK ([status]=0 OR [status]=1)
)
GO

CREATE NONCLUSTERED INDEX [IX_NameRequest]
ON [Web].[RequestHead] (
  [NameRequest] ASC
)
GO

CREATE TABLE Web.RequestElements (
    id INT PRIMARY KEY IDENTITY,
    id_head INT NOT NULL,
    Prodid nvarchar(64) NOT NULL,
    ProdName NVARCHAR(1024),
	[Quantity] int NOT NULL,
    Comment NVARCHAR(MAX),
    [FileName] NVARCHAR(500),
	Changed int ,
	Mark bit,
    Part_id char(32), -- Ссылка на BSPartStatusHistory
	CommentAuthorId int NULL,
	CommentCreatedAt  DATETIME2,
	Approval_state int,
	Version ROWVERSION,
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Web.RequestElementsHistory));

ALTER TABLE Web.RequestElements
ADD CONSTRAINT [fk_RequestElements_RequestHead] FOREIGN KEY (id_head) REFERENCES Web.RequestHead(id);

ALTER TABLE Web.RequestElements ADD CONSTRAINT Part_id UNIQUE NONCLUSTERED (Part_id)

CREATE NONCLUSTERED INDEX [IX_id_req_part]
ON [Web].RequestElements (
  Part_id,Prodid
) --лучше сделать Unique
GO

CREATE TABLE Web.BSPartCommentsHistory (
    id INT PRIMARY KEY IDENTITY,
    Part_id char(32) NOT NULL REFERENCES Web.RequestElements(Part_id),
    Comment NVARCHAR(MAX) NULL,
    AuthorId INT NOT NULL, -- ID пользователя из системы аутентификации
	Approval_state int  NULL,
    CreatedAt DATETIME2 
);
GO

CREATE TRIGGER TR_BSPart_Comments_History
ON Web.RequestElements
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Если изменился комментарий или статус
    INSERT INTO Web.BSPartCommentsHistory (Part_id, Comment, AuthorId, Approval_state, CreatedAt)
    SELECT 
        i.Part_id, 
        i.Comment, 
        i.CommentAuthorId,
		i.Approval_state,
        i.CommentCreatedAt
    FROM 
        inserted i
    INNER JOIN 
        deleted d ON i.id = d.id
    WHERE 
        (i.Comment <> d.Comment OR (i.Comment IS NULL AND d.Comment IS NOT NULL)) OR i.Approval_state <> d.Approval_state;

END;