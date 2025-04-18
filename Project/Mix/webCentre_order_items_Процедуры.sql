USE [WebCentre]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Web.proc_AddToRequest @Cart_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
			DECLARE @LastActorDate datetime2
					,@id_head int
			SET @LastActorDate= (SELECT GETDATE())
			INSERT INTO Web.RequestHead (id_customer, Creator,Editor,LastActorDate,[status])
			SELECT a.id_customer, a.id_users, a.id_users,@LastActorDate,1
			FROM Web.Cart a where a.Cart_Id=@Cart_Id
			
			SET @id_head=  SCOPE_IDENTITY();
			UPDATE Web.RequestHead SET NameRequest ='#'+CAST(id as varchar)+'_'+(FORMAT (CreationDate, 'yyyy_MM_dd-')) + CAST (id_customer as varchar) where id=@id_head

			INSERT INTO Web.RequestElements (id_head, Prodid, ProdName, Quantity, Part_id, Approval_state)
			SELECT	 @id_head, a.ProdId, b.Descr, a.Quantity, d.Id 
					,CASE WHEN e.status is NULL THEN 0 ELSE e.status END
			FROM Web.CartItems a 
			INNER JOIN BSJobs.admin.BSProduct (nolock) b ON a.ProdId=b.Prodid
			INNER JOIN BSJobs.admin.BSProductPart (nolock) c ON b.Id=c.Product_id
			INNER JOIN BSJobs.admin.BSPart (nolock) d ON c.Part_id=d.Id
			LEFT JOIN Application.ApprovalState (nolock) e ON d.Category1=e.description
			where a.Card_id=@Cart_Id

			DELETE Web.CartItems WHERE Card_id=@Cart_Id
			DELETE Web.Cart WHERE Cart_Id=@Cart_Id
     
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;