/*
Purpose:
- Validate an address through the Google Address Validation API and return parsed location data.

Security:
- Inject the API key at runtime or load it from a secure configuration source.
- Do not commit secrets into this procedure definition.
*/

CREATE PROCEDURE spAddressvalidation
    @Address varchar(80) = NULL OUTPUT,
    @City varchar(40) = NULL OUTPUT,
    @State varchar(40) = NULL OUTPUT,
    @Country varchar(40) = NULL OUTPUT,
    @PostalCode varchar(20) = NULL OUTPUT,
    @County varchar(40) = NULL OUTPUT,
    @GPSLatitude numeric(9,6) = NULL OUTPUT,
    @GPSLongitude numeric(9,6) = NULL OUTPUT,
    @MapURL varchar(1024) = NULL OUTPUT,
    @AddressText varchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @URL varchar(MAX)
    SET @URL = 'https://addressvalidation.googleapis.com/v1:validateAddress?key=' -- Replace with your actual API key

    -- Create JSON request body
    DECLARE @RequestBody NVARCHAR(MAX);
    SET @RequestBody = N'{
        "address": {
            "regionCode": "' + ISNULL(@Country, '') + N'",
            "addressLines": ["' + ISNULL(@AddressText, '') + N'"]
        },
        "previousResponseId": "",
        "enableUspsCass": false
    }';

    PRINT @RequestBody  -- Debugging: Print the request body

    DECLARE @Response varchar(8000)
    DECLARE @Obj int
    DECLARE @Result int
    DECLARE @HTTPStatus int
    DECLARE @ErrorMsg varchar(MAX)

    EXEC @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Obj OUT

    BEGIN TRY
        EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'POST', @URL, false
        EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
        EXEC @Result = sp_OAMethod @Obj, 'send', NULL, @RequestBody
        EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT
        EXEC @Result = sp_OAGetProperty @Obj, 'responseText', @Response OUT
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ERROR_MESSAGE()
    END CATCH

    EXEC @Result = sp_OADestroy @Obj

    IF (@ErrorMsg IS NOT NULL) OR (@HTTPStatus <> 200) BEGIN
        --Improved error handling with response details
        DECLARE @HTTPStatusMessage VARCHAR(255);
        SELECT @HTTPStatusMessage = CASE
            WHEN @HTTPStatus = 400 THEN 'Bad Request'
            WHEN @HTTPStatus = 403 THEN 'Forbidden. Check API Key and Address Validation API enablement.'
            ELSE 'Unknown Error'
        END;

        SET @ErrorMsg = 'Error in spGeocode <>: HTTP result is ' + CAST(@HTTPStatus AS VARCHAR(3)) + ' (' + @HTTPStatusMessage + '). ' + ISNULL(@ErrorMsg, '') + ' Response: ' + ISNULL(@Response, '');
        RAISERROR(@ErrorMsg, 16, 1)
        RETURN
    END

    -- JSON parsing using JSON_VALUE
    SET @GPSLatitude = JSON_VALUE(@Response, '$.result.geocode.location.latitude');
    SET @GPSLongitude = JSON_VALUE(@Response, '$.result.geocode.location.longitude');
    SET @Address = JSON_VALUE(@Response, '$.result.address.formattedAddress');
    SET @City = JSON_VALUE(@Response, '$.result.address.postalAddress.locality');
    SET @State = JSON_VALUE(@Response, '$.result.address.postalAddress.administrativeArea');
    SET @PostalCode = JSON_VALUE(@Response, '$.result.address.postalAddress.postalCode');
    SET @Country = JSON_VALUE(@Response, '$.result.address.postalAddress.regionCode');

    SET @MapURL = 'https://www.google.com/maps/search/?api=1&query=' + ISNULL(CAST(@GPSLatitude AS VARCHAR(20)), '') + ',' + ISNULL(CAST(@GPSLongitude AS VARCHAR(20)), '');

    -- Return the parsed data
    SELECT 
        @GPSLatitude AS GPSLatitude,
        @GPSLongitude AS GPSLongitude,
        @City AS City,
        @State AS [State],
        @PostalCode AS PostalCode,
        @Address AS [Address],
        @MapURL AS MapURL
END

