SELECT s.i AS missing_cmd
FROM generate_series(1,127440) s(i)
WHERE NOT EXISTS (SELECT 1 FROM fahhfcf0 WHERE __record = s.i); -- Your table here