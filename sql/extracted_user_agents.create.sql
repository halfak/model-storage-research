DROP TABLE IF EXISTS halfak.ms_extracted_user_agent;
CREATE TABLE halfak.ms_extracted_user_agent (
    id INT(11),
    browser VARCHAR(255),
    os VARCHAR(255),
    device VARCHAR(255)
);
CREATE UNIQUE INDEX id_idx ON halfak.ms_extracted_user_agent (id);
SELECT "Table created" AS action;
