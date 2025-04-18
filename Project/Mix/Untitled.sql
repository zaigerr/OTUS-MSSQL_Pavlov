CREATE TABLE [BSPart] (
  [Id] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Name] nvarchar(136) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Url] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [UrlHelper] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [BaseUrl] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [BaseUrlHelper] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category3] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Status_Created] datetime2(7)  NULL,
  [Status_Notes] nvarchar(1024) COLLATE Cyrillic_General_CI_AS  NULL,
  [Status_User] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Status_Value] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [DefaultColorBook] nvarchar(48) COLLATE Cyrillic_General_CI_AS  NULL,
  [DefaultSpotFunction] nvarchar(20) COLLATE Cyrillic_General_CI_AS  NULL,
  [DefaultAngle] float(53)  NULL,
  [DefaultFrequency] float(53)  NULL,
  [VDPType] int  NULL,
  [Pub_id] char(32) COLLATE Cyrillic_General_CI_AS  NULL,
  [WFID] char(53) COLLATE Cyrillic_General_CI_AS  NULL
)
GO
ALTER TABLE [BSPart] SET (LOCK_ESCALATION = TABLE)
GO
CREATE NONCLUSTERED INDEX [BSPart_i1]
ON [].[BSPart] (
  [Name] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSPart_i2]
ON [].[BSPart] (
  [Url] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSPart_i3]
ON [].[BSPart] (
  [Category1] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [BSPart_i4]
ON [].[BSPart] (
  [UrlHelper] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSPart_i5]
ON [].[BSPart] (
  [BaseUrlHelper] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSPart_i6]
ON [].[BSPart] (
  [WFID] ASC
)
GO

CREATE TABLE [BSPartComments] (
  [Id] char(36) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Type] int  NOT NULL,
  [CreationDate] datetime  NOT NULL,
  [Author] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Comment] nvarchar(4000) COLLATE Cyrillic_General_CI_AS  NULL,
  [PartId] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  CONSTRAINT [PK__BSPartCo__3214EC07DFAE5826] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [BSPartComments] SET (LOCK_ESCALATION = TABLE)
GO
EXEC sp_addextendedproperty
'MS_Description', N'type 1-версия дизайна, 0-текстовые изменния, 2-утверждено, 3-, 4-уведомление заказчика'
GO
EXEC sp_addextendedproperty
'MS_Description', N'дата создания'
GO
EXEC sp_addextendedproperty
'MS_Description', N'автор комментария'
GO
EXEC sp_addextendedproperty
'MS_Description', N'комментарий '
GO

CREATE TABLE [BSProduct] (
  [Id] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Prodid] nvarchar(136) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Cusid] nvarchar(42) COLLATE Cyrillic_General_CI_AS  NULL,
  [Cusref] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Name] nvarchar(136) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Descr] nvarchar(1024) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Category3] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Parent] char(36) COLLATE Cyrillic_General_CI_AS  NULL,
  [Created] datetime2(7)  NOT NULL,
  [OrderMaterialId] nvarchar(36) COLLATE Cyrillic_General_CI_AS  NULL,
  [LocationCategory] nvarchar(128) COLLATE Cyrillic_General_CI_AS  NULL,
  CONSTRAINT [PK__BSProduc__3214EC0704DA79F7] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [BSProduct] SET (LOCK_ESCALATION = TABLE)
