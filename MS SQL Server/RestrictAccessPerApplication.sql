/*
Purpose:
- Deny SQL Server logins opened from a specific client application and workstation.

Customization:
- Replace the placeholder values before enabling the logon trigger.
*/

CREATE TRIGGER RestrictAccessPerApplication
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @RestrictedProgram NVARCHAR(128) = N'<APPLICATION_NAME>';
    DECLARE @RestrictedHost NVARCHAR(128) = N'<WORKSTATION_NAME>';

    IF PROGRAM_NAME() = @RestrictedProgram
       AND HOST_NAME() = @RestrictedHost
    BEGIN
        ROLLBACK;
    END
END
