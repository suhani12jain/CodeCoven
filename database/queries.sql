-- =============================================================================
-- SMART WASTE MANAGEMENT AND RECYCLING SYSTEM (SWMRS)
-- Database: MySQL 8.0+
-- Script: queries.sql
-- Description: 25 Advanced Academic Queries demonstrating all relational
--              algebra operations, joins, subqueries, aggregates, window
--              functions, and analytical transformations.
-- =============================================================================

USE waste_mgmt_db;

-- -----------------------------------------------------------------------------
-- QUERY 1: INNER JOIN (3-Table Relationship)
-- Purpose: Retrieve active smart bins with their zone and waste stream properties.
-- Relational Algebra: Bin ⨝ Zone ⨝ Waste_Category
-- -----------------------------------------------------------------------------
SELECT 
    b.BinCode,
    z.ZoneName,
    z.City,
    wc.CategoryName,
    wc.ToxicityLevel,
    b.CapacityLitres,
    b.CurrentFillLevel,
    b.Status
FROM Bin b
INNER JOIN Zone z ON b.ZoneID = z.ZoneID
INNER JOIN Waste_Category wc ON b.CategoryID = wc.CategoryID
WHERE b.Status != 'DAMAGED'
ORDER BY b.CurrentFillLevel DESC;

-- -----------------------------------------------------------------------------
-- QUERY 2: MULTI-TABLE INNER JOIN (5-Table Operational Trace)
-- Purpose: Detail collection records with driver, vehicle, and route details.
-- -----------------------------------------------------------------------------
SELECT 
    cr.RecordID,
    cr.CollectionTimestamp,
    b.BinCode,
    u.FullName AS DriverName,
    d.Shift,
    v.VehicleNumber,
    v.VehicleType,
    r.RouteName,
    cr.CollectedWeightKg,
    cr.FillLevelBefore
FROM Collection_Record cr
INNER JOIN Bin b ON cr.BinID = b.BinID
INNER JOIN Collection_Route r ON cr.RouteID = r.RouteID
INNER JOIN Driver_Employee d ON cr.DriverID = d.DriverID
INNER JOIN Users u ON d.UserID = u.UserID
INNER JOIN Collection_Vehicle v ON cr.VehicleID = v.VehicleID
ORDER BY cr.CollectionTimestamp DESC
LIMIT 20;

-- -----------------------------------------------------------------------------
-- QUERY 3: LEFT OUTER JOIN
-- Purpose: List all zones and count of installed bins, retaining zones with 0 bins.
-- -----------------------------------------------------------------------------
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.PopulationDensity,
    COUNT(b.BinID) AS TotalBinsInstalled,
    COALESCE(AVG(b.CurrentFillLevel), 0.0) AS AvgFillLevel
FROM Zone z
LEFT JOIN Bin b ON z.ZoneID = b.ZoneID
GROUP BY z.ZoneID, z.ZoneName, z.PopulationDensity
ORDER BY TotalBinsInstalled DESC, z.ZoneName ASC;

-- -----------------------------------------------------------------------------
-- QUERY 4: RIGHT OUTER JOIN
-- Purpose: Match fleet vehicles to assigned routes, highlighting idle vehicles.
-- -----------------------------------------------------------------------------
SELECT 
    v.VehicleNumber,
    v.VehicleType,
    v.CapacityKg,
    v.OperationalStatus,
    r.RouteID,
    r.RouteName,
    r.ScheduledDate,
    r.RouteStatus
FROM Collection_Route r
RIGHT JOIN Collection_Vehicle v ON r.VehicleID = v.VehicleID
WHERE r.RouteID IS NULL OR r.ScheduledDate = CURDATE()
ORDER BY v.VehicleType, v.VehicleNumber;

