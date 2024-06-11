IF OBJECT_ID('dbo.fn_TitleCase') IS NOT NULL
DROP FUNCTION dbo.fn_TitleCase;
GO
CREATE FUNCTION dbo.fn_TitleCase
(
    @Input nvarchar(1000)
)
RETURNS TABLE
AS
RETURN
SELECT Item = STRING_AGG(splits.Word, ' ')
FROM (
    SELECT Word = UPPER(LEFT(value, 1)) + LOWER(RIGHT(value, LEN(value) - 1))
    FROM STRING_SPLIT(@Input, ' ')
    ) splits(Word);
GO

SELECT *
FROM dbo.fn_TitleCase('this is a test');