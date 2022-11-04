-- Search and Replace MS SQL Server


SET NOCOUNT ON 
DECLARE @stringToFind VARCHAR(100) 
DECLARE @stringToReplace VARCHAR(100) 
DECLARE @schema sysname 
DECLARE @table sysname 
DECLARE @count INT 
DECLARE @sqlCommand VARCHAR(8000) 
DECLARE @where VARCHAR(8000) 
DECLARE @columnName sysname 
DECLARE @object_id INT 
                     
SET @stringToFind = 'Smith' 
SET @stringToReplace = 'Jones' 
                        
DECLARE TAB_CURSOR CURSOR  FOR 
SELECT   B.NAME      AS SCHEMANAME, 
         A.NAME      AS TABLENAME, 
         A.OBJECT_ID 
FROM     sys.objects A 
         INNER JOIN sys.schemas B 
           ON A.SCHEMA_ID = B.SCHEMA_ID 
WHERE    TYPE = 'U' 
ORDER BY 1 
          
OPEN TAB_CURSOR 
FETCH NEXT FROM TAB_CURSOR 
INTO @schema, 
     @table, 
     @object_id 
      
WHILE @@FETCH_STATUS = 0 
  BEGIN 
    DECLARE COL_CURSOR CURSOR FOR 
    SELECT A.NAME 
    FROM   sys.columns A 
           INNER JOIN sys.types B 
             ON A.SYSTEM_TYPE_ID = B.SYSTEM_TYPE_ID 
    WHERE  OBJECT_ID = @object_id 
           AND IS_COMPUTED = 0 
           AND B.NAME IN ('char','nchar','nvarchar','varchar','text','ntext') 
OPEN COL_CURSOR 
     
    FETCH NEXT FROM COL_CURSOR 
    INTO @columnName 
     
    WHILE @@FETCH_STATUS = 0 
      BEGIN 
        SET @sqlCommand = 'UPDATE ' + @schema + '.' + @table + ' SET [' + @columnName 
                           + '] = REPLACE(convert(nvarchar(max),[' + @columnName + ']),''' 
                           + @stringToFind + ''',''' + @stringToReplace + ''')' 
         
        SET @where = ' WHERE [' + @columnName + '] LIKE ''%' + @stringToFind + '%''' 
         
        EXEC( @sqlCommand + @where) 
         
        SET @count = @@ROWCOUNT 
         
        IF @count > 0 
          BEGIN 
            PRINT @sqlCommand + @where 
            PRINT 'Updated: ' + CONVERT(VARCHAR(10),@count) 
            PRINT '----------------------------------------------------' 
          END 
         
        FETCH NEXT FROM COL_CURSOR 
        INTO @columnName 
      END 
     
    CLOSE COL_CURSOR 
    DEALLOCATE COL_CURSOR 
     
    FETCH NEXT FROM TAB_CURSOR 
    INTO @schema, 
         @table, 
         @object_id 
  END 
   
CLOSE TAB_CURSOR 
DEALLOCATE TAB_CURSOR 

-- From <https://www.mssqltips.com/sqlservertip/1555/sql-server-find-and-replace-values-in-all-tables-and-all-text-columns/> 
