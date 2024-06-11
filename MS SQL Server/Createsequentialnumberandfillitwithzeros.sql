/*

Create a sequential number and fill it with zeros.

*/
With PaddedTable as 
(
SELECT RIGHT('00000' + CONVERT(VARCHAR(6), ROW_NUMBER() OVER(
	           ORDER BY(
	               SELECT NULL
	           )
	       )      ), 6) AS PaddedNumber, nombre, OfrendanteID
FROM [dbo].[Ofrendante]

) 


update ofre set [NoOfrendante] = PaddedNumber
from [dbo].[Ofrendante] ofre
inner join
PaddedTable on PaddedTable.OfrendanteID = ofre.OfrendanteID