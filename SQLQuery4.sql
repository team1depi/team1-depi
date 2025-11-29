-- Objective 1: Analyze most used social media platforms among students
SELECT 
    Most_Used_Platform,
    COUNT(*) AS Num_Students,
    ROUND(AVG(CAST(Avg_Daily_Usage_Hours AS FLOAT)), 2) AS [Avg_Daily_Usage_(Hours)],
    ROUND(AVG(CAST(Addicted_Score AS FLOAT)), 2) AS [Avg_Addiction_(Scale_1_10)]
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Most_Used_Platform
ORDER BY Num_Students DESC;


-- Objective 2: Compare addiction across academic levels
SELECT 
    Academic_Level,
    COUNT(*) AS Num_Students,
    ROUND(AVG(CAST(Addicted_Score AS FLOAT)), 2) AS Avg_Addiction,
    ROUND(AVG(CAST(Avg_Daily_Usage_Hours AS FLOAT)), 2) AS Avg_Usage_Hours,
    ROUND(AVG(CAST(Mental_Health_Score AS FLOAT)), 2) AS Avg_Mental_Health
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Academic_Level
ORDER BY Avg_Addiction DESC;



-- Step 1: Change the column type from BIT/INT to VARCHAR
-- Reason: The data was imported as 0/1, but we need Yes/No text values without using CASE in every query.
ALTER TABLE dbo.[Students Social Media Addiction V2]
ALTER COLUMN Affects_Academic_Performance VARCHAR(10);


-- Step 2: Convert existing values from '1' and '0' into 'Yes' and 'No' only once
-- Reason: After this update, the column will permanently store Yes/No, so no need for CASE or CAST in any SELECT queries later.
UPDATE dbo.[Students Social Media Addiction V2]
SET Affects_Academic_Performance =
    CASE 
        WHEN Affects_Academic_Performance = '1' THEN 'Yes'
        ELSE 'No'
    END;




-- Objective 3: Compare addiction, mental health, and sleep by academic performance impact
SELECT 
    Affects_Academic_Performance,
    COUNT(*) AS Num_Students,
    ROUND(AVG(CAST(Addicted_Score AS FLOAT)), 2)        AS Avg_Addiction_Scale_1_10,
    ROUND(AVG(CAST(Mental_Health_Score AS FLOAT)), 2)   AS Avg_Mental_Health_Scale_1_10,
    ROUND(AVG(CAST(Sleep_Hours_Per_Night AS FLOAT)), 2) AS Avg_Sleep_Hours
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Affects_Academic_Performance
ORDER BY Avg_Addiction_Scale_1_10 DESC;



-- Objective 4: Analyze platform preferences across academic levels
SELECT 
 Academic_Level,Most_Used_Platform,
COUNT(*) AS Num_Students,
CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Academic_Level)AS DECIMAL(5,2)) AS Percent_Within_Level,
CAST(AVG(Addicted_Score) AS DECIMAL(4,1)) AS Avg_Addiction_Score
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Academic_Level, Most_Used_Platform
ORDER BY Academic_Level, Num_Students DESC;



-- Objective 5: Conflict distribution by sleep range
WITH SleepGroups AS (
    SELECT 
        CASE 
            WHEN Sleep_Hours_Per_Night < 5 THEN 'Very Low Sleep (<5h)'
            WHEN Sleep_Hours_Per_Night BETWEEN 5 AND 7 THEN 'Normal Sleep (5-7h)'
            ELSE 'High Sleep (>7h)' 
        END AS Sleep_Group,
        Conflict_Category
    FROM dbo.[Students Social Media Addiction V2]
)
SELECT 
    Sleep_Group,
    Conflict_Category,
    CAST(ROUND(
        100.0 * COUNT(*) 
        / SUM(COUNT(*)) OVER (PARTITION BY Sleep_Group)
    , 1) AS DECIMAL(5,1)) AS Percent_Within_Group