-- -----------------------------------------------------------------------------
-- QUERY 5: FULL OUTER JOIN SIMULATION (UNION of LEFT and RIGHT JOIN)
-- Purpose: Cross-tabulate Citizens and Complaints to uncover citizens who haven't
--          lodged complaints AND unlinked complaints (if citizen deleted).
-- -----------------------------------------------------------------------------
SELECT 
    c.CitizenID,
    u.FullName AS CitizenName,
    cmp.ComplaintID,
    cmp.ComplaintType,
    cmp.Status AS ComplaintStatus
FROM Citizen c
JOIN Users u ON c.UserID = u.UserID
LEFT JOIN Complaint cmp ON c.CitizenID = cmp.CitizenID

UNION

SELECT 
    c.CitizenID,
    u.FullName AS CitizenName,
    cmp.ComplaintID,
    cmp.ComplaintType,
    cmp.Status AS ComplaintStatus
FROM Citizen c
JOIN Users u ON c.UserID = u.UserID
RIGHT JOIN Complaint cmp ON c.CitizenID = cmp.CitizenID;

-- -----------------------------------------------------------------------------
-- QUERY 6: SELF JOIN (Workforce Peer Matching)
-- Purpose: Find pairs of drivers working the same shift with identical experience.
-- -----------------------------------------------------------------------------
SELECT 
    d1.DriverID AS Driver1_ID,
    u1.FullName AS Driver1_Name,
    d2.DriverID AS Driver2_ID,
    u2.FullName AS Driver2_Name,
    d1.Shift,
    d1.ExperienceYears
FROM Driver_Employee d1
JOIN Driver_Employee d2 
    ON d1.Shift = d2.Shift 
    AND d1.ExperienceYears = d2.ExperienceYears
    AND d1.DriverID < d2.DriverID
JOIN Users u1 ON d1.UserID = u1.UserID
JOIN Users u2 ON d2.UserID = u2.UserID;

-- -----------------------------------------------------------------------------
-- QUERY 7: SELF JOIN (Sequential Sensor Fill Rate Velocity)
-- Purpose: Compare successive sensor readings on the same bin to track surge.
-- -----------------------------------------------------------------------------
SELECT 
    s1.BinID,
    s1.ReadingTimestamp AS Time_T1,
    s1.FillPercentage AS Fill_T1,
    s2.ReadingTimestamp AS Time_T2,
    s2.FillPercentage AS Fill_T2,
    ROUND(s2.FillPercentage - s1.FillPercentage, 2) AS FillIncreasePct,
    TIMESTAMPDIFF(MINUTE, s1.ReadingTimestamp, s2.ReadingTimestamp) AS MinutesElapsed
FROM Sensor_Reading s1
JOIN Sensor_Reading s2 
    ON s1.BinID = s2.BinID 
    AND s2.ReadingID = s1.ReadingID + 1
WHERE s2.FillPercentage > s1.FillPercentage
ORDER BY FillIncreasePct DESC
LIMIT 15;

-- -----------------------------------------------------------------------------
-- QUERY 8: SCALAR NESTED SUBQUERY
-- Purpose: Identify all bins whose current fill level is strictly above the
--          overall city-wide average fill level.
-- -----------------------------------------------------------------------------
SELECT 
    BinCode,
    CurrentFillLevel,
    Status,
    (SELECT ROUND(AVG(CurrentFillLevel), 2) FROM Bin) AS CityAverageFill
FROM Bin
WHERE CurrentFillLevel > (SELECT AVG(CurrentFillLevel) FROM Bin)
ORDER BY CurrentFillLevel DESC;

-- -----------------------------------------------------------------------------
-- QUERY 9: SUBQUERY WITH 'IN'
-- Purpose: Find recycling facilities that have processed hazardous or e-waste.
-- -----------------------------------------------------------------------------
SELECT 
    FacilityID,
    FacilityName,
    CapacityPerDayTons,
    ContactNumber
FROM Recycling_Facility
WHERE FacilityID IN (
    SELECT DISTINCT FacilityID 
    FROM Recycling_Batch 
    WHERE CategoryID IN (
        SELECT CategoryID 
        FROM Waste_Category 
        WHERE HazardFlag = TRUE
    )
);

