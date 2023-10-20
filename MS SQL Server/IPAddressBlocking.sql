/*
 IP Address Blocking or Restriction in SQL Server

*/

-- 1. Create Table for IP List
CREATE TABLE master.dbo.IPBLock (ipaddress VARCHAR(15))

-- 2. Create a DDL Logon trigger 
CREATE TRIGGER block_ipaddress
ON ALL SERVER
FOR LOGON
AS
BEGIN
            DECLARE @capturedip NVARCHAR(15);
            SET @capturedip = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/ClientHost)[1]', 'NVARCHAR(15)'));
            IF EXISTS(SELECT ipaddress FROM master.dbo.IPBLock WHERE ipaddress = @capturedip)
            BEGIN
                        Print 'Your IP Address is blocked, Contact Administrator'
                        ROLLBACK
            END
            ELSE
            BEGIN
                        DECLARE @IPRange VARCHAR(15)
                        SELECT @IPRange= SUBSTRING(@capturedip,1,LEN(@capturedip)-CHARINDEX('.',REVERSE(@capturedip)))+'.*'
                        IF EXISTS(SELECT ipaddress FROM master.dbo.IPBLock WHERE ipaddress = @IPRange)
                        BEGIN
                            Print 'Your IP Address Range is blocked, Contact Administrator'
                            ROLLBACK
                        END
            END
END
GO 

-- 3. Testing the Trigger
INSERT INTO IPBLock VALUES('192.168.1.3')
INSERT INTO IPBLock VALUES('192.168.1.4')
INSERT INTO IPBLock VALUES('10.100.25.*')



