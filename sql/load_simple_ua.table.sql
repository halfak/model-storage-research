DROP TABLE IF EXISTS halfak.ms_load_simple_ua;
CREATE TABLE halfak.ms_load_simple_ua
SELECT 
    id, 
    (
        IF(browser LIKE "Amigo%", "Amigo",
        IF(browser LIKE "Android%", "Android",
        IF(browser LIKE "Blackberry%", "Blackberry",
        IF(browser LIKE "Chrome%", "Chrome",
        IF(browser LIKE "Firefox%", "Firefox",
        IF(browser LIKE "IE%", "Internet Explorer",
        IF(browser LIKE "Maxthon%", "Maxthon",
        IF(browser LIKE "Mobile Safari%", "Mobile Safari",
        IF(browser LIKE "Opera%", "Opera",
        IF(browser LIKE "Safari%", "Safari",
        IF(browser LIKE "Silk%", "Silk",
        IF(browser LIKE "Yandex%", "Yandex", NULL))))))))))))
    ) AS simple_browser,
    (
        IF(os LIKE "OS X%", "OS X",
        IF(os LIKE "Windows%", "Windows",
        IF(os LIKE "Linux%", "Linux",
        IF(os LIKE "Android%", "Android",
        IF(os LIKE "iOS%", "iOS",
        IF(os LIKE "Chrome OS%", "Chrome OS", NULL))))))
    ) AS simple_platform
FROM ms_extracted_user_agent;
CREATE UNIQUE INDEX id_idx ON halfak.ms_load_simple_ua (id);
SELECT NOW() AS "generated", COUNT(*) FROM halfak.ms_load_simple_ua;

