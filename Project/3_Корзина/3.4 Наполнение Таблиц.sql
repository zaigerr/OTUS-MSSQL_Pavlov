USE [WebCentre];
GO
/*--Вывод списка продуктов доступных пользователю--*/
exec Web.proc_GetFilteredProducts 
	@UserID = 5,
	--@Customer= 'Кристальная вода ООО',
    @StatusApproval = 'Утверждён', 
    --@SearchName = 'удоб',
	--@Prodid = 'Инд-020938',
    @PageNumber = 1, 
    @PageSize = 200;

/*--Вызываю процедуру добавления товаров в корзину--*/
exec Web.proc_AddToCart 5, 'Инд-031642'

exec Web.proc_AddToCart 5,'Э-03257'

exec Web.proc_GetCartContents 6

/*--Вызываю процедуру просмотра содержимого корзины--*/

exec Web.proc_GetCartContents 5
/*на подумать, требуется ли на backend проверка прав, если по умолчанию id пользователя и списки доступных продуктов придут с FrontEnd
1) в целом нет
2) для процедуры добавления по номеру или имени детали продукта надо учитывать ограничение на доступных customer, иначе дырка в безопасности*/