GO
CREATE UNIQUE NONCLUSTERED INDEX [BSProduct_i1]
ON [].[BSProduct] (
  [Name] ASC,
  [Parent] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [BSProduct_i2]
ON [].[BSProduct] (
  [Prodid] ASC,
  [Parent] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSProduct_i3]
ON [].[BSProduct] (
  [Parent] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSProduct_i4]
ON [].[BSProduct] (
  [Category1] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [BSProduct_i5]
ON [].[BSProduct] (
  [LocationCategory] ASC,
  [Id] ASC
)
GO

CREATE TABLE [BSProductPart] (
  [Id] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Product_id] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Part_id] char(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Position] int  NOT NULL,
  CONSTRAINT [PK__BSProduc__3214EC074B6BCDA1] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [BSProductPart] SET (LOCK_ESCALATION = TABLE)
GO
CREATE NONCLUSTERED INDEX [BSProductPart_i1]
ON [].[BSProductPart] (
  [Product_id] ASC,
  [Part_id] ASC
)
GO
CREATE NONCLUSTERED INDEX [BSProductPart_i2]
ON [].[BSProductPart] (
  [Part_id] ASC,
  [Product_id] ASC
)
GO

CREATE TABLE [Customers] (
  [Id] int  NOT NULL,
  [Name] nvarchar(72) COLLATE Cyrillic_General_CI_AS  NULL,
  [Description] nvarchar(128) COLLATE Cyrillic_General_CI_AS  NULL,
  [Info1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Info2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Info3] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Info4] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Info5] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Contact1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Contact2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Contact3] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [EMail1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [EMail2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [EMail3] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Street1] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Street2] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Zip] nvarchar(16) COLLATE Cyrillic_General_CI_AS  NULL,
  [City] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [Country] nvarchar(32) COLLATE Cyrillic_General_CI_AS  NULL,
  [JobLocation] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [PrdLocation] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [UplLocation] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [CloudId] nvarchar(1024) COLLATE Cyrillic_General_CI_AS  NULL,
  [CloudBy] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NULL,
  [CloudAt] datetime2(7)  NULL,
  CONSTRAINT [PK__Customer__3214EC073CF9F4F6] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [Customers] SET (LOCK_ESCALATION = TABLE)
GO
CREATE NONCLUSTERED INDEX [Customers_i1]
ON [].[Customers] (
  [Name] ASC
)
GO
EXEC sp_addextendedproperty
'MS_Description', N'Хранить id родительского предприятия'
GO

