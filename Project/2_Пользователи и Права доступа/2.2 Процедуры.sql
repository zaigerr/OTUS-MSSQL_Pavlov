USE WebCentre;
GO
/*--включаю поддержку CLR--*/
 exec sp_configure 'clr enabled', 1;
 RECONFIGURE;
 GO
--создаю сборку
USE WebCentre
   CREATE ASSEMBLY EmailValidatorAssembly
   FROM 'C:\Temp\IsEmailValid\IsEmailValid\bin\Release\IsEmailValid.dll'
   WITH PERMISSION_SET = SAFE;
 GO
--делаю из сборки функцию
CREATE FUNCTION [Application].IsValidEmail(@email NVARCHAR(255))
RETURNS BIT
AS EXTERNAL NAME EmailValidatorAssembly.EmailValidator.IsValidEmail;

 GO
----------------------------------------------------------------------------------------------------
/*--Создаю процедуру для добавления пользователя--*/
CREATE procedure [Application].proc_CreateWebUsers (
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
raiserror('Email не соответствует стандарту', 20, -1) with log
	rollback transaction
	return
end
------------хеширование пароля для хранения в таблице ----------------------
DECLARE @HashThis NVARCHAR(32), @HashThat VARBINARY (max);
SET @HashThis = CONVERT(NVARCHAR(32),@password); 
SET @HashThat=HASHBYTES('SHA2_256', @HashThis);
set @password = (
SELECT CONVERT(VARCHAR(max), @HashThat, 2) )
-----------------------------------------------------------------------------
INSERT INTO [Application].Users (email, username, [password], [role], subject_type, [status])
values (@email, @username, @password, @role, @subject_type, @status)

END
---------------------------------------------------------------------------------------------------------

/*--Создаю процедуру для добавления прав пользователя--*/
CREATE procedure [Application].proc_AccessWebUsers (@id_users int, @id_customers int) as
BEGIN
IF EXISTS (select 1 from [Application].Users where id=@id_users) and EXISTS (select 1 from BSJobs.[admin].[Customers] where Id=@id_customers)

begin
INSERT INTO [Application].AccessUsers (id_users, id_customers)
values (@id_users, @id_customers)
end

;WITH del_dubl AS (SELECT id_customers, ROW_NUMBER() OVER (PARTITION BY id_users, id_customers order by id_customers) as rnk from [Application].AccessUsers)
delete del_dubl where rnk>1 and id_customers=@id_customers
END

