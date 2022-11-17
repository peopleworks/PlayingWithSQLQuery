-- All Tables with specific column name

select dtc.owner,dtc.table_name, column_name,  atc.comments
from dba_tab_columns dtc
inner join all_tab_comments atc on atc.table_name = dtc.table_name
where upper(dtc.column_name) like upper('%_pidm%') and dtc.owner = 'SATURN'
order by dtc.table_name;