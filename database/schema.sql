-- =============================================================================
-- SMART WASTE MANAGEMENT AND RECYCLING SYSTEM (SWMRS)
-- Database: MySQL 8.0+
-- Script: schema.sql
-- Description: Complete DDL with constraints, views, indexes, triggers,
--              stored procedures, and role-based security.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS waste_mgmt_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE waste_mgmt_db;

-- -----------------------------------------------------------------------------
-- 1. DROP EXISTING OBJECTS (CLEAN SLATE RE-EXECUTION)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_zone_waste_summary;
DROP VIEW IF EXISTS vw_recycling_rate_by_category;
DROP VIEW IF EXISTS vw_overflowing_bins;
DROP VIEW IF EXISTS vw_driver_performance;
DROP VIEW IF EXISTS vw_pending_complaints;

DROP TRIGGER IF EXISTS trg_sensor_auto_update_bin_status;
DROP TRIGGER IF EXISTS trg_audit_bin_update;
DROP TRIGGER IF EXISTS trg_prevent_vehicle_overload;
DROP TRIGGER IF EXISTS trg_update_recycling_stock;

DROP PROCEDURE IF EXISTS sp_assign_emergency_pickup;
DROP PROCEDURE IF EXISTS sp_generate_monthly_zone_report;
DROP PROCEDURE IF EXISTS sp_schedule_collection_route;
DROP FUNCTION IF EXISTS fn_calculate_recycling_rate;

DROP TABLE IF EXISTS AI_Prediction;
DROP TABLE IF EXISTS Audit_Log;
DROP TABLE IF EXISTS Complaint;
DROP TABLE IF EXISTS Sensor_Reading;
DROP TABLE IF EXISTS Collection_Record;
DROP TABLE IF EXISTS Collection_Route;
DROP TABLE IF EXISTS Bin;
DROP TABLE IF EXISTS Driver_Employee;
DROP TABLE IF EXISTS Collection_Vehicle;
DROP TABLE IF EXISTS Recycling_Batch;
DROP TABLE IF EXISTS Recycling_Facility;
DROP TABLE IF EXISTS Citizen;
DROP TABLE IF EXISTS Waste_Category;
DROP TABLE IF EXISTS Zone;
DROP TABLE IF EXISTS Users;

-- -----------------------------------------------------------------------------
-- 2. TABLE DEFINITIONS WITH INTEGRITY CONSTRAINTS
-- -----------------------------------------------------------------------------

-- Table 1: Users (Authentication & RBAC)
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role ENUM('Admin', 'Supervisor', 'Driver', 'Citizen') NOT NULL DEFAULT 'Citizen',
    Email VARCHAR(100) NOT NULL UNIQUE,
    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_format CHECK (Email LIKE '%_@__%.__%')
) ENGINE=InnoDB;

-- Table 2: Zone (Geographical administrative zones)
CREATE TABLE Zone (
    ZoneID INT AUTO_INCREMENT PRIMARY KEY,
    ZoneName VARCHAR(80) NOT NULL UNIQUE,
    City VARCHAR(50) NOT NULL DEFAULT 'Metro City',
    AreaSqKm DECIMAL(6,2) NOT NULL,
    PopulationDensity INT NOT NULL COMMENT 'People per sq km',
    TargetRecyclingRate DECIMAL(5,2) NOT NULL DEFAULT 65.00,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_zone_area CHECK (AreaSqKm > 0),
    CONSTRAINT chk_zone_pop CHECK (PopulationDensity >= 0),
    CONSTRAINT chk_zone_target CHECK (TargetRecyclingRate BETWEEN 0.00 AND 100.00)
) ENGINE=InnoDB;

-- Table 3: Waste_Category (Master classification of waste streams)
CREATE TABLE Waste_Category (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL,
    TargetRecyclingPct DECIMAL(5,2) NOT NULL DEFAULT 70.00,
    ToxicityLevel ENUM('None', 'Low', 'Moderate', 'High', 'Biohazard') NOT NULL DEFAULT 'None',
    HazardFlag BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_cat_target CHECK (TargetRecyclingPct BETWEEN 0.00 AND 100.00)
) ENGINE=InnoDB;

