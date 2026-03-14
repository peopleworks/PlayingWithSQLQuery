/*
Purpose:
- Show two ways to query a remote PostgreSQL source with dblink.

Customization:
- Replace placeholder connection values and remote object names before execution.
- Keep credentials outside source control.
*/

SELECT *
FROM table1 AS tb1
LEFT JOIN (
    SELECT *
    FROM dblink(
        'dbname=<REMOTE_DATABASE>',
        'SELECT id, code FROM <REMOTE_TABLE>'
    ) AS tb2(id INT, code TEXT)
) AS tb2
    ON tb2.code = tb1.column;

SELECT *
FROM dblink(
    'dbname=<REMOTE_DATABASE> port=<REMOTE_PORT> host=<REMOTE_HOST> user=<REMOTE_USER> password=<REMOTE_PASSWORD>',
    'SELECT coddoc, numdoc FROM <REMOTE_TABLE>'
) AS tb2(coddoc NUMERIC, numdoc NUMERIC)
ORDER BY coddoc;
