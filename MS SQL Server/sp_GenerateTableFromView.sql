/*
Purpose:
- Generate a CREATE TABLE statement based on the columns exposed by a view.
*/

CREATE OR ALTER PROCEDURE dbo.sp_GenerateTableFromView
    @ViewName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = '';

    -- Build column definitions from the view metadata.
    SELECT @SQL = STRING_AGG(
        '    [' + c.name + '] ' +
        t.name +
        CASE
            WHEN t.name IN ('varchar', 'char', 'varbinary', 'binary', 'nvarchar', 'nchar')
                THEN '(' + CASE
                    WHEN c.max_length = -1 THEN 'MAX'
                    ELSE CAST(CASE WHEN t.name LIKE 'n%' THEN c.max_length / 2 ELSE c.max_length END AS VARCHAR(10))
                END + ')'
            ELSE ''
        END +
        CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END,
        ',' + CHAR(13)
    )
    FROM sys.columns c
    JOIN sys.types t
        ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(@ViewName);

    -- Wrap the generated columns into a CREATE TABLE statement.
    SET @SQL = 'CREATE TABLE ' + QUOTENAME(@ViewName + '_Table') + CHAR(13) +
               '(' + CHAR(13) + @SQL + CHAR(13) + ');';

    PRINT @SQL;
END
GO
