/*
Purpose:
- Find missing numeric values in a sequence-style column.

Customization:
- Replace 127440, fahhfcf0, and __record with your own upper bound, table, and column.
*/

SELECT s.i AS missing_record
FROM generate_series(1, 127440) AS s(i)
WHERE NOT EXISTS (
    SELECT 1
    FROM fahhfcf0 AS src
    WHERE src.__record = s.i
);
