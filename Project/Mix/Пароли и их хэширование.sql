--��������� ���������� ������--
declare @idx as int
declare @randomPwd as nvarchar(64)
declare @rnd as float 
select @idx = 0
select @randomPwd = N''
select @rnd = rand((@@CPU_BUSY % 100) + ((@@IDLE % 100) * 100) + 
       (DATEPART(ss, GETDATE()) * 10000) + ((cast(DATEPART(ms, GETDATE()) as int) % 100) * 1000000))


while @idx < 16
begin
   select @randomPwd = @randomPwd + char((cast((@rnd * 83) as int) + 43))
   select @idx = @idx + 1
select @rnd = rand()
end

select @randomPwd

------------����������� ������ ��� �������� � ������� ----------------------

DECLARE @HashThis NVARCHAR(32), @HashThat VARBINARY (max);
SET @HashThis = CONVERT(NVARCHAR(32),'test');  -- � ������ ������� test - ��� ������ ������������
SET @HashThat=HASHBYTES('SHA2_256', @HashThis);
SELECT @HashThat
SELECT CONVERT(VARCHAR(max), @HashThat, 2) AS [HexStringWithout0x]

------------------��������� ������� ��������� ���������� ������----------------------------
SELECT CRYPT_GEN_RANDOM(5)


