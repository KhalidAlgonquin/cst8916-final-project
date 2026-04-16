WITH AggregatedReadings AS
(
    SELECT
        System.Timestamp() AS windowEndTime,
        location,
        AVG(CAST(iceThicknessCm AS float)) AS avgIceThickness,
        MIN(CAST(iceThicknessCm AS float)) AS minIceThickness,
        MAX(CAST(iceThicknessCm AS float)) AS maxIceThickness,
        AVG(CAST(surfaceTempC AS float)) AS avgSurfaceTemp,
        MIN(CAST(surfaceTempC AS float)) AS minSurfaceTemp,
        MAX(CAST(surfaceTempC AS float)) AS maxSurfaceTemp,
        MAX(CAST(snowAccumulationCm AS float)) AS maxSnowAccumulation,
        AVG(CAST(externalTempC AS float)) AS avgExternalTemp,
        COUNT(*) AS readingCount
    FROM sensorinput
    GROUP BY location, TumblingWindow(minute, 5)
)

SELECT
    CONCAT(location, '-', REPLACE(REPLACE(REPLACE(CAST(windowEndTime AS nvarchar(max)), ':', ''), ' ', '-'), '.', '-')) AS id,
    location,
    windowEndTime AS aggregationTimestamp,
    avgIceThickness,
    minIceThickness,
    maxIceThickness,
    avgSurfaceTemp,
    minSurfaceTemp,
    maxSurfaceTemp,
    maxSnowAccumulation,
    avgExternalTemp,
    readingCount,
    CASE
        WHEN avgIceThickness >= 30 AND avgSurfaceTemp <= -2 THEN 'Safe'
        WHEN avgIceThickness >= 25 AND avgSurfaceTemp <= 0 THEN 'Caution'
        ELSE 'Unsafe'
    END AS safetyStatus
INTO cosmosoutput
FROM AggregatedReadings;

SELECT
    CONCAT(location, '-', REPLACE(REPLACE(REPLACE(CAST(windowEndTime AS nvarchar(max)), ':', ''), ' ', '-'), '.', '-')) AS id,
    location,
    windowEndTime AS aggregationTimestamp,
    avgIceThickness,
    minIceThickness,
    maxIceThickness,
    avgSurfaceTemp,
    minSurfaceTemp,
    maxSurfaceTemp,
    maxSnowAccumulation,
    avgExternalTemp,
    readingCount,
    CASE
        WHEN avgIceThickness >= 30 AND avgSurfaceTemp <= -2 THEN 'Safe'
        WHEN avgIceThickness >= 25 AND avgSurfaceTemp <= 0 THEN 'Caution'
        ELSE 'Unsafe'
    END AS safetyStatus
INTO bloboutput
FROM AggregatedReadings;