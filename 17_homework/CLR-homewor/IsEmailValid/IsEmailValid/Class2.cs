using System;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

public class EmailValidator
{
    [SqlFunction]
    public static SqlBoolean IsValidEmail(SqlString email)
    {
        // Проверка на null
        if (email.IsNull)
        {
            return SqlBoolean.False; // Возвращаем false для null
        }

        // Регулярное выражение для проверки правильности email
        string pattern = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

        // Выполняем проверку формата
        bool isValidFormat = Regex.IsMatch(email.Value, pattern);

        return new SqlBoolean(isValidFormat); // Возврат результата проверки
    }
}