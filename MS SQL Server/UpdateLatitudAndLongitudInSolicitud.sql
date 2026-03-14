/*
Purpose:
- Loop through pending records, validate addresses, and update latitude/longitude values.

Dependencies:
- Requires the spAddressvalidation procedure to be available in the target database.
*/

-- Declare variables to hold the values from the cursor
DECLARE @id_Solicitante INT
DECLARE @FullAddressFinal NVARCHAR(200)
DECLARE @Address NVARCHAR(80), @City NVARCHAR(40), @State NVARCHAR(40), @Country NVARCHAR(40), @PostalCode NVARCHAR(20)
DECLARE @GPSLatitude NUMERIC(9,6), @GPSLongitude NUMERIC(9,6), @MapURL NVARCHAR(1024)

-------------------------------------------------------------------------------------------------------
-- Declare the cursor for the select statement
DECLARE SolicitudCursor CURSOR FOR
SELECT Distinct Data.FullAddressFinal, Data.id_Solicitante
from
Solicitud
inner join Solicitante on Solicitud.fk_Solicitante_1 = Solicitante.id_Solicitante
inner join
(
SELECT
  FinalData.*,
  REPLACE(
    CASE
      WHEN LEFT(FullAddress, 2) = ', ' THEN STUFF(FullAddress, 1, 2, '')
      ELSE FullAddress
    END,
    ', , ',
    ''
  ) AS FullAddressFinal
FROM
  (
    SELECT
      data.*,
      CASE
        WHEN Direccion2_Fisica IS NOT NULL
        AND Direccion2_Fisica <> '' THEN Direccion1_Fisica + ' ' + Direccion2_Fisica
        ELSE Direccion1_Fisica
      END + CASE
        WHEN SectorDesc IS NOT NULL
        AND SectorDesc <> '' THEN ', ' + SectorDesc
        ELSE ''
      END + CASE
        WHEN BarrioDesc IS NOT NULL
        AND BarrioDesc <> '' THEN ', ' + BarrioDesc
        ELSE ''
      END + CASE
        WHEN NombreCiudad IS NOT NULL
        AND NombreCiudad <> '' THEN ', ' + NombreCiudad
        ELSE ''
      END + CASE
        WHEN Zipcode IS NOT NULL
        AND Zipcode <> '' THEN ', ' + Zipcode
        ELSE ''
      END + CASE
        WHEN Pais IS NOT NULL
        AND Pais <> '' THEN ', ' + Pais
        ELSE ''
      END AS FullAddress
    FROM
      (
        SELECT
          Solicitante.id_Solicitante,
          Replace(
            ISNULL(Solicitante.Direccion1_Fisica, ''),
            ' ,  , ',
            ''
          ) AS Direccion1_Fisica,
          ISNULL(Solicitante.Direccion2_Fisica, '') AS Direccion2_Fisica,
          Solicitante.fk_Ciudades_Fis_1,
          Solicitante.fk_Sector_Fisic_1,
          Solicitante.fk_Barrios_Fisi_1,
          ISNULL(Ciudades.NombreCiudad, (Select nombre from [YourReferenceDatabase].[dbo].[Municipio])) AS NombreCiudad,
          ISNULL(Sectores.SectorDesc, '') AS SectorDesc,
          ISNULL(Barrios.BarrioDesc, '') AS BarrioDesc,
          SUBSTRING(
            isnull(Solicitante.ZonaPostal_Fisica, '00617'),
            1,
            5
          ) AS Zipcode,
          'Puerto Rico' AS Pais
        FROM
          Solicitante
          LEFT OUTER JOIN Barrios ON Solicitante.fk_Barrios_Fisi_1 = Barrios.id_Barrio
          LEFT OUTER JOIN Sectores ON Solicitante.fk_Sector_Fisic_1 = Sectores.id_Sector
          LEFT OUTER JOIN Ciudades ON Solicitante.fk_Ciudades_Fis_1 = Ciudades.id_Ciudades
      ) data
  ) FinalData
  ) Data on Data.id_Solicitante = Solicitante.id_Solicitante
  where Solicitud.Latitud is null or 
        Solicitud.Longitud is null or 
		Solicitud.Latitud = 0 or 
		Solicitud.Longitud = 0
-------------------------------------------------------------------------------------------------------

-- Open the cursor
OPEN SolicitudCursor

-- Fetch the first row
FETCH NEXT FROM SolicitudCursor INTO @FullAddressFinal, @id_Solicitante

-- Loop through each row
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Execute the stored procedure spAddressvalidation for the current row
    EXEC spAddressvalidation
        @Address = @Address OUTPUT,
        @City = @City OUTPUT,
        @State = @State OUTPUT,
        @Country = @Country OUTPUT,
        @PostalCode = @PostalCode OUTPUT,
        @GPSLatitude = @GPSLatitude OUTPUT,
        @GPSLongitude = @GPSLongitude OUTPUT,
        @MapURL = @MapURL OUTPUT,
        @AddressText = @FullAddressFinal -- Pass the address text for validation

    -- Update the Solicitud table with the values returned from the procedure
    UPDATE Solicitud
    SET
        Latitud = @GPSLatitude,
        Longitud = @GPSLongitude
    WHERE fk_Solicitante_1 = @id_Solicitante

    -- Fetch the next row
    FETCH NEXT FROM SolicitudCursor INTO @FullAddressFinal, @id_Solicitante
END

-- Close and deallocate the cursor
CLOSE SolicitudCursor
DEALLOCATE SolicitudCursor

