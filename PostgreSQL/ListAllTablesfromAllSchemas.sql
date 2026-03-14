/*
Purpose:
- List all PostgreSQL base tables across schemas together with table descriptions.
*/

SELECT
    t.table_schema,
    t.table_name,
    obj_description(c.oid)::text AS table_description
FROM information_schema.tables t
JOIN pg_class c
    ON t.table_name = c.relname
   AND t.table_schema = c.relnamespace::regnamespace::text
WHERE t.table_type = 'BASE TABLE'
ORDER BY
    t.table_schema,
    t.table_name;
