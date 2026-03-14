/*
Purpose:
- Return the Oracle host name that serves the current session.
*/

select sys_context('USERENV', 'SERVER_HOST') as server_host
from dual;
