--Простая проверка на соответствие e-mai формату записи RFC 5322
--Наличие @ и отсутствие символов после домена
--0=False
--1=True

SELECT dbo.IsEmailValid('user.name@domain.com') AS IsValid;
SELECT dbo.IsEmailValid('user.name@domain.com ') AS IsValid;
SELECT dbo.IsEmailValid('user.name@domain.com1') AS IsValid;