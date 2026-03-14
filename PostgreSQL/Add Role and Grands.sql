/*
Purpose:
- Grant reporting access and set default SELECT privileges for shared read-only roles.

Customization:
- Replace placeholder database, schema, role, and table names before execution.
*/

GRANT ALL PRIVILEGES ON DATABASE your_database TO reporting_role;
GRANT USAGE ON SCHEMA public TO reporting_role;
GRANT USAGE ON SCHEMA reporting_schema TO reporting_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO reporting_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA reporting_schema GRANT SELECT ON TABLES TO reporting_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA reporting_schema GRANT SELECT ON TABLES TO reporting_group;

CREATE ROLE reporting_group;
GRANT SELECT ON your_sales_table_daily TO reporting_group;
GRANT SELECT ON your_sales_table_hourly TO reporting_group;
GRANT SELECT ON your_branch_sales_table_daily TO reporting_group;
GRANT SELECT ON your_branch_sales_table_hourly TO reporting_group;
GRANT SELECT ON your_partner_sales_table_hourly TO reporting_group;
