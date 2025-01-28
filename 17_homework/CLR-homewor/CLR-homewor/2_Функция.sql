CREATE FUNCTION dbo.IsEmailValid (@email NVARCHAR(255))
RETURNS BIT
AS EXTERNAL NAME EmailValidatorAssembly.EmailValidator.IsValidEmail;
-- имя сборки.имя класса.имя метода

