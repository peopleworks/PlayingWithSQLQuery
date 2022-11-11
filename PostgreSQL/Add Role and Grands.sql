GRANT ALL PRIVILEGES ON DATABASE pwerp TO consultabluestdo;
GRANT USAGE ON SCHEMA public TO consultabluestdo;
GRANT USAGE ON SCHEMA consultabluestdo TO consultabluestdo;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO consultabluestdo;
ALTER DEFAULT PRIVILEGES IN SCHEMA consultabluestdo GRANT SELECT ON TABLES TO consultabluestdo;
ALTER DEFAULT PRIVILEGES IN SCHEMA consulta GRANT SELECT ON TABLES TO consultas;




create group consultas;
GRANT SELECT ON ventasloccitanepuntacanadias TO GROUP consultas;
GRANT SELECT ON ventasloccitanepuntacanahoras TO GROUP consultas;
GRANT SELECT ON ventasloccitanesantodomingodias TO GROUP consultas;
GRANT SELECT ON ventasloccitanesantodomingohoras TO GROUP consultas;
GRANT SELECT ON ventastrellishomedecorpuntacanahoras TO GROUP consultas;