
DECLARE @rowCount BIGINT
DECLARE @currentIdentity BIGINT
DECLARE @newIdentity BIGINT
DECLARE @partitionNumber INT
DECLARE @leftBoundary BIGINT
DECLARE @rightBoundary BIGINT
DECLARE @sql NVARCHAR(1000)

-- Use transaction to lock the table for table switching
-- Try to minimize code and reduce as much wait time as possible
BEGIN TRY
BEGIN TRANSACTION

-- Step 1 : Get the row count of the temp table
SELECT @rowCount = COUNT(0) FROM dbo.Staging_uszips

-- Step 2 : Get the last identity of the main table
SET @currentIdentity = CONVERT(BIGINT, IDENT_CURRENT('[dbo].[uszips]'))

-- Step 3 : Get the boundary base on number of record to be inserted
-- This identity = 1 check is required when the table is empty, left boundary must be 0
IF @currentIdentity = 1
       SET @leftBoundary = @currentIdentity - 1
ELSE
       SET @leftBoundary = @currentIdentity
SET @rightBoundary = @leftBoundary + @rowCount

-- Step 4 : Reseed the table with the new identity for other session to insert new record with latest identity and avoid duplicate key constraint failure while table switching
-- Also to reserve identity for the temp table
DBCC CHECKIDENT('uszips', RESEED, @rightBoundary)

PRINT 'Row Count : ' + CONVERT(VARCHAR, @rowCount)
PRINT 'Current Identity : ' + CONVERT(VARCHAR, @currentIdentity)
PRINT 'Left Boundary : ' + CONVERT(VARCHAR, @leftBoundary)
PRINT 'Right Boundary : ' + CONVERT(VARCHAR, @rightBoundary)

-- Step 5 : Update temp table identity base on the main table current identity to solve the identity constraint check challenge
-- When you have the identity value in proper order start from 1, 2, 3, 4... in your temp table
-- And, the last identity before the partition to be switched is 8592
-- Update all the identity in the temp table to 8592+1, 8592+2, 8592+3, 8592+4...
-- End result you will not have duplicate key error occur when switching table
UPDATE [dbo].[Staging_uszips]
SET oid = oid + @leftBoundary

-- Step 6 : Get the partition number base on the new boundary value
SELECT @partitionNumber = $PARTITION.ZipIntegerPartitionFunction(@rightBoundary)
PRINT 'Partition Number : ' + CONVERT(VARCHAR, @partitionNumber)

-- Step 7 : Add check constraint to temp table to fulfill the criteria for table partition switching
SET @sql = '
ALTER TABLE [dbo].[Staging_uszips] WITH CHECK ADD CONSTRAINT [chk_Staging_uszips_partition_' + CONVERT(VARCHAR, @partitionNumber) + '] CHECK ([Oid]>N''' + CONVERT(VARCHAR, @leftBoundary) + ''' AND [Oid]<=N''' + CONVERT(VARCHAR, @rightBoundary) + ''')
ALTER TABLE [dbo].[Staging_uszips] CHECK CONSTRAINT [chk_Staging_uszips_partition_' + CONVERT(VARCHAR, @partitionNumber) + ']
'
PRINT @sql
EXEC sp_executesql @sql

-- Step 8 : Switch the partition
ALTER TABLE [dbo].[Staging_uszips]
SWITCH TO [dbo].[uszips]
PARTITION @partitionNumber;

-- Step 9 : Merge previous partition with the partition of previous partition
ALTER PARTITION FUNCTION ZipIntegerPartitionFunction()
MERGE RANGE (@rightBoundary);

ALTER PARTITION FUNCTION ZipIntegerPartitionFunction()
MERGE RANGE (@leftBoundary);

-- Optional 1 : Drop the temp table
--DROP TABLE [dbo].[Staging_uszips]

-- Optional 2 : Truncate table then drop the check constraint
SET @sql = '
ALTER TABLE [dbo].[Staging_uszips] DROP CONSTRAINT [chk_Staging_uszips_partition_' + CONVERT(VARCHAR, @partitionNumber) + ']
'
PRINT @sql
EXEC sp_executesql @sql

COMMIT TRANSACTION
END TRY
BEGIN CATCH
       SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
       ROLLBACK TRANSACTION
END CATCH