-- -----------------------------------------------------------------------------
-- QUERY 10: SUBQUERY WITH 'NOT IN'
-- Purpose: Find all fleet vehicles that have not logged any collection activity.
-- -----------------------------------------------------------------------------
SELECT 
    VehicleID,
    VehicleNumber,
    VehicleType,
    CapacityKg,
    OperationalStatus
FROM Collection_Vehicle
WHERE VehicleID NOT IN (
    SELECT DISTINCT VehicleID 
    FROM Collection_Record 
    WHERE VehicleID IS NOT NULL
);

-- -----------------------------------------------------------------------------
-- QUERY 11: CORRELATED SUBQUERY IN WHERE CLAUSE
-- Purpose: Find bins whose fill level is above the average of their own zone.
-- -----------------------------------------------------------------------------
SELECT 
    b.BinID,
    b.BinCode,
    b.ZoneID,
    b.CurrentFillLevel,
    b.Status
FROM Bin b
WHERE b.CurrentFillLevel > (
    SELECT AVG(b_sub.CurrentFillLevel)
    FROM Bin b_sub
    WHERE b_sub.ZoneID = b.ZoneID
)
ORDER BY b.ZoneID, b.CurrentFillLevel DESC;

-- -----------------------------------------------------------------------------
-- QUERY 12: CORRELATED SUBQUERY WITH 'EXISTS'
-- Purpose: Find all drivers who have emptied at least one bin with > 90% fill.
-- -----------------------------------------------------------------------------
SELECT 
    d.DriverID,
    u.FullName,
    d.LicenseNumber,
    d.Rating
FROM Driver_Employee d
JOIN Users u ON d.UserID = u.UserID
WHERE EXISTS (
    SELECT 1 
    FROM Collection_Record cr
    WHERE cr.DriverID = d.DriverID 
      AND cr.FillLevelBefore >= 90.00
);

-- -----------------------------------------------------------------------------
-- QUERY 13: CORRELATED SUBQUERY WITH 'NOT EXISTS'
-- Purpose: Find registered citizens who have NEVER lodged a grievance.
-- -----------------------------------------------------------------------------
SELECT 
    c.CitizenID,
    u.FullName AS CitizenName,
    u.Email,
    u.Phone,
    c.RewardPoints
FROM Citizen c
JOIN Users u ON c.UserID = u.UserID
WHERE NOT EXISTS (
    SELECT 1 
    FROM Complaint cmp 
    WHERE cmp.CitizenID = c.CitizenID
);

-- -----------------------------------------------------------------------------
-- QUERY 14: AGGREGATE FUNCTIONS WITH GROUP BY AND HAVING
-- Purpose: Calculate total collected waste per zone and filter zones with > 2,000 kg.
-- -----------------------------------------------------------------------------
SELECT 
    z.ZoneName,
    COUNT(cr.RecordID) AS TotalCollections,
    ROUND(SUM(cr.CollectedWeightKg), 2) AS TotalWeightKg,
    ROUND(AVG(cr.CollectedWeightKg), 2) AS AvgWeightPerTripKg,
    ROUND(MAX(cr.CollectedWeightKg), 2) AS HeaviestPickupKg
FROM Collection_Record cr
JOIN Bin b ON cr.BinID = b.BinID
JOIN Zone z ON b.ZoneID = z.ZoneID
GROUP BY z.ZoneName
HAVING SUM(cr.CollectedWeightKg) > 2000.00
ORDER BY TotalWeightKg DESC;

-- -----------------------------------------------------------------------------
-- QUERY 15: MULTI-COLUMN GROUP BY WITH ROLLUP
-- Purpose: Hierarchical waste tonnage rollup by Zone and Category.
-- -----------------------------------------------------------------------------
SELECT 
    COALESCE(z.ZoneName, '--- ALL ZONES ---') AS ZoneName,
    COALESCE(wc.CategoryName, '--- ALL CATEGORIES ---') AS CategoryName,
    ROUND(SUM(cr.CollectedWeightKg), 2) AS TotalCollectedKg,
    COUNT(cr.RecordID) AS PickupCount
