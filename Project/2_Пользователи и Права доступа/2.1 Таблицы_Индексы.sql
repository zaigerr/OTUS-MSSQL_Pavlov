USE WebCentre
-----------------Таблицы схемы Application ---------------------------------------------------------
/*--Состояние утверждения продукта--*/
CREATE TABLE [Application].[ApprovalState] (
  [id] int IDENTITY(1,1) NOT NULL,
  [status] int NOT NULL,
  [description] nvarchar(255) NULL
  CONSTRAINT [status] UNIQUE ([status])
);
GO
/*--Пользователи --*/
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
, CONSTRAINT [CK__users__subject_type] CHECK ([subject_type]=0 OR [subject_type]=1) 
, CONSTRAINT [CK__users__role] CHECK ([role]=0 OR [role]=1 OR [role]=2 OR [role]=3) 
, CONSTRAINT [CK__users__status] CHECK ([status]=0 OR [status]=1) 

)
GO
EXEC sp_addextendedproperty
'MS_Description', N'0=designer; 1=customer; 2=manager; 3=admin',
'SCHEMA', N'Application',
'TABLE', N'Users',
'COLUMN', N'role'
GO

EXEC sp_addextendedproperty
'MS_Description', N'1 = группа  0=пользователь',
'SCHEMA', N'Application',
'TABLE', N'Users',
'COLUMN', N'subject_type'
GO

EXEC sp_addextendedproperty
'MS_Description', N'0=active; 1=blocked',
'SCHEMA', N'Application',
'TABLE', N'Users',
'COLUMN', N'status'

/*--Права доступа--*/
CREATE TABLE [Application].[AccessUsers] (
  [id_access_object] int  IDENTITY(1,1) NOT NULL,
  [id_users] int NOT NULL,
  [id_customers] int NOT NULL,
  CONSTRAINT [PK_AccessUsers] PRIMARY KEY CLUSTERED ([id_access_object])
);
GO
CREATE NONCLUSTERED INDEX [IX_id_users]
ON [Application].[AccessUsers] (
  [id_users]
)
GO
CREATE INDEX IX_AccessUsers_id_customers 
ON [WebCentre].[Application].[AccessUsers] (id_customers);
GO