CREATE TABLE [WebAccessUsers] (
  [id_access_object] int NOT NULL,
  [id_users] int NOT NULL,
  [id_customers] int NOT NULL,
  CONSTRAINT [_copy_2] PRIMARY KEY CLUSTERED ([id_access_object])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TABLE [WebRequest] (
  [Id] char(36) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [OrderPartName] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [Position] int  NOT NULL,
  [OrderedCopies] int  NOT NULL,
  [CusId] nvarchar(32) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [CreationDate] datetime2(7)  NOT NULL,
  [Creator] int  NOT NULL,
  [LastActorDate] datetime2(7)  NOT NULL,
  [Editor] int  NOT NULL,
  [Name] nvarchar(128) COLLATE Cyrillic_General_CI_AS  NULL,
  CONSTRAINT [_copy_1] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [WebRequest] SET (LOCK_ESCALATION = TABLE)
GO
EXEC sp_addextendedproperty
'MS_Description', N'id связан по FK с таблицей WebRequestElements поле ReqId'
GO
EXEC sp_addextendedproperty
'MS_Description', N'Наименование элемента заявки'
GO
EXEC sp_addextendedproperty
'MS_Description', N'Номер позиции в заявке'
GO
EXEC sp_addextendedproperty
'MS_Description', N'Тираж элемента в заявке'
GO
EXEC sp_addextendedproperty
'MS_Description', N'ID заказчика/не понятно его назначение в этой таблице, в чем смысл/ '
GO
EXEC sp_addextendedproperty
'MS_Description', N'дата создания'
GO
EXEC sp_addextendedproperty
'MS_Description', N'id создателя'
GO
EXEC sp_addextendedproperty
'MS_Description', N'последняя дата редактирования'
GO
EXEC sp_addextendedproperty
'MS_Description', N'id редактора'
GO
EXEC sp_addextendedproperty
'MS_Description', N'имя заявки'
GO

CREATE TABLE [WebRequestElements] (
  [Id] char(36) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [ReqId] char(36) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [ProdId] nvarchar(64) COLLATE Cyrillic_General_CI_AS  NOT NULL,
  [ProdName] nvarchar(1024) COLLATE Cyrillic_General_CI_AS  NULL,
  [Comment] ntext COLLATE Cyrillic_General_CI_AS  NULL,
  [FileUrl] nvarchar(256) COLLATE Cyrillic_General_CI_AS  NULL,
  [Mark] bit  NULL,
  [Changed] bit  NULL,
  [NewFile] bit  NULL,
  [Notify] char(36) COLLATE Cyrillic_General_CI_AS  NULL,
  [NewProduct] bit  NULL,
  PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
ALTER TABLE [WebRequestElements] SET (LOCK_ESCALATION = TABLE)
GO
EXEC sp_addextendedproperty
'MS_Description', N'id продукта'
GO
EXEC sp_addextendedproperty
'MS_Description', N'имя продукта'
GO
EXEC sp_addextendedproperty
'MS_Description', N'комментарий последний в заявке'
GO
EXEC sp_addextendedproperty
'MS_Description', N'имя нового файла в заявке для элемента'
GO
EXEC sp_addextendedproperty
'MS_Description', N'отмеченный элемент в заявке'
GO
EXEC sp_addextendedproperty
'MS_Description', N'0 - нет изменений
1 - изменения по элементу'
GO
EXEC sp_addextendedproperty
'MS_Description', N'0 - нет нового файла
1 - новый файл'
GO
EXEC sp_addextendedproperty
'MS_Description', N'уведомление, указывается роль пользователя в системе. admin, customer, designer'
GO
EXEC sp_addextendedproperty
'MS_Description', N'
0 = старый продукт
1 = новый входящий продукт IN '
GO

CREATE TABLE [WebUsers] (
  [id] int  IDENTITY(1,1) NOT NULL,
  [email] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  [username] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  [userID] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  [password] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  [role] nvarchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  [last_login] datetimeoffset(7)  NULL,
  [status] varchar(255) COLLATE Cyrillic_General_CI_AS  NULL,
  CONSTRAINT [CK__users__status__703EA55A] CHECK ([status]=N'inactive' OR [status]=N'active')
)
GO
ALTER TABLE [WebUsers] SET (LOCK_ESCALATION = TABLE)
GO

ALTER TABLE [BSPart] ADD CONSTRAINT [temp3] FOREIGN KEY ([Id]) REFERENCES [BSProductPart] ([Part_id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
ALTER TABLE [BSPartComments] ADD CONSTRAINT [id_BSPart_to_PartId_BSPartComments] FOREIGN KEY ([PartId]) REFERENCES [BSPart] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
ALTER TABLE [BSPartComments] ADD CONSTRAINT [PartId_BSPartComm_to_Part_Id_BSProductPart] FOREIGN KEY ([PartId]) REFERENCES [BSProductPart] ([Part_id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
ALTER TABLE [BSProduct] ADD CONSTRAINT [temp2] FOREIGN KEY ([Id]) REFERENCES [BSProductPart] ([Product_id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
ALTER TABLE [WebAccessUsers] ADD CONSTRAINT [id_users_Access_to_id_WebUsers] FOREIGN KEY ([id_users]) REFERENCES [WebUsers] ([id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
ALTER TABLE [WebAccessUsers] ADD CONSTRAINT [id_customers_to_id_Customers] FOREIGN KEY ([id_customers]) REFERENCES [Customers] ([Id])
GO
ALTER TABLE [WebRequest] ADD CONSTRAINT [WebRequest_to_WebRequestElements] FOREIGN KEY ([Id]) REFERENCES [WebRequestElements] ([ReqId])
GO
ALTER TABLE [WebRequest] ADD CONSTRAINT [WebRequest_to_WebUsers] FOREIGN KEY ([Creator]) REFERENCES [WebUsers] ([id])
GO
ALTER TABLE [WebRequestElements] ADD CONSTRAINT [temp1] FOREIGN KEY ([ProdId]) REFERENCES [BSProduct] ([Prodid]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO
EXEC sp_addextendedproperty
'MS_Description', N'временый, чтоб разобраться в связях'
GO

