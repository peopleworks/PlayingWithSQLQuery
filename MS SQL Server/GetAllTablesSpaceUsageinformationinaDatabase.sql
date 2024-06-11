-- Get All Tables Space Usage information in a Database

IF OBJECT_ID('tempdb..#SpaceUsed') IS NOT NULL
	DROP TABLE #SpaceUsed

CREATE TABLE #SpaceUsed (
	 TableName sysname
	,NumRows BIGINT
	,ReservedSpace VARCHAR(50)
	,DataSpace VARCHAR(50)
	,IndexSize VARCHAR(50)
	,UnusedSpace VARCHAR(50)
	) 

DECLARE @str VARCHAR(500)
SET @str =  'exec sp_spaceused ''?'''
INSERT INTO #SpaceUsed 
EXEC sp_msforeachtable @command1=@str

SELECT TableName, NumRows, 
CONVERT(numeric(18,0),REPLACE(ReservedSpace,' KB','')) / 1024 as ReservedSpace_MB,
CONVERT(numeric(18,0),REPLACE(DataSpace,' KB','')) / 1024 as DataSpace_MB,
CONVERT(numeric(18,0),REPLACE(IndexSize,' KB','')) / 1024 as IndexSpace_MB,
CONVERT(numeric(18,0),REPLACE(UnusedSpace,' KB','')) / 1024 as UnusedSpace_MB
FROM #SpaceUsed
ORDER BY ReservedSpace_MB desc