/*
Purpose:
- Show column comments for a specific Oracle table.

Customization:
- Replace 'SPBPERS' with your target table name.
*/

select c.*
from ALL_COL_COMMENTS c
where c.TABLE_NAME = 'SPBPERS'
order by c.COLUMN_NAME;
