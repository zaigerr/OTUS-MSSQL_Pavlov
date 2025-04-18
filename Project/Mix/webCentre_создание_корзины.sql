CREATE PROCEDURE web.AddToCart
    @UserID INT,
    @ProductID nvarchar(136),
    @Quantity INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CartID INT,
				@CustomerID INT = null,
				@role INT;
		SET @role= (SELECT n.role FROM Web.Users n where n.id=@UserID)
 
 /*--Ограничение. У пользователя, создающего корзину может быть только одно родительское предприятие--*/
--ТРЕБУЕТСЯ  дописать проверку
-- Проверка, сколько контрагентов доступно пользователю
--;WITH temp as (
--				SELECT coalesce (b.Info1, b.Id) as  CusId from [Web].[AccessUsers] a 
--				inner join [BSJobs].[admin].[Customers] b on a.id_customers=b.Id
--				where a.id_users=@UserID and @role=1 --customer
--				GROUP BY coalesce (b.Info1, b.Id)
--				)
--SELECT COUNT(*) AS CustomerCount 
-- Если CustomerCount = 1, используем DefaultCustomerID, иначе закрываем корзину

		SET @CustomerID = (SELECT coalesce (b.Info1, b.Id) as  CusId from [Web].[AccessUsers] a 
							inner join [BSJobs].[admin].[Customers] b on a.id_customers=b.Id
							where a.id_users=@UserID and @role in(1) --корзину может создавать только пользователь с ролью customer
							GROUP BY coalesce (b.Info1, b.Id)
							)

        -- Находим активную корзину или создаем новую
        SELECT TOP 1 @CartID = Cart_Id
        FROM Web.Cart 
        WHERE id_users = @UserID --and id_customer=@CustomerID
        ORDER BY Create_Date DESC;
        
        IF @CartID IS NULL
        BEGIN
            INSERT INTO Cart (id_users, id_customer)
            VALUES (@UserID, @CustomerID);--тут нужно определить еще id customer для которого создается эта корзина
            SET @CartID = SCOPE_IDENTITY();
        END
        
        -- Обновляем количество или добавляем новый товар
        MERGE Web.CartItems AS target
        USING (SELECT @ProductID, @Quantity) AS source (ProdId, Quantity)
        ON (target.Card_id = @CartID AND target.ProdId = source.ProdId)
        WHEN MATCHED THEN
            UPDATE SET 
                Quantity = target.Quantity + source.Quantity,
                AddedData = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT (Card_id, ProdId, Quantity)
            VALUES (@CartID, source.ProdId, source.Quantity);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

