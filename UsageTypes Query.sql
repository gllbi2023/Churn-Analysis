WITH UsageCounts AS (
    SELECT User_id,
        CASE WHEN Category = 'Fitness Gym' THEN 'Gym'
            WHEN Category = 'Pools Swimming' THEN 'Swim'
            WHEN Category = 'Fitness Classes' THEN 'Fitness Class'
            ELSE 'Other'
        END AS UsageType,
        COUNT(Visits) AS Visits
    FROM [dbo].[vw_CustomerVisits]
    GROUP BY User_id,
            CASE WHEN Category = 'Fitness Gym' THEN 'Gym'
                 WHEN Category = 'Pools Swimming' THEN 'Swim'
                 WHEN Category = 'Fitness Classes' THEN 'Fitness Class'
                 ELSE 'Other'
            END
),
TotalVisits AS (
    SELECT User_id, SUM(Visits) AS TotalVisitCount
    FROM UsageCounts
    GROUP BY User_id
),
UsagePercentages AS (
    SELECT U.User_id, U.UsageType, U.Visits, T.TotalVisitCount,
        CAST(U.Visits * 1.0 / NULLIF(T.TotalVisitCount, 0) AS DECIMAL(5,2)) AS UsagePercentage
    FROM UsageCounts U
    JOIN TotalVisits T
        ON U.User_id = T.User_id
),
PrimaryUsage AS (
    SELECT User_id,
        MAX(CASE WHEN UsagePercentage >= 0.5 THEN UsageType ELSE NULL END) AS PrimaryUsage,
        COUNT(CASE WHEN UsagePercentage > 0.5 THEN 1 END) AS DominantType
    FROM UsagePercentages
    GROUP BY User_id
)

SELECT P.User_id,
    CASE WHEN DominantType = 1 THEN PrimaryUsage
         ELSE 'Mixed'
    END AS UsageType
FROM PrimaryUsage P