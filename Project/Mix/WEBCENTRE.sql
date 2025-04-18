USE master; 
GO 
IF DB_ID (N'WebCentre') IS NOT NULL 
	DROP DATABASE WebCentre;  

CREATE DATABASE WebCentre;
GO	
Use WebCentre;
GO
CREATE SCHEMA [Web];
GO
CREATE TABLE [Web].[AccessUsers] (
  [id_access_object] int NOT NULL,
  [id_users] int NOT NULL,
  [id_customers] int NOT NULL,
  CONSTRAINT [PK_AccessUsers] PRIMARY KEY CLUSTERED ([id_access_object])
)
GO

CREATE TABLE [Web].[RequestElements] (
  [Id] char(36)  NOT NULL,
  [id_req_part] char(36) NULL,
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
)
GO
CREATE NONCLUSTERED INDEX [IX_id_req_part]
ON [Web].[RequestElements] (
  [id_req_part] DESC
)
GO

CREATE TABLE [Web].[RequestHead] (
  [Id] char(36)  NOT NULL,
  [NameRequest] nvarchar(128)  NULL,
  [CusId] nvarchar(32)  NOT NULL,
  [Creator] int  NOT NULL,
  [Editor] int  NOT NULL,
  [CreationDate] datetime2(7)  NOT NULL,
  [LastActorDate] datetime2(7)  NOT NULL,
  CONSTRAINT [id_RequesHead] PRIMARY KEY CLUSTERED ([Id])

)
GO
CREATE NONCLUSTERED INDEX [IX_NameRequest]
ON [Web].[RequestHead] (
  [NameRequest] ASC
)
GO
CREATE TABLE [Web].[RequestPart] (
  [Id] char(36)  NOT NULL,
  [OrderPartName] nvarchar(256)  NOT NULL,
  [Position] int  NOT NULL,
  [OrderedCopies] int  NOT NULL,
  [id_req_head] char(36)  NOT NULL,
  CONSTRAINT [PK_RequestPart] PRIMARY KEY CLUSTERED ([Id])

)
GO
CREATE TABLE [Web].[Users] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [email] nvarchar(255)  NULL,
  [username] nvarchar(255)  NOT NULL,
  [password] nvarchar(255)  NULL,
  [role] int  NOT NULL,
  [last_login] datetimeoffset(7)  NULL,
  [status] int  NULL,
  CONSTRAINT [PK_id_Users] PRIMARY KEY CLUSTERED ([id])
,
  CONSTRAINT [CK__users__status] CHECK ([status]=N'inactive' OR [status]=N'active')
)
GO

ALTER TABLE [Web].[RequestHead] ADD CONSTRAINT [FK_Request_Users] FOREIGN KEY ([Creator]) REFERENCES [Web].[Users] ([id])
GO
/*ALTER TABLE [Web].[RequestPart] ADD CONSTRAINT [FK_RequestPart_Elements] FOREIGN KEY ([Id]) REFERENCES [Web].[RequestElements] ([id_req_part])
GO --не работает выдает ошибка, что в ссыллающейся таблице нет первичного ключа. Но он есть. Получается, что FK может ссылаться только на PK? */

ALTER TABLE [Web].[RequestElements] ADD CONSTRAINT [FK_RequestPart_Elements] FOREIGN KEY ([id_req_part]) REFERENCES [Web].[RequestPart] ([Id])
GO

ALTER TABLE [Web].[RequestPart] ADD CONSTRAINT [FK_RequestPart_RequestHead] FOREIGN KEY ([id_req_head]) REFERENCES [Web].[RequestHead] ([Id])
GO

ALTER TABLE [Web].[AccessUsers] ADD CONSTRAINT [FK_Web.Users_Web.Access] FOREIGN KEY ([id_users]) REFERENCES [Web].[Users] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
