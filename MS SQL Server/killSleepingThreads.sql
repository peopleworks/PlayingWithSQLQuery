USE [master]
GO
/****** Object:  StoredProcedure [dbo].[killSleepingThreads]    Script Date: 10/19/2023 2:44:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[killSleepingThreads]
as
begin


IF OBJECT_ID('dbo.temp_sp_who2', 'U') IS NOT NULL
BEGIN
DROP TABLE dbo.temp_sp_who2;
END;

CREATE TABLE temp_sp_who2
(
SPID INT
,Status VARCHAR(1000) NULL
,LOGIN SYSNAME NULL
,HostName SYSNAME NULL
,BlkBy SYSNAME NULL
,DBName SYSNAME NULL
,Command VARCHAR(1000) NULL
,CPUTime INT NULL
,DiskIO INT NULL
,LastBatch VARCHAR(1000) NULL
,ProgramName VARCHAR(1000) NULL
,SPID2 INT
, RequestID INT NULL --comment out for SQL 2000 databases
, InsertedDate datetime DEFAULT GETDATE()
);

--This insert can be added to a job that runs periodically.
INSERT INTO temp_sp_who2
(
SPID
,Status
,LOGIN
,HostName
,BlkBy
,DBName
,Command
,CPUTime
,DiskIO
,LastBatch
,ProgramName
,SPID2
,RequestID
)
EXECUTE sp_who2;

DECLARE @KillPrueba nvarchar(MAX) = '';
SELECT @KillPrueba = @KillPrueba + 'Kill ' + CAST(SPID as nVarchar(10)) + char(13)
FROM temp_sp_who2 where  Status = 'sleeping' and DBName not in ('master');

--select * from temp_sp_who2
--print @KillPrueba;
--EXEC @KillPrueba;
EXEC sp_executesql @KillPrueba


end




