/*
Purpose:
- Block SQL Server logins from specific IP addresses or wildcard ranges.

Customization:
- Populate the optional values section with approved blocked addresses before enabling the trigger.
*/

-- 1. Create a table to store blocked IP addresses or wildcard ranges.
CREATE TABLE master.dbo.IPBLock (
    ipaddress VARCHAR(50)
);

-- 2. Create a server logon trigger.
CREATE TRIGGER block_ipaddress
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @capturedip NVARCHAR(50);
    DECLARE @IPRange VARCHAR(50);

    SET @capturedip = (
        SELECT EVENTDATA().value('(/EVENT_INSTANCE/ClientHost)[1]', 'NVARCHAR(50)')
    );

    IF EXISTS (
        SELECT 1
        FROM master.dbo.IPBLock
        WHERE ipaddress = @capturedip
    )
    BEGIN
        PRINT 'Your IP address is blocked. Contact the administrator.';
        ROLLBACK;
    END
    ELSE
    BEGIN
        SELECT @IPRange =
            SUBSTRING(@capturedip, 1, LEN(@capturedip) - CHARINDEX('.', REVERSE(@capturedip))) + '.*';

        IF EXISTS (
            SELECT 1
            FROM master.dbo.IPBLock
            WHERE ipaddress = @IPRange
        )
        BEGIN
            PRINT 'Your IP address range is blocked. Contact the administrator.';
            ROLLBACK;
        END
    END
END
GO

-- 3. Optional seed data for testing. Replace NULL values before use.
DECLARE @BlockedIp1 VARCHAR(50) = NULL;
DECLARE @BlockedIp2 VARCHAR(50) = NULL;
DECLARE @BlockedIpRange VARCHAR(50) = NULL;

INSERT INTO master.dbo.IPBLock (ipaddress)
SELECT value_to_block
FROM (VALUES (@BlockedIp1), (@BlockedIp2), (@BlockedIpRange)) AS blocked(value_to_block)
WHERE value_to_block IS NOT NULL;