FROM Collection_Record cr
JOIN Bin b ON cr.BinID = b.BinID
JOIN Zone z ON b.ZoneID = z.ZoneID
JOIN Waste_Category wc ON b.CategoryID = wc.CategoryID
GROUP BY z.ZoneName, wc.CategoryName WITH ROLLUP;

-- -----------------------------------------------------------------------------
-- QUERY 16: COMPLEX HAVING WITH MULTIPLE AGGREGATE FILTERS
-- Purpose: Find waste categories with average batch purity > 92% and total output > 10,000 kg.
-- -----------------------------------------------------------------------------
SELECT 
    wc.CategoryName,
    COUNT(rb.BatchID) AS TotalBatches,
    ROUND(SUM(rb.InputWeightKg), 2) AS GrossInputKg,
    ROUND(SUM(rb.OutputRecycledKg), 2) AS GrossRecycledKg,
    ROUND(AVG(rb.PurityRate), 2) AS MeanPurity
FROM Waste_Category wc
JOIN Recycling_Batch rb ON wc.CategoryID = rb.CategoryID
GROUP BY wc.CategoryName
HAVING AVG(rb.PurityRate) >= 92.00 AND SUM(rb.OutputRecycledKg) > 10000.00
ORDER BY GrossRecycledKg DESC;

-- -----------------------------------------------------------------------------
-- QUERY 17: CONDITIONAL LOGIC USING MULTI-BRANCH CASE
-- Purpose: Classify bins into actionable emergency operational status tiers.
-- -----------------------------------------------------------------------------
SELECT 
    b.BinCode,
    z.ZoneName,
    wc.CategoryName,
    b.CurrentFillLevel,
    CASE 
        WHEN b.CurrentFillLevel >= 90.00 THEN '🔴 DISPATCH IMMEDIATE COMPACTOR'
        WHEN b.CurrentFillLevel >= 75.00 THEN '🟡 SCHEDULE NEXT SHIFT PICKUP'
        WHEN b.CurrentFillLevel >= 50.00 THEN '🟢 NORMAL MONITORING'
        ELSE '⚪ LOW USAGE / SUFFICIENT CAPACITY'
    END AS OperationalActionPlan
FROM Bin b
JOIN Zone z ON b.ZoneID = z.ZoneID
JOIN Waste_Category wc ON b.CategoryID = wc.CategoryID
ORDER BY b.CurrentFillLevel DESC;

-- -----------------------------------------------------------------------------
-- QUERY 18: PIVOT QUERY USING CASE INSIDE AGGREGATES
-- Purpose: Matrix count of Bins by Operational Status per Zone.
-- -----------------------------------------------------------------------------
SELECT 
    z.ZoneName,
    COUNT(b.BinID) AS TotalBins,
    SUM(CASE WHEN b.Status = 'NORMAL' THEN 1 ELSE 0 END) AS NormalBins,
    SUM(CASE WHEN b.Status = 'NEEDS_ATTENTION' THEN 1 ELSE 0 END) AS AttentionBins,
    SUM(CASE WHEN b.Status = 'OVERFLOW_CRITICAL' THEN 1 ELSE 0 END) AS CriticalBins,
    SUM(CASE WHEN b.Status IN ('DAMAGED', 'UNDER_MAINTENANCE') THEN 1 ELSE 0 END) AS DamagedBins
FROM Zone z
LEFT JOIN Bin b ON z.ZoneID = b.ZoneID
GROUP BY z.ZoneName
ORDER BY CriticalBins DESC, TotalBins DESC;

