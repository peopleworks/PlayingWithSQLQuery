-- MS SQL Server
-- Find a table in all objects

SELECT SCHEMA_NAME(o.schema_id) + '.' + o.name AS [table], 
       'is used by' AS ref, 
       SCHEMA_NAME(ref_o.schema_id) + '.' + ref_o.name AS [object], 
       ref_o.type_desc AS object_type
FROM sys.objects o
     JOIN sys.sql_expression_dependencies dep ON o.object_id = dep.referenced_id
     JOIN sys.objects ref_o ON dep.referencing_id = ref_o.object_id
WHERE o.type IN('V', 'U')
     AND SCHEMA_NAME(o.schema_id) = 'dbo'  -- put schema name here
     AND o.name = 'TipoNegocio'   -- put table/view name here
ORDER BY [object];


-- Find a field in all objects

SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS [No], 
       sys.schemas.name AS [Schema], 
       sys.objects.name AS Object_Name, 
       sys.objects.type_desc AS [Type]
FROM sys.sql_modules(NOLOCK)
     INNER JOIN sys.objects(NOLOCK) ON sys.sql_modules.object_id = sys.objects.object_id
     INNER JOIN sys.schemas(NOLOCK) ON sys.objects.schema_id = sys.schemas.schema_id
WHERE sys.sql_modules.definition COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%TipoNegocioDescripcion%' ESCAPE '\' -- Name of fild inside %
ORDER BY sys.objects.type_desc, 
         sys.schemas.name, 
         sys.objects.name;
