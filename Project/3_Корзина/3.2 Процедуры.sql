USE WebCentre;
GO
/*--Процедура для вывода списка продуктов доступных пользователю по странично--*/
CREATE PROCEDURE Web.proc_GetFilteredProducts
    @UserID INT,
	@Prodid NVARCHAR(64) = NULL,
    @StatusApproval NVARCHAR(64) = NULL, 
    @Status_Value NVARCHAR(64) = NULL, 
    @Customer NVARCHAR(64) = NULL, 
    @SearchName NVARCHAR(255) = NULL, 
    @PageNumber INT = 1, 
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    WITH FilteredData AS (
        SELECT 
            b.Info1 AS parent, 
            b.Id, 
            b.Name AS Customer, 
            c.Prodid, 
            c.Descr AS Names,
            e.Category1 AS status_approval,
            e.Category3 AS autor,
            e.Status_User,
            e.Status_Value,
			e.Id AS Part_id
        FROM [Application].[AccessUsers] (nolock) a 
        INNER JOIN [BSJobs].[admin].[Customers] (nolock) b ON a.id_customers = CONVERT(INT, b.Id) --конвертирую поле в int
        INNER JOIN [BSJobs].[admin].[BSProduct] (nolock) c ON b.Id = c.Cusid
        INNER JOIN [BSJobs].[admin].BSProductPart (nolock) d ON d.Product_id = c.Id
        INNER JOIN [BSJobs].[admin].[BSPart] (nolock) e ON e.Id = d.Part_id
        WHERE a.id_users = @UserID
    )
    SELECT 
        parent, Id, Names, Prodid, Customer, status_approval, autor, Status_User, Status_Value,Part_id
    FROM FilteredData
    WHERE 
        (@StatusApproval IS NULL OR status_approval = @StatusApproval)
        AND (@Status_Value IS NULL OR Status_Value = @Status_Value)
        AND (@Customer IS NULL OR Customer = @Customer)
        AND (@SearchName IS NULL OR Names LIKE '%' + @SearchName + '%')
		AND (@Prodid IS NULL OR Prodid LIKE '%' + @Prodid + '%')
    ORDER BY Id
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
	OPTION (RECOMPILE); --перестроение плана при каждом запросе
END;

/*--Cоздаю корзину из доступных продуктов--*/
CREATE PROCEDURE Web.proc_AddToCart
    @UserID INT,
    @ProductID nvarchar(136),
    @Quantity INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CartID INT
				,@CustomerID INT = null
				,@CustomerCount INT =null
				,@role INT;
		SET @role= (SELECT n.role FROM [Application].[Users] n where n.id=@UserID)
 
 /*--Ограничение. У пользователя, создающего корзину может быть доступно только одно родительское предприятие--*/
-- Проверка, сколько контрагентов доступно представителю заказчика
;WITH temp as (
				SELECT coalesce (b.Info1, b.Id) as  CusId from [Application].[AccessUsers] a 
				inner join [BSJobs].[admin].[Customers] b on a.id_customers=b.Id
				where a.id_users=@UserID and @role=1 --customer
				GROUP BY coalesce (b.Info1, b.Id)
				)
SELECT @CustomerCount=COUNT(*) FROM temp 

        IF @CustomerCount > 1
        BEGIN
            ;THROW 50001, N'Недопустимо представителю заказчика иметь больше одного родительского предприятия', 1;
        END;

		SET @CustomerID = (SELECT coalesce (b.Info1, b.Id) as  CusId from [Application].[AccessUsers] a 
							inner join [BSJobs].[admin].[Customers] b on a.id_customers=b.Id
							where a.id_users=@UserID and @role in(1) --корзину может создавать только пользователь с ролью customer
							GROUP BY coalesce (b.Info1, b.Id)
							)
        -- Находим активную корзину или создаем новую
        SELECT TOP 1 @CartID = Cart_Id
        FROM Web.Cart 
        WHERE id_users = @UserID 
        ORDER BY Create_Date DESC;
        
        IF @CartID IS NULL
        BEGIN
            INSERT INTO Cart (id_users, id_customer)
            VALUES (@UserID, @CustomerID);
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
GO
---------------------------------------------------------------------------
/*--Просмотр содержимого корзины--*/
USE WebCentre;
GO
CREATE PROCEDURE Web.proc_GetCartContents
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
		SELECT 
				b.ProdId
				,Coalesce (c.Descr, c.Name) Prod_Name
				,b.Quantity
				,a.id_users
				,a.id_customer
		FROM Web.Cart a
		JOIN Web.CartItems b ON a.Cart_Id = b.Card_id
		JOIN BSJobs.admin.BSProduct c ON c.Prodid=b.ProdId
		WHERE a.id_users = @UserID
		ORDER BY b.AddedData DESC;
END;
GO
----------------------------------------------------------------------------
/*--Удаление старых корзин. Вешаем на Job --*/
USE WebCentre;
GO
CREATE PROCEDURE Web.proc_CleanupOldCarts
    @DaysOld INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Удаляем элементы корзин
        DELETE ci
        FROM Web.CartItems ci
        INNER JOIN Web.Cart c ON ci.Card_id = c.Cart_Id
        WHERE c.Create_Date < DATEADD(DAY, -@DaysOld, GETDATE());
        
        -- Удаляем сами корзины
        DELETE FROM Web.Cart 
        WHERE Create_Date < DATEADD(DAY, -@DaysOld, GETDATE());
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;