USE [WebCentre];
GO
/*--����� ������ ��������� ��������� ������������--*/
exec Web.proc_GetFilteredProducts 
	@UserID = 5,
	--@Customer= '����������� ���� ���',
    @StatusApproval = '��������', 
    --@SearchName = '����',
	--@Prodid = '���-020938',
    @PageNumber = 1, 
    @PageSize = 200;

/*--������� ��������� ���������� ������� � �������--*/
exec Web.proc_AddToCart 5, '���-031642'

exec Web.proc_AddToCart 5,'�-03257'

exec Web.proc_GetCartContents 6

/*--������� ��������� ��������� ����������� �������--*/

exec Web.proc_GetCartContents 5
/*�� ��������, ��������� �� �� backend �������� ����, ���� �� ��������� id ������������ � ������ ��������� ��������� ������ � FrontEnd
1) � ����� ���
2) ��� ��������� ���������� �� ������ ��� ����� ������ �������� ���� ��������� ����������� �� ��������� customer, ����� ����� � ������������*/