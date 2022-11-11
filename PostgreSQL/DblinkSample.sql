SELECT * 
FROM   table1 tb1 
LEFT   JOIN (
   SELECT *
   FROM   dblink('dbname=ilacdb','SELECT id, code FROM cbmovf02')
   AS     tb2(id int, code text);
) AS tb2 ON tb2.column = tb1.column;


SELECT *
   FROM   dblink('dbname=ilacdb port=5432 
            host=localhost user=postgres password=postgres','SELECT coddoc, numdoc FROM cbmovf02')
   AS     tb2( coddoc numeric, numdoc numeric)
   order by coddoc