-- Table 4: Collection_Vehicle (Fleet assets)
CREATE TABLE Collection_Vehicle (
    VehicleID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleNumber VARCHAR(20) NOT NULL UNIQUE,
    VehicleType ENUM('Compactor Truck', 'Mini Tipper', 'Electric Van', 'Heavy Hauler') NOT NULL,
    CapacityKg DECIMAL(8,2) NOT NULL,
    FuelType ENUM('Diesel', 'CNG', 'Electric', 'Hybrid') NOT NULL DEFAULT 'CNG',
    OperationalStatus ENUM('Available', 'On Route', 'Maintenance', 'Decommissioned') NOT NULL DEFAULT 'Available',
    PurchaseDate DATE NOT NULL,
    CONSTRAINT chk_veh_capacity CHECK (CapacityKg > 100.00)
) ENGINE=InnoDB;

-- Table 5: Driver_Employee (Logistics workforce linked to user accounts)
CREATE TABLE Driver_Employee (
    DriverID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LicenseNumber VARCHAR(50) NOT NULL UNIQUE,
    Shift ENUM('Morning', 'Evening', 'Night') NOT NULL DEFAULT 'Morning',
    ExperienceYears INT NOT NULL DEFAULT 1,
    Status ENUM('Active', 'On Leave', 'Suspended') NOT NULL DEFAULT 'Active',
    Rating DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    CONSTRAINT fk_driver_user FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_driver_exp CHECK (ExperienceYears >= 0),
    CONSTRAINT chk_driver_rating CHECK (Rating BETWEEN 1.00 AND 5.00)
) ENGINE=InnoDB;

