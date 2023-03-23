-- Checking Datatypes

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'playerslookup';

-- Checking for Null values

SELECT 
    *
FROM
    nhl.playerslookup
WHERE
    name IS NULL;

-- Finding Goalies from the data set

SELECT 
    *
FROM
    nhl.playerslookup
WHERE
    position = 'G';

-- Remove Goalies from the data set

DELETE FROM nhl.playerslookup 
WHERE
    position = 'G';

-- Finding older players that shouldn't be on this data set

SELECT 
    name,
    birthdate,
    TIMESTAMPDIFF(YEAR,
        birthdate,
        CURDATE()) AS age
FROM
    nhl.playerslookup
HAVING AGE >= 39;

-- Noticed a couple players that were still in the league at this time, so kept them in for this example

SELECT 
    name,
    birthdate,
    TIMESTAMPDIFF(YEAR,
        birthdate,
        CURDATE()) AS age
FROM
    nhl.playerslookup
WHERE
    name NOT LIKE '%Joe%Thornton%'
        AND name NOT LIKE '%Mark%Giordano%'
HAVING AGE >= 39;

-- Create new table to get age column separated

CREATE TABLE older AS SELECT name,
    TIMESTAMPDIFF(YEAR,
        birthdate,
        CURDATE()) AS age,
    (name + TIMESTAMPDIFF(YEAR,
        birthdate,
        CURDATE())) AS new FROM
    nhl.playerslookup;

-- Add new table as a column into current data set

ALTER TABLE nhl.playerslookup
ADD COLUMN new INT;

-- Update and Join new table to current table 

UPDATE nhl.playerslookup AS up
        JOIN
    older AS o ON up.name = o.name 
SET 
    up.new = o.new;

SELECT 
    *
FROM
    nhl.playerslookup;

-- Remove older players except Joe Thornton and Mark Giordano

DELETE FROM nhl.playerslookup 
WHERE
    name NOT LIKE '%Joe%Thornton%'
    AND name NOT LIKE '%Mark%Giordano%'
    AND new >= 39;

-- Confirm they are still in the data

SELECT 
    *
FROM
    nhl.playerslookup
WHERE
    name LIKE '%Mark%Giordano%'
        OR name LIKE '%Joe%Thornton%';

-- The names are showing up 5 times because of the data collected on the specific situation column

SELECT 
    *, COUNT(*) AS count
FROM
    nhl.season2022 AS s22
        LEFT JOIN
    nhl.playerslookup AS up ON s22.playerId = up.playerId
GROUP BY s22.name , s22.playerid
HAVING count > 1;

-- Count the number of players by position

SELECT 
    position, COUNT(*) AS count
FROM
    nhl.season2022
WHERE
    situation = 'all'
GROUP BY position;

 -- List the distinct variables in the position column using a sub query
 
SELECT 
    position, COUNT(*) AS count
FROM
    (SELECT DISTINCT
        position
    FROM
        nhl.season2022) AS temp
GROUP BY position;

-- the top 10 scoring leaders in the 2021/2022 season

SELECT 
    s22.name,
    s22.position,
    up.team,
    s22.I_F_goals AS goals,
    (I_F_primaryAssists + I_F_secondaryAssists) AS assists,
    s22.I_F_points AS points
FROM
    nhl.season2022 AS s22
        LEFT JOIN
    nhl.playerslookup AS up ON s22.playerId = up.playerId
WHERE
    situation = 'all'
ORDER BY points DESC
LIMIT 10;
-- Finding the average number of points for the 2021/22 season
SELECT 
    ROUND(AVG(I_F_points), 2) AS avgPoints
FROM
    season2022;

-- Rank players by points then partitioning by their positon

SELECT DISTINCT name,position, I_F_points as points,
RANK() OVER(PARTITION BY position ORDER BY I_F_points desc ) as positionRank,
RANK()OVER (ORDER BY I_F_points desc)as leader
FROM nhl.season2022
LIMIT 100;

-- Finding out height in cm
SELECT 
    name,
    height,
    SUBSTR(height,
        1,
        INSTR(height, '\'') - 1) * 12 * 2.54 + SUBSTR(height,
        INSTR(height, '\'') + 1,
        INSTR(height, '"') - INSTR(height, '\'') - 1) * 2.54 AS heightincm
FROM
    nhl.playerslookup;

-- Finding the most popular number picked amongst players

SELECT 
    primaryNumber, COUNT(*) AS count
FROM
    nhl.playerslookup
GROUP BY primaryNumber
ORDER BY count DESC
LIMIT 1;

-- Showing icetime converted to minutes, and we conlcude that defencemen get the most icetime

SELECT 
    s22.name,
    s22.position,
    up.team,
    icetime,
    ROUND(icetime * 0.0166667, 0) AS timeinM
FROM
    nhl.season2022 AS s22
        LEFT JOIN
    nhl.playerslookup AS up ON s22.playerId = up.playerId
GROUP BY icetime
ORDER BY icetime DESC
LIMIT 100;

-- Categorizing players into tiers using CASE statements

SELECT 
    s22.name,
    s22.position,
    I_F_points AS points,
    CASE
        WHEN I_F_points >= 100 THEN 'Elite Tier'
        WHEN I_F_points >= 82 AND I_F_points < 100 THEN 'Top Tier'
        WHEN I_F_points >= 50 AND I_F_points < 82 THEN 'Mid Tier'
        WHEN I_F_points >= 25 AND I_F_points < 50 THEN 'Low Tier'
        ELSE 'Basement Tier'
    END AS tier
FROM
    nhl.season2022 AS s22
        LEFT JOIN
    nhl.playerslookup AS up ON s22.playerId = up.playerId
WHERE
    situation = 'all'
ORDER BY points DESC
LIMIT 100;

-- Calculating current age from date of birth

SELECT 
    name,
    birthdate,
    TIMESTAMPDIFF(YEAR,
        birthdate,
        CURDATE()) AS age
FROM
    nhl.playerslookup;

-- Counting the number of births in each month

SELECT 
    MONTH(birthdate) AS birthMonth, COUNT(*) AS birthCount
FROM
    playerslookup
GROUP BY birthMonth
ORDER BY birthMonth DESC;


-- Showing avg points per team
SELECT DISTINCT s22.team,AVG(s22.I_F_points) OVER(PARTITION BY s22.team ORDER BY team desc) as teamAVG
from nhl.season2022 as s22
left join nhl.playerslookup as up
on s22.playerId = up.playerId
WHERE situation = 'all';

SELECT name, I_F_points AS POINTS
FROM season2022
WHERE team = 'EDM' AND situation = 'all';


-- Import current season Data to compare points leaders as of March 9,2023

SELECT 
    s22.name, s22.I_F_points AS last, c.I_F_points AS curr
FROM
    season2022 AS s22
        JOIN
    currentseason AS c ON s22.playerid = c.playerid
WHERE
    s22.situation = 'all'
ORDER BY c.I_F_points DESC
LIMIT 100;


