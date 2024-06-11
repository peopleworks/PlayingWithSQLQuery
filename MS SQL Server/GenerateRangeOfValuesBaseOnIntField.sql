SELECT 
    (oid / 10000) * 10000 AS range_start, 
    ((oid / 10000) + 1) * 10000 AS range_end
FROM uszips
JOIN (SELECT 10000 AS min_int_field, MAX(oid) AS max_int_field FROM uszips) CTE ON 1 = 1
WHERE oid BETWEEN CTE.min_int_field AND CTE.max_int_field
GROUP BY (oid / 10000)
ORDER BY range_start


SELECT 
    (oid / 10000) * 10000 AS range_start
FROM uszips
JOIN (SELECT 10000 AS min_int_field, MAX(oid) AS max_int_field FROM uszips) CTE ON 1 = 1
WHERE oid BETWEEN CTE.min_int_field AND CTE.max_int_field
GROUP BY (oid / 10000)
ORDER BY range_start