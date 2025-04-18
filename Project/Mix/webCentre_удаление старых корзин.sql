/*--Удаление старых корзин. --*/
CREATE PROCEDURE web.CleanupOldCarts
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