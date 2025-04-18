USE WebCentre
----------------Таблицы схемы Web КОРЗИНА---------------
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