/*
 Update Records with missing numbers
*/
DO $$

DECLARE
    row record;
DECLARE
    rowupdate record;
DECLARE minrecord numeric(10) = (select min(__record) from ccclief0 );
DECLARE maxrecord numeric(10) = (SELECT record_count FROM public."alaska-software.isam.tables" where table_name = 'ccclief0'  limit 1);

BEGIN
    FOR row IN SELECT s.i AS missing_cmd
			   FROM generate_series(minrecord,maxrecord) s(i)
			   WHERE NOT EXISTS (SELECT 1 FROM ccclief0 WHERE __record = s.i) LOOP

		FOR rowupdate IN SELECT __record
			   FROM ccclief0
			   WHERE __record > maxrecord LOOP

			--UPDATE ccclief0 SET __record = row.missing_cmd  WHERE __record = rowupdate.__record ;
			raise notice 'Number % is going to replace % and max record is %',  row.missing_cmd, rowupdate.__record, maxrecord ;
			exit;
		END LOOP;

    END LOOP;
END $$;