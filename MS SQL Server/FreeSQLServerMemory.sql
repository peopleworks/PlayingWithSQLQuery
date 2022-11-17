USE [master]
GO
/****** Object:  StoredProcedure [dbo].[CommandCleanMemory]   ***/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CommandCleanMemory]
AS

BEGIN
   
   
  
	Exec sp_configure 'show advanced options', 1 
	RECONFIGURE 
	 
	/*** Drop the max down to 64GB temporarily ***/
	Exec sp_configure 'max server memory', 10240 -- 10 GB
	RECONFIGURE 
	/**** Wait a couple minutes to let SQLServer to naturally release the RAM..... ****/
	WAITFOR DELAY '00:02:00' 

	/** now bump it back up to "lots of RAM"! ****/
	Exec sp_configure 'max server memory', 32768 -- 32 GB
	RECONFIGURE

END