-- Table 6: Citizen (Community residents and commercial waste generators)
CREATE TABLE Citizen (
    CitizenID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    ZoneID INT NOT NULL,
    AddressLine VARCHAR(200) NOT NULL,
    RewardPoints INT NOT NULL DEFAULT 0,
    RegisteredAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_citizen_user FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_citizen_zone FOREIGN KEY (ZoneID) 
        REFERENCES Zone(ZoneID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_citizen_rewards CHECK (RewardPoints >= 0)
) ENGINE=InnoDB;

-- Table 7: Bin (Smart receptacle master)
CREATE TABLE Bin (
    BinID INT AUTO_INCREMENT PRIMARY KEY,
    BinCode VARCHAR(30) NOT NULL UNIQUE,
    ZoneID INT NOT NULL,
    CategoryID INT NOT NULL,
    CapacityLitres INT NOT NULL DEFAULT 1100,
    CurrentFillLevel DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    Latitude DECIMAL(10,8) NOT NULL,
    Longitude DECIMAL(11,8) NOT NULL,
    Status ENUM('NORMAL', 'NEEDS_ATTENTION', 'OVERFLOW_CRITICAL', 'DAMAGED', 'UNDER_MAINTENANCE') NOT NULL DEFAULT 'NORMAL',
    LastCleanedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bin_zone FOREIGN KEY (ZoneID) 
        REFERENCES Zone(ZoneID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_bin_category FOREIGN KEY (CategoryID) 
        REFERENCES Waste_Category(CategoryID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_bin_fill CHECK (CurrentFillLevel BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_bin_capacity CHECK (CapacityLitres > 0)
) ENGINE=InnoDB;

-- Table 8: Collection_Route (Scheduled logistics corridors)
CREATE TABLE Collection_Route (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    RouteName VARCHAR(100) NOT NULL,
    ZoneID INT NOT NULL,
    VehicleID INT NOT NULL,
    DriverID INT NOT NULL,
    ScheduledDate DATE NOT NULL,
    ScheduledStartTime TIME NOT NULL,
    EstimatedDistanceKm DECIMAL(5,2) NOT NULL DEFAULT 15.00,
    RouteStatus ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_route_zone FOREIGN KEY (ZoneID) 
        REFERENCES Zone(ZoneID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_route_vehicle FOREIGN KEY (VehicleID) 
        REFERENCES Collection_Vehicle(VehicleID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_route_driver FOREIGN KEY (DriverID) 
        REFERENCES Driver_Employee(DriverID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_route_distance CHECK (EstimatedDistanceKm > 0.00)
) ENGINE=InnoDB;

-- Table 9: Collection_Record (Granular waste emptying transactions)
CREATE TABLE Collection_Record (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    BinID INT NOT NULL,
    RouteID INT NOT NULL,
    DriverID INT NOT NULL,
    VehicleID INT NOT NULL,
    CollectedWeightKg DECIMAL(7,2) NOT NULL,
    FillLevelBefore DECIMAL(5,2) NOT NULL,
    CollectionTimestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    VerifiedBySupervisor BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_rec_bin FOREIGN KEY (BinID) 
        REFERENCES Bin(BinID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_rec_route FOREIGN KEY (RouteID) 
        REFERENCES Collection_Route(RouteID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_rec_driver FOREIGN KEY (DriverID) 
        REFERENCES Driver_Employee(DriverID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_rec_vehicle FOREIGN KEY (VehicleID) 
        REFERENCES Collection_Vehicle(VehicleID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_coll_weight CHECK (CollectedWeightKg >= 0.00),
    CONSTRAINT chk_coll_fillbefore CHECK (FillLevelBefore BETWEEN 0.00 AND 100.00)
) ENGINE=InnoDB;

-- Table 10: Recycling_Facility (Processing plants)
CREATE TABLE Recycling_Facility (
    FacilityID INT AUTO_INCREMENT PRIMARY KEY,
    FacilityName VARCHAR(100) NOT NULL UNIQUE,
    ZoneID INT NOT NULL,
    CapacityPerDayTons DECIMAL(7,2) NOT NULL,
    OperationalCostPerTon DECIMAL(8,2) NOT NULL DEFAULT 1200.00,
    ContactNumber VARCHAR(20) NOT NULL,
    Latitude DECIMAL(10,8) NOT NULL,
    Longitude DECIMAL(11,8) NOT NULL,
    TotalProcessedTons DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Status ENUM('Operational', 'At Capacity', 'Maintenance', 'Closed') NOT NULL DEFAULT 'Operational',
    CONSTRAINT fk_facility_zone FOREIGN KEY (ZoneID) 
        REFERENCES Zone(ZoneID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_fac_cap CHECK (CapacityPerDayTons > 0.00),
    CONSTRAINT chk_fac_cost CHECK (OperationalCostPerTon >= 0.00)
) ENGINE=InnoDB;

-- Table 11: Recycling_Batch (Transformation of waste into recyclable material)
CREATE TABLE Recycling_Batch (
    BatchID INT AUTO_INCREMENT PRIMARY KEY,
    FacilityID INT NOT NULL,
    CategoryID INT NOT NULL,
    InputWeightKg DECIMAL(8,2) NOT NULL,
    ProcessedWeightKg DECIMAL(8,2) NOT NULL,
    OutputRecycledKg DECIMAL(8,2) NOT NULL,
    ProcessingDate DATE NOT NULL,
    PurityRate DECIMAL(5,2) NOT NULL,
    BatchStatus ENUM('In Sorting', 'Processing', 'Quality Passed', 'Rejected') NOT NULL DEFAULT 'Processing',
    CONSTRAINT fk_batch_facility FOREIGN KEY (FacilityID) 
        REFERENCES Recycling_Facility(FacilityID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_batch_category FOREIGN KEY (CategoryID) 
        REFERENCES Waste_Category(CategoryID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_batch_input CHECK (InputWeightKg > 0.00),
    CONSTRAINT chk_batch_processed CHECK (ProcessedWeightKg <= InputWeightKg),
    CONSTRAINT chk_batch_output CHECK (OutputRecycledKg <= ProcessedWeightKg),
    CONSTRAINT chk_batch_purity CHECK (PurityRate BETWEEN 0.00 AND 100.00)
) ENGINE=InnoDB;

-- Table 12: Complaint (Citizen grievance redressal)
CREATE TABLE Complaint (
    ComplaintID INT AUTO_INCREMENT PRIMARY KEY,
    CitizenID INT NOT NULL,
    BinID INT NULL,
    ComplaintType ENUM('Overflowing Bin', 'Damaged Bin', 'Foul Odour', 'Missed Collection', 'Illegal Dumping') NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('Pending', 'Assigned', 'In Progress', 'Resolved', 'Rejected') NOT NULL DEFAULT 'Pending',
    LodgedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ResolvedAt TIMESTAMP NULL,
    ResolutionRemarks VARCHAR(255) NULL,
    CONSTRAINT fk_complaint_citizen FOREIGN KEY (CitizenID) 
        REFERENCES Citizen(CitizenID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_complaint_bin FOREIGN KEY (BinID) 
        REFERENCES Bin(BinID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table 13: Sensor_Reading (IoT Telemetry time-series)
CREATE TABLE Sensor_Reading (
    ReadingID BIGINT AUTO_INCREMENT PRIMARY KEY,
    BinID INT NOT NULL,
    FillPercentage DECIMAL(5,2) NOT NULL,
    BatteryLevelPct DECIMAL(5,2) NOT NULL,
    TemperatureCelsius DECIMAL(4,1) NOT NULL,
    TiltAngleDegrees DECIMAL(4,1) NOT NULL DEFAULT 0.0,
    ReadingTimestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sensor_bin FOREIGN KEY (BinID) 
        REFERENCES Bin(BinID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT chk_sensor_fill CHECK (FillPercentage BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_sensor_battery CHECK (BatteryLevelPct BETWEEN 0.00 AND 100.00)
) ENGINE=InnoDB;

-- Table 14: AI_Prediction (Machine learning inference audit log)
CREATE TABLE AI_Prediction (
    PredictionID INT AUTO_INCREMENT PRIMARY KEY,
    BinID INT NULL,
    ModelTask ENUM('Bin Overflow (Task 1)', 'Waste Classification (Task 4)', 'Recycling Recommendation (Task 5)') NOT NULL,
    PredictedClass VARCHAR(100) NOT NULL,
    ConfidenceScore DECIMAL(5,4) NOT NULL,
    FeaturesJson JSON NOT NULL,
    PredictedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pred_bin FOREIGN KEY (BinID) 
        REFERENCES Bin(BinID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table 15: Audit_Log (DBMS security & compliance log)
CREATE TABLE Audit_Log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50) NOT NULL,
    ActionType ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    RecordID INT NOT NULL,
    OldValue TEXT NULL,
    NewValue TEXT NULL,
    ChangedBy VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
    ChangedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. HIGH-PERFORMANCE INDEXES
-- -----------------------------------------------------------------------------
CREATE INDEX idx_bin_zone_status ON Bin(ZoneID, Status);
CREATE INDEX idx_bin_category ON Bin(CategoryID);
CREATE INDEX idx_sensor_bin_time ON Sensor_Reading(BinID, ReadingTimestamp DESC);
CREATE INDEX idx_collection_route_date ON Collection_Record(RouteID, CollectionTimestamp);
CREATE INDEX idx_collection_driver ON Collection_Record(DriverID, CollectionTimestamp);
CREATE INDEX idx_complaint_status_date ON Complaint(Status, LodgedAt DESC);
CREATE INDEX idx_route_scheduled ON Collection_Route(ScheduledDate, RouteStatus);
CREATE INDEX idx_batch_facility_date ON Recycling_Batch(FacilityID, ProcessingDate);

-- -----------------------------------------------------------------------------
-- 4. FIVE STRATEGIC DATABASE VIEWS
-- -----------------------------------------------------------------------------

-- View 1: Zone-wise Waste Generation & Target Summary
CREATE OR REPLACE VIEW vw_zone_waste_summary AS
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.PopulationDensity,
    COUNT(DISTINCT b.BinID) AS TotalBins,
    COALESCE(SUM(cr.CollectedWeightKg), 0.00) AS TotalCollectedKg,
    ROUND(COALESCE(SUM(cr.CollectedWeightKg) / NULLIF(z.AreaSqKm, 0), 0.00), 2) AS WasteDensityKgPerSqKm,
    z.TargetRecyclingRate,
    ROUND(COALESCE(AVG(b.CurrentFillLevel), 0.00), 2) AS AvgBinFillLevel
FROM Zone z
LEFT JOIN Bin b ON z.ZoneID = b.ZoneID
LEFT JOIN Collection_Record cr ON b.BinID = cr.BinID
GROUP BY z.ZoneID, z.ZoneName, z.PopulationDensity, z.AreaSqKm, z.TargetRecyclingRate;

-- View 2: Recycling Efficiency & Rate by Waste Category
CREATE OR REPLACE VIEW vw_recycling_rate_by_category AS
SELECT 
    wc.CategoryID,
    wc.CategoryName,
    wc.TargetRecyclingPct,
    COALESCE(SUM(rb.InputWeightKg), 0.00) AS TotalInputKg,
    COALESCE(SUM(rb.OutputRecycledKg), 0.00) AS TotalRecycledKg,
    CASE 
        WHEN SUM(rb.InputWeightKg) > 0 THEN 
            ROUND((SUM(rb.OutputRecycledKg) / SUM(rb.InputWeightKg)) * 100.0, 2)
        ELSE 0.00 
    END AS ActualRecyclingRatePct,
    ROUND(AVG(rb.PurityRate), 2) AS AvgBatchPurity
FROM Waste_Category wc
LEFT JOIN Recycling_Batch rb ON wc.CategoryID = rb.CategoryID
GROUP BY wc.CategoryID, wc.CategoryName, wc.TargetRecyclingPct;

-- View 3: Overflowing & Critical Bins Needing Immediate Dispatch
CREATE OR REPLACE VIEW vw_overflowing_bins AS
SELECT 
    b.BinID,
    b.BinCode,
    z.ZoneName,
    wc.CategoryName,
    b.CapacityLitres,
    b.CurrentFillLevel,
    b.Status,
    b.LastCleanedAt,
    TIMESTAMPDIFF(HOUR, b.LastCleanedAt, NOW()) AS HoursSinceLastService,
    b.Latitude,
    b.Longitude
FROM Bin b
JOIN Zone z ON b.ZoneID = z.ZoneID
JOIN Waste_Category wc ON b.CategoryID = wc.CategoryID
WHERE b.CurrentFillLevel >= 85.00 OR b.Status = 'OVERFLOW_CRITICAL';

-- View 4: Driver Fleet Performance & Productivity KPI
CREATE OR REPLACE VIEW vw_driver_performance AS
SELECT 
    d.DriverID,
    u.FullName AS DriverName,
    d.Shift,
    d.ExperienceYears,
    d.Rating,
    COUNT(DISTINCT r.RouteID) AS TotalRoutesAssigned,
    COUNT(cr.RecordID) AS TotalBinsEmptied,
    COALESCE(SUM(cr.CollectedWeightKg), 0.00) AS TotalWeightCollectedKg,
    ROUND(COALESCE(AVG(cr.CollectedWeightKg), 0.00), 2) AS AvgWeightPerBinKg
FROM Driver_Employee d
JOIN Users u ON d.UserID = u.UserID
LEFT JOIN Collection_Route r ON d.DriverID = r.DriverID
LEFT JOIN Collection_Record cr ON d.DriverID = cr.DriverID
GROUP BY d.DriverID, u.FullName, d.Shift, d.ExperienceYears, d.Rating;

-- View 5: Pending Citizen Grievances & Resolution Aging
CREATE OR REPLACE VIEW vw_pending_complaints AS
SELECT 
    c.ComplaintID,
    u.FullName AS CitizenName,
    u.Phone AS CitizenPhone,
    z.ZoneName,
    b.BinCode,
    c.ComplaintType,
    c.Description,
    c.Status,
    c.LodgedAt,
    TIMESTAMPDIFF(HOUR, c.LodgedAt, NOW()) AS AgingHours,
    CASE 
        WHEN TIMESTAMPDIFF(HOUR, c.LodgedAt, NOW()) > 48 THEN 'SLA BREACHED'
        WHEN TIMESTAMPDIFF(HOUR, c.LodgedAt, NOW()) > 24 THEN 'HIGH PRIORITY'
        ELSE 'NORMAL'
    END AS UrgencyLevel
FROM Complaint c
JOIN Citizen cit ON c.CitizenID = cit.CitizenID
JOIN Users u ON cit.UserID = u.UserID
JOIN Zone z ON cit.ZoneID = z.ZoneID
LEFT JOIN Bin b ON c.BinID = b.BinID
WHERE c.Status IN ('Pending', 'In Progress');

-- -----------------------------------------------------------------------------
-- 5. FOUR DATABASE TRIGGERS
-- -----------------------------------------------------------------------------

-- Trigger 1: Auto-update Bin status and fill level from Sensor Readings
DELIMITER $$
CREATE TRIGGER trg_sensor_auto_update_bin_status
AFTER INSERT ON Sensor_Reading
FOR EACH ROW
BEGIN
    DECLARE v_new_status VARCHAR(30);

    IF NEW.FillPercentage >= 90.00 THEN
        SET v_new_status = 'OVERFLOW_CRITICAL';
    ELSEIF NEW.FillPercentage >= 75.00 THEN
        SET v_new_status = 'NEEDS_ATTENTION';
    ELSE
        SET v_new_status = 'NORMAL';
    END IF;

    UPDATE Bin
    SET CurrentFillLevel = NEW.FillPercentage,
        Status = v_new_status
    WHERE BinID = NEW.BinID;
END$$
DELIMITER ;

-- Trigger 2: Audit Logging on Bin Configuration or Status Modifications
DELIMITER $$
CREATE TRIGGER trg_audit_bin_update
AFTER UPDATE ON Bin
FOR EACH ROW
BEGIN
    IF (OLD.Status != NEW.Status) OR (OLD.CurrentFillLevel != NEW.CurrentFillLevel) THEN
        INSERT INTO Audit_Log (TableName, ActionType, RecordID, OldValue, NewValue, ChangedBy, ChangedAt)
        VALUES (
            'Bin',
            'UPDATE',
            NEW.BinID,
            CONCAT('Status=', OLD.Status, ', FillLevel=', OLD.CurrentFillLevel),
            CONCAT('Status=', NEW.Status, ', FillLevel=', NEW.CurrentFillLevel),
            COALESCE(@current_app_user, 'SYSTEM_TRIGGER'),
            NOW()
        );
    END IF;
END$$
DELIMITER ;

-- Trigger 3: Prevent Vehicle Overload on Collection Dispatch
DELIMITER $$
CREATE TRIGGER trg_prevent_vehicle_overload
BEFORE INSERT ON Collection_Record
FOR EACH ROW
BEGIN
    DECLARE v_veh_capacity DECIMAL(8,2);
    DECLARE v_current_route_load DECIMAL(8,2);

    -- Get max vehicle capacity
    SELECT CapacityKg INTO v_veh_capacity
    FROM Collection_Vehicle
    WHERE VehicleID = NEW.VehicleID;

    -- Calculate current weight already collected in this route
    SELECT COALESCE(SUM(CollectedWeightKg), 0.00) INTO v_current_route_load
    FROM Collection_Record
    WHERE RouteID = NEW.RouteID;

    -- Check if new collection exceeds rated limit
    IF (v_current_route_load + NEW.CollectedWeightKg) > v_veh_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction Rejected: Collection weight exceeds maximum vehicle payload capacity.';
    END IF;
END$$
DELIMITER ;

-- Trigger 4: Update Recycling Facility Processed Stock & Output Statistics
DELIMITER $$
CREATE TRIGGER trg_update_recycling_stock
AFTER INSERT ON Recycling_Batch
FOR EACH ROW
BEGIN
    UPDATE Recycling_Facility
    SET TotalProcessedTons = TotalProcessedTons + (NEW.ProcessedWeightKg / 1000.0)
    WHERE FacilityID = NEW.FacilityID;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 6. FOUR STORED PROCEDURES AND FUNCTIONS
-- -----------------------------------------------------------------------------

-- Procedure 1: Dispatch Emergency Pickup for an Overflowing Bin
DELIMITER $$
CREATE PROCEDURE sp_assign_emergency_pickup(
    IN p_bin_id INT,
    OUT p_route_id INT
)
proc_label: BEGIN
    DECLARE v_zone_id INT;
    DECLARE v_driver_id INT;
    DECLARE v_vehicle_id INT;

    -- Fetch bin's zone
    SELECT ZoneID INTO v_zone_id FROM Bin WHERE BinID = p_bin_id;
    IF v_zone_id IS NULL THEN
        SET p_route_id = -1;
        LEAVE proc_label;
    END IF;

    -- Find an available driver
    SELECT DriverID INTO v_driver_id
    FROM Driver_Employee
    WHERE Status = 'Active'
    ORDER BY Rating DESC, ExperienceYears DESC
    LIMIT 1;

    -- Find an available vehicle
    SELECT VehicleID INTO v_vehicle_id
    FROM Collection_Vehicle
    WHERE OperationalStatus = 'Available'
    ORDER BY CapacityKg DESC
    LIMIT 1;

    IF v_driver_id IS NULL OR v_vehicle_id IS NULL THEN
        SET p_route_id = 0; -- Indicating resource shortage
        LEAVE proc_label;
    END IF;

    -- Create an Emergency Route
    INSERT INTO Collection_Route (
        RouteName, ZoneID, VehicleID, DriverID, ScheduledDate, ScheduledStartTime, EstimatedDistanceKm, RouteStatus
    ) VALUES (
        CONCAT('EMERGENCY-BIN-', p_bin_id, '-', CURDATE()),
        v_zone_id,
        v_vehicle_id,
        v_driver_id,
        CURDATE(),
        CURTIME(),
        8.50,
        'Scheduled'
    );

    SET p_route_id = LAST_INSERT_ID();

    -- Mark vehicle as assigned
    UPDATE Collection_Vehicle SET OperationalStatus = 'On Route' WHERE VehicleID = v_vehicle_id;
    
    -- Mark bin as being handled
    UPDATE Bin SET Status = 'NEEDS_ATTENTION' WHERE BinID = p_bin_id;
END$$
DELIMITER ;

-- Procedure 2: Generate Monthly Zone Performance Report
DELIMITER $$
CREATE PROCEDURE sp_generate_monthly_zone_report(
    IN p_month INT,
    IN p_year INT
)
BEGIN
    SELECT 
        z.ZoneName,
        COUNT(DISTINCT b.BinID) AS ActiveBins,
        COUNT(cr.RecordID) AS TotalEmptyings,
        COALESCE(SUM(cr.CollectedWeightKg), 0.00) AS TotalCollectedWeightKg,
        ROUND(AVG(cr.CollectedWeightKg), 2) AS AvgWeightPerPickupKg,
        COUNT(DISTINCT c.ComplaintID) AS ComplaintsLogged,
        z.TargetRecyclingRate
    FROM Zone z
    LEFT JOIN Bin b ON z.ZoneID = b.ZoneID
    LEFT JOIN Collection_Record cr ON b.BinID = cr.BinID 
        AND MONTH(cr.CollectionTimestamp) = p_month 
        AND YEAR(cr.CollectionTimestamp) = p_year
    LEFT JOIN Citizen cit ON z.ZoneID = cit.ZoneID
    LEFT JOIN Complaint c ON cit.CitizenID = c.CitizenID 
        AND MONTH(c.LodgedAt) = p_month 
        AND YEAR(c.LodgedAt) = p_year
    GROUP BY z.ZoneID, z.ZoneName, z.TargetRecyclingRate
    ORDER BY TotalCollectedWeightKg DESC;
END$$
DELIMITER ;

-- Function 3: Calculate Cumulative Recycling Rate for a Category
DELIMITER $$
CREATE FUNCTION fn_calculate_recycling_rate(p_category_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_input DECIMAL(10,2);
    DECLARE v_recycled DECIMAL(10,2);
    DECLARE v_rate DECIMAL(5,2);

    SELECT COALESCE(SUM(InputWeightKg), 0.00), COALESCE(SUM(OutputRecycledKg), 0.00)
    INTO v_input, v_recycled
    FROM Recycling_Batch
    WHERE CategoryID = p_category_id;

    IF v_input = 0.00 THEN
        RETURN 0.00;
    END IF;

    SET v_rate = ROUND((v_recycled / v_input) * 100.0, 2);
    RETURN v_rate;
END$$
DELIMITER ;

-- Procedure 4: Schedule Standard Automated Collection Route
DELIMITER $$
CREATE PROCEDURE sp_schedule_collection_route(
    IN p_zone_id INT,
    IN p_driver_id INT,
    IN p_vehicle_id INT,
    OUT p_route_id INT
)
BEGIN
    DECLARE v_zone_name VARCHAR(80);
    SELECT ZoneName INTO v_zone_name FROM Zone WHERE ZoneID = p_zone_id;

    INSERT INTO Collection_Route (
        RouteName, ZoneID, VehicleID, DriverID, ScheduledDate, ScheduledStartTime, EstimatedDistanceKm, RouteStatus
    ) VALUES (
        CONCAT('ROUTE-', v_zone_name, '-', CURDATE()),
        p_zone_id,
        p_vehicle_id,
        p_driver_id,
        CURDATE(),
        '06:00:00',
        18.50,
        'Scheduled'
    );

    SET p_route_id = LAST_INSERT_ID();
    UPDATE Collection_Vehicle SET OperationalStatus = 'On Route' WHERE VehicleID = p_vehicle_id;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 7. ROLE-BASED ACCESS CONTROL (RBAC) & PERMISSIONS
-- -----------------------------------------------------------------------------
DROP ROLE IF EXISTS 'AdminRole', 'SupervisorRole', 'DriverRole', 'CitizenRole';

CREATE ROLE 'AdminRole';
CREATE ROLE 'SupervisorRole';
CREATE ROLE 'DriverRole';
CREATE ROLE 'CitizenRole';

GRANT ALL PRIVILEGES ON waste_mgmt_db.* TO 'AdminRole';

GRANT SELECT, INSERT, UPDATE ON waste_mgmt_db.Bin TO 'SupervisorRole';
GRANT SELECT, INSERT, UPDATE ON waste_mgmt_db.Collection_Route TO 'SupervisorRole';
GRANT SELECT, INSERT ON waste_mgmt_db.Collection_Record TO 'SupervisorRole';
GRANT SELECT, UPDATE ON waste_mgmt_db.Complaint TO 'SupervisorRole';
GRANT SELECT, INSERT, UPDATE ON waste_mgmt_db.Recycling_Batch TO 'SupervisorRole';
GRANT SELECT ON waste_mgmt_db.* TO 'SupervisorRole';
GRANT EXECUTE ON waste_mgmt_db.* TO 'SupervisorRole';

GRANT SELECT ON waste_mgmt_db.Collection_Route TO 'DriverRole';
GRANT SELECT ON waste_mgmt_db.Bin TO 'DriverRole';
GRANT INSERT ON waste_mgmt_db.Collection_Record TO 'DriverRole';
GRANT UPDATE (Status, LastCleanedAt, CurrentFillLevel) ON waste_mgmt_db.Bin TO 'DriverRole';

GRANT SELECT ON waste_mgmt_db.Bin TO 'CitizenRole';
GRANT SELECT, INSERT ON waste_mgmt_db.Complaint TO 'CitizenRole';
GRANT SELECT ON waste_mgmt_db.vw_recycling_rate_by_category TO 'CitizenRole';
GRANT SELECT ON waste_mgmt_db.vw_zone_waste_summary TO 'CitizenRole';