-- -----------------------------------------------------------------------------
-- QUERY 19: UNION ALL (Unified Incident Alert Stream)
-- Purpose: Consolidate overflowing bins and pending complaints into one feed.
-- -----------------------------------------------------------------------------
SELECT 
    'BIN_OVERFLOW' AS AlertCategory,
    b.BinCode AS ReferenceIdentifier,
    z.ZoneName AS Location,
    CONCAT('Fill level at ', b.CurrentFillLevel, '%') AS Details,
    b.LastCleanedAt AS EventTimestamp
FROM Bin b
JOIN Zone z ON b.ZoneID = z.ZoneID
WHERE b.CurrentFillLevel >= 85.00

UNION ALL

SELECT 
    'CITIZEN_COMPLAINT' AS AlertCategory,
    CONCAT('CMP-#', c.ComplaintID) AS ReferenceIdentifier,
    z.ZoneName AS Location,
    CONCAT(c.ComplaintType, ': ', SUBSTRING(c.Description, 1, 40), '...') AS Details,
    c.LodgedAt AS EventTimestamp
FROM Complaint c
JOIN Citizen cit ON c.CitizenID = cit.CitizenID
JOIN Zone z ON cit.ZoneID = z.ZoneID
WHERE c.Status = 'Pending'
ORDER BY EventTimestamp DESC;

-- -----------------------------------------------------------------------------
-- QUERY 20: WINDOW FUNCTION - ROW_NUMBER()
-- Purpose: Extract the latest 2 sensor readings for each bin chronologically.
-- -----------------------------------------------------------------------------
WITH RankedReadings AS (
    SELECT 
        sr.ReadingID,
        sr.BinID,
        b.BinCode,
        sr.FillPercentage,
        sr.BatteryLevelPct,
        sr.TemperatureCelsius,
        sr.ReadingTimestamp,
        ROW_NUMBER() OVER (
            PARTITION BY sr.BinID 
            ORDER BY sr.ReadingTimestamp DESC
        ) AS RowSeq
    FROM Sensor_Reading sr
    JOIN Bin b ON sr.BinID = b.BinID
)
SELECT 
    BinCode,
    FillPercentage,
    BatteryLevelPct,
    TemperatureCelsius,
    ReadingTimestamp
FROM RankedReadings
WHERE RowSeq <= 2
ORDER BY BinID, RowSeq;

-- -----------------------------------------------------------------------------
-- QUERY 21: WINDOW FUNCTIONS - RANK() & DENSE_RANK()
-- Purpose: Benchmark driver performance based on cumulative weight collected.
-- -----------------------------------------------------------------------------
SELECT 
    u.FullName AS DriverName,
    d.Shift,
    COUNT(cr.RecordID) AS CollectionsDone,
    ROUND(SUM(cr.CollectedWeightKg), 2) AS TotalWeightCollectedKg,
    RANK() OVER (ORDER BY SUM(cr.CollectedWeightKg) DESC) AS StandardRank,
    DENSE_RANK() OVER (ORDER BY SUM(cr.CollectedWeightKg) DESC) AS DenseRank
FROM Driver_Employee d
JOIN Users u ON d.UserID = u.UserID
JOIN Collection_Record cr ON d.DriverID = cr.DriverID
GROUP BY d.DriverID, u.FullName, d.Shift;

-- -----------------------------------------------------------------------------
-- QUERY 22: WINDOW FUNCTION - LAG()
-- Purpose: Calculate fill percentage increment between successive sensor readings.
-- -----------------------------------------------------------------------------
SELECT 
    ReadingID,
    BinID,
    ReadingTimestamp,
    FillPercentage AS CurrentFill,
    LAG(FillPercentage, 1) OVER (
        PARTITION BY BinID 
        ORDER BY ReadingTimestamp
    ) AS PreviousFill,
    ROUND(FillPercentage - LAG(FillPercentage, 1) OVER (
        PARTITION BY BinID 
        ORDER BY ReadingTimestamp
    ), 2) AS FillDelta
FROM Sensor_Reading
ORDER BY BinID, ReadingTimestamp DESC
LIMIT 25;

