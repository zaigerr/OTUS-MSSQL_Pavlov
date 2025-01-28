  -- включаю поддержку CLR на уровне сервера
  sp_configure 'clr enabled', 1;
   RECONFIGURE;


   CREATE ASSEMBLY EmailValidatorAssembly
   FROM 'C:\Temp\IsEmailValid\IsEmailValid\bin\Release\IsEmailValid.dll'
   WITH PERMISSION_SET = SAFE;


