select * from `workspace`.`default`.`brighttv_user_profiles` limit 100;


-- See first 10 users
SELECT *
FROM `workspace`.`default`.`brighttv_user_profiles`
LIMIT 10;



-- See first 10 viewership records
SELECT *
FROM `workspace`.`default`.`brighttv_viewership`
LIMIT 10;



-----------------------
--HOW BIG IS THE DATA?--
-------------------------


-- Total users
SELECT COUNT(*) AS total_users
FROM `workspace`.`default`.`brighttv_user_profiles`;



-- Total sessions
SELECT COUNT(*) AS total_sessions
FROM `workspace`.`default`.`brighttv_viewership`;



-- Total unique users who watched
SELECT COUNT(DISTINCT UserID0) AS active_users
FROM `workspace`.`default`.`brighttv_viewership`;



---------------------
--UNIQUE VALUES--
---------------------


-- Age range
SELECT
    MIN(Age) AS youngest,
    MAX(Age) AS oldest,
    AVG(Age) AS average_age
FROM `workspace`.`default`.`brighttv_user_profiles`;



-- Date range of viewership
SELECT
    MIN(RecordDate2) AS first_session,
    MAX(RecordDate2) AS last_session
FROM `workspace`.`default`.`brighttv_viewership`;



---------------------
--COUNT EACH GROUP--
---------------------



-- Users by gender
SELECT Gender, COUNT(*) AS total_users
FROM `workspace`.`default`.`brighttv_user_profiles`
GROUP BY Gender
ORDER BY total_users DESC;



-- Users by race
SELECT Race, COUNT(*) AS total_users
FROM `workspace`.`default`.`brighttv_user_profiles`
GROUP BY Race
ORDER BY total_users DESC;



-- Users by province
SELECT Province, COUNT(*) AS total_users
FROM `workspace`.`default`.`brighttv_user_profiles`
GROUP BY Province
ORDER BY total_users DESC;



-- Sessions by channel2
SELECT Channel2, COUNT(*) AS total_sessions
FROM `workspace`.`default`.`brighttv_viewership`
GROUP BY Channel2
ORDER BY total_sessions DESC;



---------------------
--COUNT NULLS--
---------------------



-- Nulls in user profiles
SELECT
    SUM(CASE WHEN Gender   IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN Race     IS NULL THEN 1 ELSE 0 END) AS missing_race,
    SUM(CASE WHEN Province IS NULL THEN 1 ELSE 0 END) AS missing_province,
    SUM(CASE WHEN Age      IS NULL THEN 1 ELSE 0 END) AS missing_age
FROM `workspace`.`default`.`brighttv_user_profiles`



-- Nulls in viewership
SELECT
    SUM(CASE WHEN Channel2     IS NULL THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN RecordDate2  IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN 'Duration2'    IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM `workspace`.`default`.`brighttv_viewership`;



--COALESCE Function

SELECT
COALESCE(NULLIF(gender,'None'),'Unknown') AS cleaned_gender,
COALESCE(NULLIF(Race,'None'),'Unknown') AS cleaned_Race,
COALESCE(NULLIF(province,'None'),'Unknown') AS cleaned_province
FROM `workspace`.`default`.`brighttv_user_profiles`



--CONVERT UTC TO SA TIME (+2 HOURS)
SELECT
    RecordDate2 AS original_UTC,
    DATEADD(HOUR, 2, RecordDate2) AS RecordDate_SA
FROM `workspace`.`default`.`brighttv_viewership`;



--CREATE AGE BRACKETS
SELECT
    Age,
    CASE
        WHEN Age BETWEEN 18 AND 24 THEN 'young'
        WHEN Age BETWEEN 25 AND 34 THEN 'adult'
        WHEN Age BETWEEN 35 AND 44 THEN 'mid-age adult'
        WHEN Age BETWEEN 45 AND 54 THEN 'mature adult'
        ELSE                             'senior'
    END AS age_bracket
FROM `workspace`.`default`.`brighttv_user_profiles`
WHERE Age BETWEEN 18 AND 90;



--CLASSIFY TIME OF DAY
SELECT
    DATEADD(HOUR, 2, RecordDate2)              AS RecordDate_SA,
    CASE
        WHEN HOUR(DATEADD(HOUR,2,RecordDate2)) BETWEEN 6  AND 11 THEN 'Morning'
        WHEN HOUR(DATEADD(HOUR,2,RecordDate2)) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(DATEADD(HOUR,2,RecordDate2)) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE                                                           'Late Night'
    END                                        AS daytime_slot
FROM `workspace`.`default`.`brighttv_viewership`;



--CLASSIFY WEEKDAY VS WEEKEND
SELECT
    DATEADD(HOUR, 2, RecordDate2) AS RecordDate_SA,
    DAYNAME(DATEADD(HOUR, 2, RecordDate2)) AS day_of_week,
    CASE
        WHEN DAYNAME(DATEADD(HOUR, 2, RecordDate2))
             IN ('Saturday','Sunday') THEN 'Weekend'
        ELSE                               'Weekday'
    END  AS day_type
FROM `workspace`.`default`.`brighttv_viewership`;



--------------------
--JOIN STATEMENTS
--------------------



--Sessions and minutes by province
SELECT
    u.Province,
    COUNT(*)               AS total_sessions,
    SUM(MINUTE(`v`.`Duration 2`)) AS total_minutes,
    AVG(MINUTE(`v`.`Duration 2`)) AS avg_minutes
FROM `workspace`.`default`.`brighttv_user_profiles` u
INNER JOIN `workspace`.`default`.`brighttv_viewership` v
    ON u.UserID = v.UserID0
WHERE u.Province IS NOT NULL
GROUP BY u.Province
ORDER BY total_minutes DESC;



--Favourite channel by gender
SELECT
    u.Gender,
    v.Channel2,
    COUNT(*)               AS total_sessions
FROM `workspace`.`default`.`brighttv_user_profiles` u
INNER JOIN `workspace`.`default`.`brighttv_viewership` v
    ON u.UserID = v.UserID0
WHERE u.Gender IS NOT NULL
GROUP BY u.Gender, v.Channel2
ORDER BY u.Gender, total_sessions DESC;



--Top 10 most active users
SELECT
    u.UserID,
    u.Name,
    u.Province,
    COUNT(*)               AS total_sessions,
    SUM(MINUTE(`v`.`Duration 2`)) AS total_minutes
FROM `workspace`.`default`.`brighttv_user_profiles` u
INNER JOIN `workspace`.`default`.`brighttv_viewership` v
    ON u.UserID = v.UserID0
GROUP BY u.UserID, u.Name, u.Province
ORDER BY total_minutes DESC
LIMIT 10;
