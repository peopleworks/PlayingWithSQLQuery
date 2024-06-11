BEGIN TRY 

DECLARE 
@PartitionManagementID INT,
@TableName NVARCHAR(50),
@SQLPartitionText NVARCHAR(MAX),
@UpdateDate DATETIME;

-- Fetch partition information from PartitionManagement
SELECT
  TOP 1 @PartitionManagementID = PartitionManagementID,
  @TableName = TableName,
  @SQLPartitionText = SQLPartitionText,
  @UpdateDate = UpdateDate
FROM
  PartitionManagement;

-- Choose the latest record based on UpdateDate
DECLARE @PartitionValues NVARCHAR(MAX);

-- Execute the SQLPartitionText to get partition values and their types
SET
  @PartitionValues = '';

SET
  @SQLPartitionText = 'SELECT * FROM (' + @SQLPartitionText + ') SubQuery';

CREATE TABLE #TempPartitionValues (
  PartitionColumns NVARCHAR(MAX),
  ColumnsTypes NVARCHAR(MAX)
);

INSERT INTO
  #TempPartitionValues (PartitionColumns, ColumnsTypes) EXEC(@SQLPartitionText);

DECLARE @PartitionFunctionParams NVARCHAR(MAX);

SELECT
  @PartitionValues = STRING_AGG(PartitionColumns, ', ')
FROM
  (
    SELECT
      STRING_AGG(CONVERT(NVARCHAR(MAX), ColumnValue), ', ') AS PartitionColumns
    FROM
      (
        SELECT
          value AS ColumnValue
        FROM
          #TempPartitionValues CROSS APPLY STRING_SPLIT(PartitionColumns, ',')
      ) AS SubResult
    GROUP BY
      SubResult.ColumnValue
  ) AS FinalResult;

SET
  @PartitionFunctionParams = (
    SELECT
      TOP 1 ColumnsTypes
    FROM
      #TempPartitionValues
  );

DECLARE @SQLPartitionFunction NVARCHAR(MAX);

SET
  @SQLPartitionFunction = N'CREATE PARTITION FUNCTION PartitionFunctionName (' + @PartitionFunctionParams + ') AS RANGE RIGHT FOR VALUES (' + @PartitionValues + ');';

EXEC (@SQLPartitionFunction);

-- Insert partition function elements into PartitionManagementDetail
INSERT INTO
  PartitionManagementDetail (PartitionManagementID, Line, Text)
SELECT
  @PartitionManagementID,
  ROW_NUMBER() OVER(
    ORDER BY
      (
        SELECT
          NULL
      )
  ) AS Line,
  ColumnValue
FROM
  (
    SELECT
      value AS ColumnValue
    FROM
      #TempPartitionValues CROSS APPLY STRING_SPLIT(PartitionColumns, ',')
  ) AS SubResult
GROUP BY
  ColumnValue;

-- Display the generated SQL for Partition Function creation
PRINT 'Generated SQL for Partition Function:';

PRINT @SQLPartitionFunction;

-- Display the inserted partition function elements
PRINT 'Partition Function Elements:';

SELECT
  *
FROM
  PartitionManagementDetail
WHERE
  PartitionManagementID = @PartitionManagementID;

DROP TABLE #TempPartitionValues;

END TRY 

BEGIN CATCH 
PRINT 'An error occurred: ' + ERROR_MESSAGE();

-- Drop temporary table if an error occurs
IF OBJECT_ID('tempdb..#TempPartitionValues') IS NOT NULL DROP TABLE #TempPartitionValues;


END CATCH