CREATE PROCEDURE Web.GetCartContents
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
		WHERE a.id_users = 7
		ORDER BY b.AddedData DESC;
END;