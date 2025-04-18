USE WebCentre
/*--������� ��������� CLR--*/
 sp_configure 'clr enabled', 1;
 RECONFIGURE;
 GO
--������ ������
USE WebCentre
   CREATE ASSEMBLY EmailValidatorAssembly
   FROM 'C:\Temp\IsEmailValid\IsEmailValid\bin\Release\IsEmailValid.dll'
   WITH PERMISSION_SET = SAFE;
 GO
--����� �� ������ �������
CREATE FUNCTION [Application].IsValidEmail(@email NVARCHAR(255))
RETURNS BIT
AS EXTERNAL NAME EmailValidatorAssembly.EmailValidator.IsValidEmail;

 GO

/*--������ ��������� ��� ���������� ������������--*/
CREATE procedure [Application].CreateWebUsers (
	 @email nvarchar(255)
	,@username nvarchar(255)
	,@password nvarchar(255)
	,@role int
	,@subject_type int =0
	,@status int =0				) as

BEGIN

DECLARE @valid_email int 
set @valid_email = (select dbo.IsValidEmail(@email) )
IF @valid_email=0
begin
raiserror('Email �� ������������� ���������', 20, -1) with log
	rollback transaction
	return
end
------------����������� ������ ��� �������� � ������� ----------------------
DECLARE @HashThis NVARCHAR(32), @HashThat VARBINARY (max);
SET @HashThis = CONVERT(NVARCHAR(32),@password);  -- � ������ ������� test - ��� ������ ������������
SET @HashThat=HASHBYTES('SHA2_256', @HashThis);
set @password = (
SELECT CONVERT(VARCHAR(max), @HashThat, 2) )
-----------------------------------------------------------------------------
INSERT INTO [Application].Users (email, username, [password], [role], subject_type, [status])
values (@email, @username, @password, @role, @subject_type, @status)

END

/*--�������� ������--*/
INSERT INTO [Application].Users (email, username, [role], subject_type, [status])
values ('designer','designer', 0, 1, 0),('customer','customer', 1, 1, 0),('manager','manager', 2, 1, 0),('admin','admin', 3, 1, 0)

/*������� ��������� ��� �������� ������������*/
exec [Application].CreateWebUsers 'pda@remas.ru', '������� ������', '"lbycrfz73', 1

/*--�������� ����� ������ admin � designer �� ���� ������������ �����������--*/
;With temp as (select 3 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;With temp as (select 0 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;WITH del_dubl AS (SELECT ROW_NUMBER() OVER (PARTITION BY id_users,id_customers order by id_users) as rnm from [Application].AccessUsers)
delete del_dubl where rnm>1

/*--������ ��������� ��� ���������� ���� ������������--*/
CREATE procedure [Application].AccessWebUsers (@id_users int, @id_customers int) as
BEGIN
IF EXISTS (select 1 from Web.Users where id=@id_users) and EXISTS (select 1 from BSJobs.[admin].[Customers] where Id=@id_customers)

begin
INSERT INTO [Application].AccessUsers (id_users, id_customers)
values (@id_users, @id_customers)
end

;WITH del_dubl AS (SELECT id_customers, ROW_NUMBER() OVER (PARTITION BY id_users, id_customers order by id_customers) as rnk from [Application].AccessUsers)
delete del_dubl where rnk>1 and id_customers=@id_customers
END

/*--�������� ����� ������������� � ������������*/
exec [Application].AccessWebUsers 7,62

