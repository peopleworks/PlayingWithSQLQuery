/*
Purpose:
- Identify candidate rows that can fill missing sequence values in a table.

Safety:
- The UPDATE statement remains commented on purpose.
- Replace table and metadata references before execution.
*/

DO $$
DECLARE
    missing_row RECORD;
    row_to_update RECORD;
    min_record NUMERIC(10) := (SELECT MIN(__record) FROM ccclief0);
    max_record NUMERIC(10) := (
        SELECT record_count
        FROM public."alaska-software.isam.tables"
        WHERE table_name = 'ccclief0'
        LIMIT 1
    );
BEGIN
    FOR missing_row IN
        SELECT s.i AS missing_cmd
        FROM generate_series(min_record, max_record) AS s(i)
        WHERE NOT EXISTS (
            SELECT 1
            FROM ccclief0
            WHERE __record = s.i
        )
    LOOP
        FOR row_to_update IN
            SELECT __record
            FROM ccclief0
            WHERE __record > max_record
        LOOP
            -- UPDATE ccclief0
            -- SET __record = missing_row.missing_cmd
            -- WHERE __record = row_to_update.__record;
            RAISE NOTICE 'Number % is going to replace % and max record is %',
                missing_row.missing_cmd,
                row_to_update.__record,
                max_record;
            EXIT;
        END LOOP;
    END LOOP;
END $$;
