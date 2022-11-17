-- Table information

SELECT
c.*
from
ALL_COL_COMMENTS c
where 
c.TABLE_NAME = 'SPBPERS'
order by COLUMN_NAME