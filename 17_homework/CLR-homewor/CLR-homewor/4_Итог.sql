--������� �������� �� ������������ e-mai ������� ������ RFC 5322
--������� @ � ���������� �������� ����� ������
--0=False
--1=True

SELECT dbo.IsEmailValid('user.name@domain.com') AS IsValid;
SELECT dbo.IsEmailValid('user.name@domain.com ') AS IsValid;
SELECT dbo.IsEmailValid('user.name@domain.com1') AS IsValid;