FROM SleepGroups
GROUP BY Sleep_Group, Conflict_Category
ORDER BY Sleep_Group, Conflict_Category;




-- Objective 6: Academic performance impact comparison by gender
SELECT 
    Gender,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2)) AS Avg_Addiction_Score,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2)) AS Avg_Mental_Health,
    CAST(ROUND(AVG(Sleep_Hours_Per_Night), 2) AS DECIMAL(4,2)) AS Avg_Sleep_Hours,
    CAST(
        100.0 * SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 ELSE 0 END) 
        / COUNT(*) AS DECIMAL(5,2)
    ) AS Academic_Impact_Percent
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Gender
ORDER BY Academic_Impact_Percent DESC;



-- Objective 7.1: Addiction, mental health, and sleep differences by relationship status
SELECT 
    Relationship_Status,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2)) AS Avg_Addiction_Score,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2)) AS Avg_Mental_Health,
    CAST(ROUND(AVG(Sleep_Hours_Per_Night), 2) AS DECIMAL(4,2)) AS Avg_Sleep_Hours
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Relationship_Status
ORDER BY Avg_Addiction_Score DESC;



-- Objective 8: Average conflicts and addiction levels across countries
SELECT 
    Country,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2)) AS Avg_Addiction_Score,
    CAST(ROUND(AVG(Conflicts_Over_Social_Media), 2) AS DECIMAL(4,2)) AS Avg_Conflict_Count
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Country
HAVING COUNT(*) >= 10   -- تجاهل الدول اللي عددها قليل
ORDER BY Avg_Conflict_Count DESC;





-- Objective 9: Mental health and academic impact by sleep category
SELECT 
    Sleep_Category AS Sleep_Category,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2)) AS Avg_Mental_Health,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2)) AS Avg_Addiction_Score,
    CAST(
        100.0 * SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) AS DECIMAL(5,2)
    ) AS Academic_Impact_Percent
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Sleep_Category
ORDER BY Academic_Impact_Percent DESC;




-- Objective 10: Impact comparison across addiction categories
SELECT
    Addiction_Category,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2)) AS Avg_Mental_Health,
    CAST(ROUND(AVG(Sleep_Hours_Per_Night), 2) AS DECIMAL(4,2)) AS Avg_Sleep_Hours,
    CAST(
        100.0 * SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) AS DECIMAL(5,2)
    ) AS Academic_Impact_Percent
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Addiction_Category
ORDER BY Academic_Impact_Percent DESC;






-- Objective 11: Relationship between sleep category and mental health, addiction, and academic impact
SELECT
    Sleep_Category,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2))          AS Avg_Addiction_Score,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2))     AS Avg_Mental_Health,
    CAST(
        100.0 * SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) AS DECIMAL(5,2)
    ) AS Academic_Impact_Percent
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Sleep_Category
ORDER BY Academic_Impact_Percent DESC;




-- Objective 12: Compare addiction, sleep, mental health, and academic impact by usage group
SELECT 
    Usage_Group,
    COUNT(*) AS Num_Students,
    CAST(ROUND(AVG(Addicted_Score), 2) AS DECIMAL(4,2))          AS Avg_Addiction_Score,
    CAST(ROUND(AVG(Avg_Daily_Usage_Hours), 2) AS DECIMAL(4,2))   AS Avg_Daily_Usage_Hours,
    CAST(ROUND(AVG(Sleep_Hours_Per_Night), 2) AS DECIMAL(4,2))   AS Avg_Sleep_Hours,
    CAST(ROUND(AVG(Mental_Health_Score), 2) AS DECIMAL(4,2))     AS Avg_Mental_Health,
    CAST(
        100.0 * SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) AS DECIMAL(5,2)
    ) AS Academic_Impact_Percent
FROM dbo.[Students Social Media Addiction V2]
GROUP BY Usage_Group
ORDER BY Avg_Addiction_Score DESC;