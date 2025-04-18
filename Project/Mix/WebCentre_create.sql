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
CREATE TABLE [Application].[AccessUsers] (
  [id_access_object] int  IDENTITY(1,1) NOT NULL,
  [id_users] int NOT NULL,
  [id_customers] int NOT NULL,
  CONSTRAINT [PK_AccessUsers] PRIMARY KEY CLUSTERED ([id_access_object])
);
GO

CREATE TABLE [Application].[ApprovalState] (
  [id] int IDENTITY(1,1) NOT NULL,
  [status] int NOT NULL,
  [description] nvarchar(255) NULL
);
GO
/*--наполняю таблицу [Application].ApprovalState --*/

INSERT INTO [Application].[ApprovalState] ([status],[description])
VALUES	 (0,'Не утвержден'), (1,'Внесение изменений')
		,(2, 'Утверждён'), (3, 'Архив')
		,(4, 'Ожидает согласования')

------------------------------------------
CREATE TABLE [Application].[Users] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [email] nvarchar(255)  NULL,
  [username] nvarchar(255)  NOT NULL,
  [password] nvarchar(255)  NULL,
  [role] int  NOT NULL,
  [subject_type] int  NOT NULL, 
  [last_login] datetimeoffset(7)  NULL,
  [status] int   NOT NULL,
  CONSTRAINT [PK_id_Users] PRIMARY KEY CLUSTERED ([id])
, CONSTRAINT [CK__users__email] UNIQUE([email])
, CONSTRAINT [CK__users__subject_type] CHECK ([subject_type]=0 OR [subject_type]=1) -- 0= users; 1=group
, CONSTRAINT [CK__users__role] CHECK ([role]=0 OR [role]=1 OR [role]=2 OR [role]=3) -- 0=designer; 1=customer; 2=manager; 3=admin
, CONSTRAINT [CK__users__status] CHECK ([status]=0 OR [status]=1) -- 0=active ; 1=blocked

)
GO

/*--Создаю корзину--*/
CREATE TABLE [Web].[Cart] (
  [Cart_Id] int IDENTITY(1,1) NOT NULL,
  [Create_Date] datetime DEFAULT GETDATE(),
  [id_users] int NOT NULL,
  [id_customer] int NOT NULL,
CONSTRAINT[PK_Cart_Id] PRIMARY KEY CLUSTERED ([Cart_Id] )
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
  CONSTRAINT [fk_Cart_Users] FOREIGN KEY ([id_users]) REFERENCES [Web].[Users] ([id])
)
GO

CREATE NONCLUSTERED INDEX [IX_Users_id]
ON [Web].[Cart] (
  [id_users]
)
GO
----------------------------
/*--Создаю детализацию корзины--*/
CREATE TABLE [Web].[CartItems] (
  [id_Cart_Item] bigint IDENTITY(1,1) NOT NULL,
  [Card_id] int NOT NULL,
  [ProdId] nvarchar(136) NOT NULL,
  [Quantity] int NOT NULL,
  [AddedData] datetime DEFAULT GETDATE(),
CONSTRAINT [id_Cart_Item] PRIMARY KEY CLUSTERED ([id_Cart_Item])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
  CONSTRAINT [fk_CartItems_Cart] FOREIGN KEY ([Card_id]) REFERENCES [Web].[Cart] ([Cart_Id]),
  CONSTRAINT [Quantity] CHECK (Quantity>0)
)
GO

CREATE NONCLUSTERED INDEX [IX_CartItems_CartProdId]
ON [Web].[CartItems] (
  [Card_id],
  [ProdId]
)
GO

/*
CREATE TABLE [Web].[RequestHead] (
  [Id] char(36)  NOT NULL,
  [NameRequest] nvarchar(128)  NULL,
  [CusId] nvarchar(32)  NOT NULL,
  [Creator] int  NOT NULL,
  [Editor] int  NOT NULL,
  [CreationDate] datetime DEFAULT GETDATE() NOT NULL,
  [LastActorDate] datetime ,
  CONSTRAINT [id_RequesHead] PRIMARY KEY CLUSTERED ([Id])
)
GO
CREATE NONCLUSTERED INDEX [IX_NameRequest]
ON [Web].[RequestHead] (
  [NameRequest] desc
)
CREATE NONCLUSTERED INDEX [IX_Users_id]
ON [Web].[RequestHead] (
  [Creator]
)
GO
---------
CREATE TABLE [Web].[RequestElements] (
  [Id] char(36)  NOT NULL,
  [id_request_head] char(36) NULL,
  [ProdId] nvarchar(64)  NOT NULL,
  [ProdName] nvarchar(1024)  NULL,
  [Comment] nvarchar(max)  NULL,
  [FileUrl] nvarchar(256)  NULL,
  [Notify] char(36)  NULL,
  [Mark] bit  NULL,
  [Changed] bit  NULL,
  [NewFile] bit  NULL,
  [NewProduct] bit  NULL,
CONSTRAINT [PK_RequestElem] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
  CONSTRAINT [fk_RequestItems_RequestHead] FOREIGN KEY ([id_request_head]) REFERENCES [Web].[RequestHead] ([Id])
)
GO
CREATE NONCLUSTERED INDEX [IX_ProdId_id_request_head]
ON [Web].[RequestElements] (
  [ProdId],[id_request_head]
)
GO
*/

/*
CREATE TABLE [Web].[RequestPart] (
  [Id] char(36)  NOT NULL,
  [OrderPartName] nvarchar(256)  NOT NULL,
  [Position] int  NOT NULL,
  [OrderedCopies] int  NOT NULL,
  [id_req_head] char(36)  NOT NULL,
  CONSTRAINT [PK_RequestPart] PRIMARY KEY CLUSTERED ([Id])

)
GO
*/
---------------------------------------------
/*ALTER TABLE [Web].[RequestHead] ADD CONSTRAINT [FK_Request_Users] FOREIGN KEY ([Creator]) REFERENCES [Web].[Users] ([id])
GO

ALTER TABLE [Web].[RequestPart] ADD CONSTRAINT [FK_RequestElement_RequestHead] FOREIGN KEY ([id_req_head]) REFERENCES [Web].[RequestHead] ([Id])
GO

ALTER TABLE [Web].[AccessUsers] ADD CONSTRAINT [FK_Web.Users_Web.Access] FOREIGN KEY ([id_users]) REFERENCES [Web].[Users] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO --подумать над необходимостью этого
*/
