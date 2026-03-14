/*
Purpose:
- Assemble a normalized full address string from multiple source columns.

Customization:
- Replace cross-database references with your own shared lookup database if needed.
*/

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



