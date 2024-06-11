/*
How to check if data has changed in database

*/

SELECT * FROM 
(
    SELECT 
        @@servername as servername 
        , DB_NAME(database_id) as DatabaseName
        , u.object_id
        , SchemaName = OBJECT_SCHEMA_NAME(u.object_id, database_Id)  
        , TableName = OBJECT_NAME(u.object_id, database_id) 
        , Writes =  SUM(user_updates)
        , LastUpdate = CASE WHEN MAX(u.last_user_update) IS NULL THEN CAST('17530101' AS DATETIME) ELSE MAX(u.last_user_update) END
    FROM sys.dm_db_index_usage_stats u
    JOIN sys.indexes i
    ON u.index_id = i.index_id
    AND u.object_id = i.object_id
    WHERE u.database_id = DB_ID()
    GROUP BY database_id, u.object_id
    UNION ALL 
    SELECT 
        @@servername as servername
        , DB_NAME() as DatabaseName 
        , o.object_id
        , OBJECT_SCHEMA_NAME(o.object_id, db_id())
        , object_name(o.object_id, db_id())
        , 0
        , CAST('17530101' AS DATETIME) 
    FROM sys.indexes i
    JOIN sys.objects o ON i.object_id = o.object_id
    WHERE o.type_desc in ('user_table')
    and i.index_id NOT IN (select s.index_id from sys.dm_db_index_usage_stats s where s.object_id=i.object_id 
    and i.index_id=s.index_id and database_id = db_id(db_name()) )
) AS temp 
ORDER BY writes DESC

