-- Concatenate multiple rows into sigle one separate by semicolon 
DECLARE @EmailString NVARCHAR(MAX);

SELECT
  @EmailString = STUFF(
    (
      SELECT
        '; ' + ltrim(rtrim(Email))
      FROM
        ReporteProgramadoEmail rpe
        INNER JOIN ReporteProgramado rp ON rp.OID = rpe.ReporteProgramado
      WHERE
        rp.Descripcion = 'Reporte Ventas Por Vendedor y Grupo de Productos' FOR XML PATH('')
    ),
    1,
    2,
    ''
  );