/*--Из корзины создаю ЗАКАЗ--*/
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
			INSERT INTO Web.RequestHead (id_customer, Creator,Editor,LastActorDate, [status])
			SELECT a.id_customer, a.id_users, a.id_users,@LastActorDate,1
			FROM Web.Cart a where a.Cart_Id=@Cart_Id
			
			SET @id_head=  SCOPE_IDENTITY();
			UPDATE Web.RequestHead SET NameRequest ='#'+CAST(id as varchar)+'_'+(FORMAT (CreationDate, 'yyyy_MM_dd-')) + CAST (id_customer as varchar) where id=@id_head

			INSERT INTO Web.RequestElements (id_head, Prodid, ProdName, Quantity, Part_id)
			SELECT	 @id_head, a.ProdId, b.Descr, a.Quantity, d.Id 
			FROM Web.CartItems a 
			INNER JOIN BSJobs.admin.BSProduct (nolock) b ON a.ProdId=b.Prodid
			INNER JOIN BSJobs.admin.BSProductPart (nolock) c ON b.Id=c.Product_id
			INNER JOIN BSJobs.admin.BSPart (nolock) d ON c.Part_id=d.Id
			WHERE a.Card_id=@Cart_Id

			DELETE Web.CartItems WHERE Card_id=@Cart_Id
			DELETE Web.Cart WHERE Cart_Id=@Cart_Id
     
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

/*--Добавление комментария и обновление статуса--*/

CREATE PROCEDURE Web.proc_AddCommentUpdateStatus
    @Part_id char(32)
    ,@CommentText NVARCHAR(MAX)
    ,@AuthorId INT
	,@Approval_state INT
AS
BEGIN
    INSERT INTO Web.BSPartCommentsHistory (Part_id, Comment, AuthorId, CreatedAt, Approval_state)
    VALUES (@Part_id, @CommentText, @AuthorId, GETDATE(),@Approval_state);
END;

/*--История продукта--*/

CREATE PROCEDURE Web.proc_HistoryProduct 
@Part_id char(36)
AS
BEGIN
  SELECT a.CreatedAt, d.description, c.role_name, b1.username, a.Comment FROM [WebCentre].[Web].[BSPartCommentsHistory] a
  INNER JOIN [WebCentre].[Application].[Users] b1 on b1.id=a.AuthorId
  INNER JOIN [WebCentre].[Application].[ApprovalState] d on a.Approval_state=d.status
  CROSS APPLY (select b.username as role_name from [WebCentre].[Application].[Users] b where b1.role=b.role and b.subject_type=1) c
  WHERE a.Part_id=@Part_id
  ORDER BY CreatedAt
END;
