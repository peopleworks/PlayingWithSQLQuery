/*
Restrict Access Per Application
*/
CREATE TRIGGER RestrictAccessPerApplication
ON ALL SERVER
FOR LOGON
AS
BEGIN
      IF
      (PROGRAM_NAME() = 'Microsoft® Access' AND HOST_NAME() = 'WORKSTATION_01')
      BEGIN
            ROLLBACK;
      END
END
