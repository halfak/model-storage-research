CREATE TABLE halfak.ms_indexed_load
SELECT
    *,
    1 AS load_index
FROM (
    SELECT
        event_experimentId,
        timestamp
    FROM
        ModuleStorage_6356853
    GROUP BY 1,2;
) AS first
INNER JOIN ModuleStorage_6356853 loads ON
    first.event_experimentId = last.event_experimentId AND
    first.timestamp          = last.timestamp;
CREATE INDEX id_timestamp ON halfak.ms_indexed_load;