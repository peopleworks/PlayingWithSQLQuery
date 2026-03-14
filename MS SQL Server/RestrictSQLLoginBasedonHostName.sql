/*
Purpose:
- Restrict SQL Server logins based on the client host name.

Customization:
- Replace the placeholder host names before enabling the logon trigger.
*/

USE [master]
GO

CREATE TRIGGER host_name_reject_trigger
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @RejectedHosts TABLE (HostName NVARCHAR(128));

    INSERT INTO @RejectedHosts (HostName)
    VALUES
        (N'<HOST_NAME_1>'),
        (N'<HOST_NAME_2>'),
        (N'<HOST_NAME_3>');

    IF EXISTS (
        SELECT 1
        FROM @RejectedHosts
        WHERE HostName = HOST_NAME()
    )
    BEGIN
        ROLLBACK;
    END
END;
