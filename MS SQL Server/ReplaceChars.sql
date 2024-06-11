/*
* https://www.codeproject.com/Tips/5382272/Small-function-to-replace-characters-with-SQL-Serv
* Small function to replace characters with SQL Server
* Sample(1) : SELECT dbo.ReplaceChars('this% contains ! illegal/ chars', '!"#¤%&/()=?', '')
* Sample(2) : UPDATE MyTable
*             SET MyColumn = dbo.ReplaceChars(MyColumn, '!"#¤%&/()=?', '');
*/

CREATE FUNCTION ReplaceChars(@stringToReplace nvarchar(MAX),
                             @charsToReplace nvarchar(100),
                             @replacement nvarchar(1))
RETURNS nvarchar(MAX) AS
BEGIN
   DECLARE @returnData  nvarchar(MAX);

   WITH
      CharsToReplace (Chars) AS (
         SELECT @charsToReplace
      ),
      InputData (InputString) AS (
         SELECT @stringToReplace
      ),
      ReplaceLoop (Position, SingleChar, OutputString) AS (
         SELECT 1                                AS Position,
                SUBSTRING(ctr.Chars, 1, 1)       AS SingleChar,
                REPLACE(id.InputString,
                     SUBSTRING(ctr.Chars, 1, 1),
                     @replacement)               AS OutputString
         FROM        CharsToReplace ctr
         CROSS APPLY InputData      id
         UNION ALL
         SELECT rl.Position + 1                                AS Position,
                SUBSTRING(ctr.chars, rl.position + 1, 1)       AS SingleChar,
                REPLACE(rl.OutputString,
                     SUBSTRING(ctr.chars, rl.Position + 1, 1),
                     @replacement)                             AS OutputString
         FROM        CharsToReplace ctr
         CROSS APPLY ReplaceLoop    rl
         WHERE LEN(ctr.Chars) > rl.Position
      )
   SELECT @returnData = rl.OutputString
   FROM ReplaceLoop rl
   ORDER BY rl.position DESC
   OFFSET 0 ROWS
   FETCH FIRST 1 ROWS ONLY;

   RETURN (@returnData);
END;