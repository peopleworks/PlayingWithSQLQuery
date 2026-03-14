/*
Purpose:
- Geocode an address from SQL Server through the Google Geocoding API.

Security:
- Supply API access securely outside source control.
- Review the use of OLE Automation before enabling in production.
*/

CREATE PROCEDURE spGeocode
    @Address VARCHAR(80) = NULL OUTPUT,
    @City VARCHAR(40) = NULL OUTPUT,
    @State VARCHAR(40) = NULL OUTPUT,
    @Country VARCHAR(40) = NULL OUTPUT,
    @PostalCode VARCHAR(20) = NULL OUTPUT,
    @County VARCHAR(40) = NULL OUTPUT,
    @GPSLatitude NUMERIC(9, 6) = NULL OUTPUT,
    @GPSLongitude NUMERIC(9, 6) = NULL OUTPUT,
    @MapURL VARCHAR(1024) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @URL VARCHAR(MAX);
    SET @URL = 'https://maps.googleapis.com/maps/api/geocode/xml?sensor=false&address=' +
        CASE WHEN @Address IS NOT NULL THEN @Address ELSE '' END +
        CASE WHEN @City IS NOT NULL THEN ', ' + @City ELSE '' END +
        CASE WHEN @State IS NOT NULL THEN ', ' + @State ELSE '' END +
        CASE WHEN @PostalCode IS NOT NULL THEN ', ' + @PostalCode ELSE '' END +
        CASE WHEN @Country IS NOT NULL THEN ', ' + @Country ELSE '' END;
    SET @URL = REPLACE(@URL, ' ', '+');

    DECLARE @Response VARCHAR(8000);
    DECLARE @XML XML;
    DECLARE @Obj INT;
    DECLARE @Result INT;
    DECLARE @HTTPStatus INT;
    DECLARE @ErrorMsg VARCHAR(MAX);

    EXEC @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Obj OUT;

    BEGIN TRY
        EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false;
        EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded';
        EXEC @Result = sp_OAMethod @Obj, 'send', NULL, '';
        EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT;
        EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml', @Response OUT;
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ERROR_MESSAGE();
    END CATCH

    EXEC @Result = sp_OADestroy @Obj;

    IF (@ErrorMsg IS NOT NULL) OR (@HTTPStatus <> 200)
    BEGIN
        SET @ErrorMsg = 'Error in spGeocode: ' + ISNULL(@ErrorMsg, 'HTTP result is: ' + CAST(@HTTPStatus AS VARCHAR(10)));
        RAISERROR(@ErrorMsg, 16, 1, @HTTPStatus);
        RETURN;
    END

    SET @XML = CAST(@Response AS XML);

    SET @GPSLatitude = @XML.value('(/GeocodeResponse/result/geometry/location/lat)[1]', 'numeric(9,6)');
    SET @GPSLongitude = @XML.value('(/GeocodeResponse/result/geometry/location/lng)[1]', 'numeric(9,6)');
    SET @City = @XML.value('(/GeocodeResponse/result/address_component[type="locality"]/long_name)[1]', 'varchar(40)');
    SET @State = @XML.value('(/GeocodeResponse/result/address_component[type="administrative_area_level_1"]/short_name)[1]', 'varchar(40)');
    SET @PostalCode = @XML.value('(/GeocodeResponse/result/address_component[type="postal_code"]/long_name)[1]', 'varchar(20)');
    SET @Country = @XML.value('(/GeocodeResponse/result/address_component[type="country"]/short_name)[1]', 'varchar(40)');
    SET @County = @XML.value('(/GeocodeResponse/result/address_component[type="administrative_area_level_2"]/short_name)[1]', 'varchar(40)');
    SET @Address =
        ISNULL(@XML.value('(/GeocodeResponse/result/address_component[type="street_number"]/long_name)[1]', 'varchar(40)'), '???') + ' ' +
        ISNULL(@XML.value('(/GeocodeResponse/result/address_component[type="route"]/long_name)[1]', 'varchar(40)'), '???');
    SET @MapURL = 'https://www.google.com/maps?q=' + CAST(@GPSLatitude AS VARCHAR(20)) + '+' + CAST(@GPSLongitude AS VARCHAR(20));

    SELECT
        @GPSLatitude AS GPSLatitude,
        @GPSLongitude AS GPSLongitude,
        @City AS City,
        @State AS [State],
        @PostalCode AS PostalCode,
        @Address AS [Address],
        @County AS County,
        @MapURL AS MapURL,
        @XML AS XMLResults;
END
