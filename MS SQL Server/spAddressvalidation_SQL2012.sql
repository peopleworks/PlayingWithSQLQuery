/*
Purpose:
- SQL Server 2012-compatible address validation procedure using manual JSON parsing.

Security:
- Inject the API key at runtime or load it from a secure configuration source.
- Do not commit secrets into this procedure definition.
*/

USE [YourDatabaseName]
GO
/****** Object:  StoredProcedure [dbo].[spAddressvalidation]    Script Date: 10/18/2024 9:21:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spAddressvalidation]
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

      -- Clean the JSON response
    SET @Response = REPLACE(REPLACE(REPLACE(REPLACE(@Response, CHAR(13), ''), CHAR(10), ''), CHAR(9), ''), ' ', '');

	Begin Try


		-- Function to extract string values
		DECLARE @ExtractStringValue NVARCHAR(4000)
		DECLARE @ExtractNumericValue NVARCHAR(4000)

		-- Extract formattedAddress (@Address)
		DECLARE @AddressKey NVARCHAR(255) = '"formattedAddress":"';
		DECLARE @AddressStart INT = CHARINDEX(@AddressKey, @Response);
		IF @AddressStart > 0
		BEGIN
			SET @AddressStart = @AddressStart + LEN(@AddressKey);
			DECLARE @AddressEnd INT = CHARINDEX('"', @Response, @AddressStart);
			SET @Address = SUBSTRING(@Response, @AddressStart, @AddressEnd - @AddressStart);
		END
		ELSE
		BEGIN
			SET @Address = NULL;
		END

		-- Extract locality (@City)
		DECLARE @CityKey NVARCHAR(255) = '"locality":"';
		DECLARE @CityStart INT = CHARINDEX(@CityKey, @Response);
		IF @CityStart > 0
		BEGIN
			SET @CityStart = @CityStart + LEN(@CityKey);
			DECLARE @CityEnd INT = CHARINDEX('"', @Response, @CityStart);
			SET @City = SUBSTRING(@Response, @CityStart, @CityEnd - @CityStart);
		END
		ELSE
		BEGIN
			SET @City = NULL;
		END

		-- Extract administrativeArea (@State)
		DECLARE @StateKey NVARCHAR(255) = '"administrativeArea":"';
		DECLARE @StateStart INT = CHARINDEX(@StateKey, @Response);
		IF @StateStart > 0
		BEGIN
			SET @StateStart = @StateStart + LEN(@StateKey);
			DECLARE @StateEnd INT = CHARINDEX('"', @Response, @StateStart);
			SET @State = SUBSTRING(@Response, @StateStart, @StateEnd - @StateStart);
		END
		ELSE
		BEGIN
			SET @State = NULL;
		END

		-- Extract regionCode (@Country)
		DECLARE @CountryKey NVARCHAR(255) = '"regionCode":"';
		DECLARE @CountryStart INT = CHARINDEX(@CountryKey, @Response);
		IF @CountryStart > 0
		BEGIN
			SET @CountryStart = @CountryStart + LEN(@CountryKey);
			DECLARE @CountryEnd INT = CHARINDEX('"', @Response, @CountryStart);
			SET @Country = SUBSTRING(@Response, @CountryStart, @CountryEnd - @CountryStart);
		END
		ELSE
		BEGIN
			SET @Country = NULL;
		END

		-- Extract postalCode (@PostalCode)
		DECLARE @PostalCodeKey NVARCHAR(255) = '"postalCode":"';
		DECLARE @PostalCodeStart INT = CHARINDEX(@PostalCodeKey, @Response);
		IF @PostalCodeStart > 0
		BEGIN
			SET @PostalCodeStart = @PostalCodeStart + LEN(@PostalCodeKey);
			DECLARE @PostalCodeEnd INT = CHARINDEX('"', @Response, @PostalCodeStart);
			SET @PostalCode = SUBSTRING(@Response, @PostalCodeStart, @PostalCodeEnd - @PostalCodeStart);
		END
		ELSE
		BEGIN
			SET @PostalCode = NULL;
		END

		-- Extract latitude (@GPSLatitude)
		DECLARE @LatitudeKey NVARCHAR(255) = '"latitude":';
		DECLARE @LatitudeStart INT = CHARINDEX(@LatitudeKey, @Response);
		IF @LatitudeStart > 0
		BEGIN
			SET @LatitudeStart = @LatitudeStart + LEN(@LatitudeKey);
			DECLARE @LatitudeEnd INT = @LatitudeStart;
			WHILE @LatitudeEnd <= LEN(@Response) AND SUBSTRING(@Response, @LatitudeEnd, 1) LIKE '[0-9.-]'
			BEGIN
				SET @LatitudeEnd = @LatitudeEnd + 1;
			END
			SET @GPSLatitude = CAST(SUBSTRING(@Response, @LatitudeStart, @LatitudeEnd - @LatitudeStart) AS NUMERIC(18,10));
		END
		ELSE
		BEGIN
			SET @GPSLatitude = NULL;
		END

		-- Extract longitude (@GPSLongitude)
		DECLARE @LongitudeKey NVARCHAR(255) = '"longitude":';
		DECLARE @LongitudeStart INT = CHARINDEX(@LongitudeKey, @Response, @LatitudeStart); -- Start searching after latitude
		IF @LongitudeStart > 0
		BEGIN
			SET @LongitudeStart = @LongitudeStart + LEN(@LongitudeKey);
			DECLARE @LongitudeEnd INT = @LongitudeStart;
			WHILE @LongitudeEnd <= LEN(@Response) AND SUBSTRING(@Response, @LongitudeEnd, 1) LIKE '[0-9.-]'
			BEGIN
				SET @LongitudeEnd = @LongitudeEnd + 1;
			END
			SET @GPSLongitude = CAST(SUBSTRING(@Response, @LongitudeStart, @LongitudeEnd - @LongitudeStart) AS NUMERIC(18,10));
		END
		ELSE
		BEGIN
			SET @GPSLongitude = NULL;
		END

	End Try
    Begin catch
	  Select ERROR_NUMBER() Error, ERROR_MESSAGE() Mensaje
    End Catch
    -- Build Map URL
    IF @GPSLatitude IS NOT NULL AND @GPSLongitude IS NOT NULL
    BEGIN
        SET @MapURL = 'https://www.google.com/maps/search/?api=1&query=' + CAST(@GPSLatitude AS VARCHAR(20)) + ',' + CAST(@GPSLongitude AS VARCHAR(20));
    END
    ELSE
    BEGIN
        SET @MapURL = NULL;
    END
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

