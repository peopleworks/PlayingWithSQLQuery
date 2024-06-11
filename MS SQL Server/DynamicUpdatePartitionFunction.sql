BEGIN TRY 
    DECLARE @PartitionManagementID INT,
            @TableName NVARCHAR(50),
            @SQLPartitionText NVARCHAR(MAX),
            @UpdateDate DATETIME;

    -- Fetch partition information from PartitionManagement
    SELECT TOP 1 @PartitionManagementID = PartitionManagementID,
                 @TableName = TableName,
                 @SQLPartitionText = SQLPartitionText,
                 @UpdateDate = UpdateDate
    FROM PartitionManagement;

    -- Choose the latest record based on UpdateDate
    DECLARE @PartitionValues NVARCHAR(MAX);

    -- Execute the SQLPartitionText to get partition values and their types
    SET @PartitionValues = '';

    SET @SQLPartitionText = 'SELECT * FROM (' + @SQLPartitionText + ') SubQuery';

	-- Create Temp Table 
    CREATE TABLE #TempPartitionValues (
        PartitionColumns NVARCHAR(MAX),
        ColumnsTypes NVARCHAR(MAX)
    );

    INSERT INTO #TempPartitionValues (PartitionColumns, ColumnsTypes) EXEC(@SQLPartitionText);

    DECLARE @PartitionFunctionParams NVARCHAR(MAX);

    SELECT @PartitionValues = STRING_AGG(PartitionColumns, ', ')
    FROM (
        SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), ColumnValue), ', ') AS PartitionColumns
        FROM (
            SELECT value AS ColumnValue
            FROM #TempPartitionValues
            CROSS APPLY STRING_SPLIT(PartitionColumns, ',')
        ) AS SubResult
        GROUP BY SubResult.ColumnValue
    ) AS FinalResult;

    SET @PartitionFunctionParams = (
        SELECT TOP 1 ColumnsTypes
        FROM #TempPartitionValues
    );

    DECLARE @NewPartitionValues NVARCHAR(MAX);

    -- Compare current partition values with existing ones in PartitionManagementDetail
    SELECT @NewPartitionValues = STRING_AGG(ColumnValue, ', ')
    FROM (
        SELECT DISTINCT value AS ColumnValue
        FROM #TempPartitionValues
        CROSS APPLY STRING_SPLIT(PartitionColumns, ',')
    ) AS NewValues
    LEFT JOIN PartitionManagementDetail PMD ON NewValues.ColumnValue = PMD.[Text]
    WHERE PMD.PartitionManagementID = @PartitionManagementID
    AND PMD.[Text] IS NULL;

	-- Alter the partition function if there is new range of values 
    IF @NewPartitionValues IS NOT NULL
    BEGIN
        DECLARE @SQLAlterPartitionFunction NVARCHAR(MAX);

        -- Update partition function with new ranges
        SET @SQLAlterPartitionFunction = N'ALTER PARTITION FUNCTION YourPartitionFunctionName() MERGE RANGE (' + @NewPartitionValues + ');';
		-- Print Alter Function
		print @SQLAlterPartitionFunction;
		-- Execute ALter Function
        EXEC (@SQLAlterPartitionFunction);

        -- Insert new partition function elements into PartitionManagementDetail
        INSERT INTO PartitionManagementDetail (PartitionManagementID, Line, Text)
        SELECT @PartitionManagementID,
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Line,
               ColumnValue
        FROM (
            SELECT DISTINCT value AS ColumnValue
            FROM #TempPartitionValues
            CROSS APPLY STRING_SPLIT(PartitionColumns, ',')
        ) AS SubResult
        LEFT JOIN PartitionManagementDetail PMD ON SubResult.ColumnValue = PMD.Text
        WHERE PMD.PartitionManagementID = @PartitionManagementID
        AND PMD.Text IS NULL;
    END;

	-- Drop temp table when finish
    DROP TABLE #TempPartitionValues;

END TRY

BEGIN CATCH 
    PRINT 'An error occurred: ' + ERROR_MESSAGE();

    -- Drop temporary table if an error occurs
    IF OBJECT_ID('tempdb..#TempPartitionValues') IS NOT NULL DROP TABLE #TempPartitionValues;
END CATCH
