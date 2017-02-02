DROP TABLE IF EXISTS halfak.ms_indexed_load;
CREATE TABLE halfak.ms_indexed_load
SELECT * 
FROM log.ModuleStorage_6978194;
CREATE UNIQUE INDEX id_idx ON halfak.ms_indexed_load (id);
SELECT NOW() AS "generated", COUNT(*) FROM halfak.ms_indexed_load;
