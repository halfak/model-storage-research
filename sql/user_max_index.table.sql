DROP TABLE IF EXISTS halfak.ms_user_max_index;
CREATE TABLE halfak.ms_user_max_index
SELECT
    event_experimentId,
    MAX(event_loadIndex) AS max_loadIndex
FROM log.ModuleStorage_6978194
GROUP BY 1;
CREATE UNIQUE INDEX event_experimentId_idx ON halfak.ms_user_max_index (event_experimentId);
SELECT NOW() AS "generated", COUNT(*) FROM halfak.ms_user_max_index;
