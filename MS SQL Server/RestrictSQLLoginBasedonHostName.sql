/*
 Restrict SQL Login on a MS SQL Database based on Host Name

*/
USE master;  
GO
CREATE TRIGGER host_name_reject_trigger
ON ALL SERVER
FOR LOGON  
AS
BEGIN
    IF HOST_NAME() in (N'bad_host', N'worse_host', N'the_worst')
        ROLLBACK;
END;