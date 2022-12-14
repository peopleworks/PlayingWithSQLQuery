USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Cleansleepingjobs]    Script Date: 12/9/2022 10:36:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Cleansleepingjobs]
AS
  BEGIN
      DECLARE @user_spid INT
      DECLARE curspid CURSOR fast_forward FOR
        SELECT spid
        FROM   master.dbo.sysprocesses (nolock)
        WHERE  spid > 50 -- avoid system threads
               AND status = 'sleeping' -- only sleeping threads
               AND Datediff(hour, last_batch, Getdate()) >= 1
               -- thread sleeping for 24 hours
               AND spid <> @@spid -- ignore current spid

      OPEN curspid

      FETCH next FROM curspid INTO @user_spid

      WHILE ( @@FETCH_STATUS = 0 )
        BEGIN
            PRINT 'Killing ' + CONVERT(VARCHAR, @user_spid)

            EXEC('KILL '+@user_spid)

            FETCH next FROM curspid INTO @user_spid
        END

      CLOSE curspid

      DEALLOCATE curspid
  END 