/*
Purpose:
- Temporarily lower and then restore SQL Server max memory to encourage memory release.

Customization:
- Adjust the memory values to match your environment before execution.
*/

USE [master]
GO
/****** Object:  StoredProcedure [dbo].[CommandCleanMemory] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CommandCleanMemory]
AS
BEGIN
    DECLARE @ReducedMemoryMB INT = 10240;
    DECLARE @RestoredMemoryMB INT = 32768;

    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;

    EXEC sp_configure 'max server memory', @ReducedMemoryMB;
    RECONFIGURE;

    WAITFOR DELAY '00:02:00';

    EXEC sp_configure 'max server memory', @RestoredMemoryMB;
    RECONFIGURE;
END