-- -----------------------------------------------------------------------------
-- QUERY 23: WINDOW FUNCTION - LEAD()
-- Purpose: Anticipate subsequent route assignments for each collection vehicle.
-- -----------------------------------------------------------------------------
SELECT 
    v.VehicleNumber,
    r.RouteName,
    r.ScheduledDate,
    r.ScheduledStartTime,
    LEAD(r.RouteName, 1) OVER (
        PARTITION BY v.VehicleID 
        ORDER BY r.ScheduledDate, r.ScheduledStartTime
    ) AS NextAssignedRoute,
    LEAD(r.ScheduledStartTime, 1) OVER (
        PARTITION BY v.VehicleID 
        ORDER BY r.ScheduledDate, r.ScheduledStartTime
    ) AS NextRouteStartTime
FROM Collection_Route r
JOIN Collection_Vehicle v ON r.VehicleID = v.VehicleID
ORDER BY v.VehicleNumber, r.ScheduledDate;

-- -----------------------------------------------------------------------------
-- QUERY 24: WINDOW FUNCTION - RUNNING & MOVING AVERAGE
-- Purpose: Compute moving average of collected waste per zone across timestamps.
-- -----------------------------------------------------------------------------
SELECT 
    cr.RecordID,
    z.ZoneName,
    cr.CollectionTimestamp,
    cr.CollectedWeightKg,
    ROUND(AVG(cr.CollectedWeightKg) OVER (
        PARTITION BY z.ZoneID 
        ORDER BY cr.CollectionTimestamp 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling4PickupAvgKg
FROM Collection_Record cr
JOIN Bin b ON cr.BinID = b.BinID
JOIN Zone z ON b.ZoneID = z.ZoneID
ORDER BY z.ZoneName, cr.CollectionTimestamp DESC
LIMIT 30;

-- -----------------------------------------------------------------------------
-- QUERY 25: COMPLEX COMMON TABLE EXPRESSION (CTE) WITH ANALYTICS
-- Purpose: Executive Municipal Sustainability & Circular Economy Scorecard.
-- -----------------------------------------------------------------------------
WITH ZoneMetrics AS (
    SELECT 
        z.ZoneID,
        z.ZoneName,
        z.TargetRecyclingRate,
        COUNT(DISTINCT b.BinID) AS BinCount,
        COALESCE(SUM(cr.CollectedWeightKg), 0.0) AS TotalCollectedKg
    FROM Zone z
    LEFT JOIN Bin b ON z.ZoneID = b.ZoneID
    LEFT JOIN Collection_Record cr ON b.BinID = cr.BinID
    GROUP BY z.ZoneID, z.ZoneName, z.TargetRecyclingRate
),
ComplaintMetrics AS (
    SELECT 
        cit.ZoneID,
        COUNT(c.ComplaintID) AS TotalComplaints,
        SUM(CASE WHEN c.Status = 'Resolved' THEN 1 ELSE 0 END) AS ResolvedComplaints
    FROM Citizen cit
    LEFT JOIN Complaint c ON cit.CitizenID = c.CitizenID
    GROUP BY cit.ZoneID
)
SELECT 
    zm.ZoneName,
    zm.BinCount,
    zm.TotalCollectedKg,
    COALESCE(cm.TotalComplaints, 0) AS TotalComplaints,
    COALESCE(cm.ResolvedComplaints, 0) AS ResolvedComplaints,
    CASE 
        WHEN COALESCE(cm.TotalComplaints, 0) > 0 THEN 
            ROUND((cm.ResolvedComplaints / cm.TotalComplaints) * 100.0, 1)
        ELSE 100.0 
    END AS GrievanceResolutionRatePct,
    DENSE_RANK() OVER (ORDER BY zm.TotalCollectedKg DESC) AS WasteGenerationRank
FROM ZoneMetrics zm
LEFT JOIN ComplaintMetrics cm ON zm.ZoneID = cm.ZoneID
ORDER BY zm.TotalCollectedKg DESC;
