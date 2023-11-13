-- Reorganize and Rebuild Indexes for All Tables in a Database

CREATE DEFINER=`yourdatabase`@`%` PROCEDURE `yourdatabase`.`ReorganizeRebuildIndexes`()
begin
	DECLARE done INT DEFAULT 0;
    DECLARE tableName VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME FROM (
           SELECT TABLE_NAME
			FROM information_schema.TABLES
			WHERE TABLE_SCHEMA = DATABASE() and TABLE_TYPE = 'BASE TABLE'
        ) AS tbl ;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Reorganize and rebuild indexes for the table
        SET @sql := CONCAT('ALTER TABLE ', tableName, ' FORCE;');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END;