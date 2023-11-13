-- Find Missing Indexes for All Tables in a Database

CREATE DEFINER=`yourdatabase`@`%` PROCEDURE `yourdatabase`.`FindMissingIndexes`()
begin
	DECLARE done INT DEFAULT 0;
    DECLARE tableName VARCHAR(255);
    DECLARE columnList TEXT;
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME, columns FROM (
            SELECT
				TABLE_NAME,
				GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS columns
			FROM
				information_schema.COLUMNS
			WHERE
				TABLE_SCHEMA = DATABASE() 
			GROUP BY
				TABLE_NAME
        ) AS tbl;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName, columnList;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if an index exists
        SET @indexName := CONCAT('idx_', tableName, '_', REPLACE(columnList, ',', '_'));

        SELECT IFNULL(
            (SELECT 1 FROM information_schema.STATISTICS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME = tableName
               AND INDEX_NAME = @indexName),
            0
        ) INTO @indexExists;

        -- If the index does not exist, generate an SQL statement to create it
        IF @indexExists = 0 THEN
            SET @createIndexSQL := CONCAT('CREATE INDEX ', @indexName, ' ON ', tableName, ' (', columnList, ');');
            SELECT @createIndexSQL AS 'Missing Index SQL';
        END IF;
    END LOOP;

    CLOSE cur;
END;