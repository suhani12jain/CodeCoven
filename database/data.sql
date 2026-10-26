-- =============================================================================
-- SMART WASTE MANAGEMENT AND RECYCLING SYSTEM (SWMRS)
-- Database: MySQL 8.0+
-- Script: data.sql
-- Description: Realistic Seed Data for Master & Transactional Entities
-- =============================================================================

USE waste_mgmt_db;

-- -----------------------------------------------------------------------------
-- 1. USERS (Password for all default accounts is 'admin123' or 'user123')
-- Hash format: PBKDF2 / SHA256 consistent for Flask/Werkzeug
-- Hash for 'password123': pbkdf2:sha256:600000$c1e8d9e7a... or standard mock hash
-- -----------------------------------------------------------------------------
INSERT INTO Users (UserID, Username, PasswordHash, Role, Email, FullName, Phone, IsActive) VALUES
(1,  'admin',        'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Admin',      'admin@swmrs.gov.in',      'Vikramaditya Sharma', '+91-9876543210', 1),
(2,  'super_rahul',  'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Supervisor', 'rahul.verma@swmrs.gov.in',  'Rahul Verma',         '+91-9811223344', 1),
(3,  'super_priya',  'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Supervisor', 'priya.nair@swmrs.gov.in',   'Priya Nair',          '+91-9822334455', 1),
(4,  'driver_amit',  'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'amit.singh@swmrs.gov.in',   'Amit Singh',          '+91-9711002233', 1),
(5,  'driver_rajesh','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'rajesh.k@swmrs.gov.in',     'Rajesh Kumar',        '+91-9722113344', 1),
(6,  'driver_suresh','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'suresh.yadav@swmrs.gov.in', 'Suresh Yadav',        '+91-9733224455', 1),
(7,  'driver_manoj', 'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'manoj.t@swmrs.gov.in',      'Manoj Tiwari',        '+91-9744335566', 1),
(8,  'driver_deepak','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'deepak.p@swmrs.gov.in',     'Deepak Patel',        '+91-9755446677', 1),
(9,  'driver_karan', 'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'karan.j@swmrs.gov.in',      'Karan Joshi',         '+91-9766557788', 1),
(10, 'driver_anand', 'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Driver',     'anand.r@swmrs.gov.in',      'Anand Rao',           '+91-9777668899', 1),
(11, 'citizen_anita','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'anita.deshmukh@gmail.com',  'Anita Deshmukh',      '+91-9988776655', 1),
(12, 'citizen_rohit','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'rohit.sharma88@gmail.com',  'Rohit Sharma',        '+91-9977665544', 1),
(13, 'citizen_sneha','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'sneha.kulkarni@gmail.com',  'Sneha Kulkarni',      '+91-9966554433', 1),
(14, 'citizen_arjun','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'arjun.mehta@yahoo.com',     'Arjun Mehta',         '+91-9955443322', 1),
(15, 'citizen_pooja','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'pooja.hegde@outlook.com',   'Pooja Hegde',         '+91-9944332211', 1),
(16, 'citizen_varun','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'varun.dhawan9@gmail.com',   'Varun Dhawan',        '+91-9933221100', 1),
(17, 'citizen_kavita','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c','Citizen',    'kavita.sen@gmail.com',      'Kavita Sen',          '+91-9922110099', 1),
(18, 'citizen_alok', 'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'alok.nath@gmail.com',       'Alok Nath',           '+91-9911009988', 1),
(19, 'citizen_neha', 'pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'neha.bhasin@hotmail.com',   'Neha Bhasin',         '+91-9900998877', 1),
(20, 'citizen_sunil','pbkdf2:sha256:260000$WvQJvC0X8P$3448b1aa618684693a2eb681da0d170f80bc40fb518ff7aa8df621571434190c', 'Citizen',    'sunil.grover@gmail.com',    'Sunil Grover',        '+91-9899887766', 1);

-- -----------------------------------------------------------------------------
-- 2. ZONE (15 Municipal Administrative Zones)
-- -----------------------------------------------------------------------------
INSERT INTO Zone (ZoneID, ZoneName, City, AreaSqKm, PopulationDensity, TargetRecyclingRate) VALUES
(1,  'Central Business District (CBD)', 'Metro City', 12.50, 14500, 75.00),
(2,  'North Tech Corridor',             'Metro City', 24.80, 9200,  80.00),
(3,  'Green Meadows Residential',       'Metro City', 18.20, 6800,  70.00),
(4,  'Old Town Commercial Market',      'Metro City',  8.40, 22000, 60.00),
(5,  'Harbor Industrial Estate',        'Metro City', 32.00, 3100,  85.00),
(6,  'Riverdale Suburban Enclave',      'Metro City', 15.60, 5400,  68.00),
(7,  'East University Campus Zone',     'Metro City', 11.30, 8900,  72.00),
(8,  'South Medical & Hospital Hub',    'Metro City',  9.10, 11200, 88.00),
(9,  'Western Heights Hills',           'Metro City', 21.00, 4200,  65.00),
(10, 'Lakeside Promenade & Tourism',    'Metro City',  7.80, 7800,  70.00),
(11, 'Airport Aerocity Logistics',      'Metro City', 28.50, 2500,  78.00),
(12, 'Metro Junction Railway Colony',   'Metro City', 10.40, 16500, 62.00),
(13, 'Textile & Garment Cluster',       'Metro City', 14.20, 8300,  74.00),
(14, 'Cyber Hills Financial District',  'Metro City', 16.90, 12800, 82.00),
(15, 'Heritage Cultural Quarter',       'Metro City',  6.50, 18400, 58.00);

-- -----------------------------------------------------------------------------
-- 3. WASTE_CATEGORY (7 Standard Waste Streams)
-- -----------------------------------------------------------------------------
INSERT INTO Waste_Category (CategoryID, CategoryName, Description, TargetRecyclingPct, ToxicityLevel, HazardFlag) VALUES
(1, 'Organic / Wet Waste',   'Kitchen waste, food scraps, garden foliage, compostable matter', 85.00, 'None',      0),
(2, 'Recyclable Plastic',    'PET bottles, HDPE containers, LDPE film, PP packaging',          75.00, 'Low',       0),
(3, 'Paper & Cardboard',     'Newspapers, corrugated boxes, office stationery, cartons',       90.00, 'None',      0),
(4, 'Metal & Aluminum',      'Beverage cans, tin boxes, iron scrap, copper wires',             95.00, 'Low',       0),
(5, 'Glass & Ceramics',      'Beverage bottles, glass jars, broken architectural panes',       80.00, 'Low',       0),
(6, 'Electronic Waste',      'Batteries, PCBs, discarded gadgets, wiring, CFLs',               65.00, 'High',      1),
(7, 'Hazardous & Medical',   'Sanitary items, chemical containers, biohazard laboratory swabs',40.00, 'Biohazard', 1);

-- -----------------------------------------------------------------------------
-- 4. COLLECTION_VEHICLE (15 Operational Fleet Assets)
-- -----------------------------------------------------------------------------
INSERT INTO Collection_Vehicle (VehicleID, VehicleNumber, VehicleType, CapacityKg, FuelType, OperationalStatus, PurchaseDate) VALUES
(1,  'MH-12-TR-1001', 'Compactor Truck', 7500.00, 'CNG',      'Available',   '2021-03-15'),
(2,  'MH-12-TR-1002', 'Compactor Truck', 7500.00, 'CNG',      'On Route',    '2021-03-15'),
(3,  'MH-12-TR-1003', 'Compactor Truck', 8000.00, 'Diesel',   'Available',   '2020-08-20'),
(4,  'MH-12-MT-2001', 'Mini Tipper',     2500.00, 'Electric',  'Available',   '2022-01-10'),
(5,  'MH-12-MT-2002', 'Mini Tipper',     2500.00, 'Electric',  'On Route',    '2022-01-10'),
(6,  'MH-12-MT-2003', 'Mini Tipper',     3000.00, 'CNG',       'Available',   '2022-05-18'),
(7,  'MH-12-EV-3001', 'Electric Van',    1500.00, 'Electric',  'Available',   '2023-02-01'),
(8,  'MH-12-EV-3002', 'Electric Van',    1500.00, 'Electric',  'On Route',    '2023-02-01'),
(9,  'MH-12-EV-3003', 'Electric Van',    1800.00, 'Electric',  'Maintenance', '2023-06-12'),
(10, 'MH-12-HH-4001', 'Heavy Hauler',   12000.00, 'Diesel',   'Available',   '2019-11-05'),
(11, 'MH-12-HH-4002', 'Heavy Hauler',   12000.00, 'Diesel',   'Available',   '2019-11-05'),
(12, 'MH-12-TR-1004', 'Compactor Truck', 7500.00, 'Hybrid',   'Available',   '2023-09-14'),
(13, 'MH-12-MT-2004', 'Mini Tipper',     2800.00, 'CNG',       'Available',   '2022-11-20'),
(14, 'MH-12-EV-3004', 'Electric Van',    1500.00, 'Electric',  'Available',   '2024-01-08'),
(15, 'MH-12-HH-4003', 'Heavy Hauler',   14000.00, 'Diesel',   'Maintenance', '2018-04-22');

-- -----------------------------------------------------------------------------
-- 5. DRIVER_EMPLOYEE (7 Active Drivers linked to Users table)
-- -----------------------------------------------------------------------------
INSERT INTO Driver_Employee (DriverID, UserID, LicenseNumber, Shift, ExperienceYears, Status, Rating) VALUES
(1, 4,  'DL-MH-2015-001234', 'Morning', 8, 'Active', 4.85),
(2, 5,  'DL-MH-2017-005678', 'Morning', 6, 'Active', 4.90),
(3, 6,  'DL-MH-2014-009988', 'Evening', 9, 'Active', 4.70),
(4, 7,  'DL-MH-2019-003322', 'Evening', 4, 'Active', 4.65),
(5, 8,  'DL-MH-2016-004411', 'Night',   7, 'Active', 4.80),
(6, 9,  'DL-MH-2021-007766', 'Morning', 3, 'Active', 4.50),
(7, 10, 'DL-MH-2013-008855', 'Evening',10, 'Active', 4.95);

-- -----------------------------------------------------------------------------
-- 6. CITIZEN (10 Registered Residents linked to Users table)
-- -----------------------------------------------------------------------------
INSERT INTO Citizen (CitizenID, UserID, ZoneID, AddressLine, RewardPoints) VALUES
(1,  11, 1,  'Flat 402, Royal Residency, MG Road',        240),
(2,  12, 2,  'Bungalow 12, Tech Park Enclave, Phase 1',    410),
(3,  13, 3,  'House 88, Green Meadows 2nd Cross',         180),
(4,  14, 4,  'Shop 15, Old Bazaar Main Lane',             320),
(5,  15, 6,  'Villa 45, Riverdale Palm Avenue',           550),
(6,  16, 7,  'Room 204, Scholars Hostel, Campus Road',    120),
(7,  17, 8,  'Staff Quarters B-3, Apollo Medical Enclave',290),
(8,  18, 9,  'Plot 67, Western Crest Road',               150),
(9,  19, 10, 'Skyline Towers A-1002, Lakeview Blvd',      380),
(10, 20, 14, 'Penthouse 16, Cyber Heights, Sector 5',    620);

-- -----------------------------------------------------------------------------
-- 7. RECYCLING_FACILITY (10 Processing Plants)
-- -----------------------------------------------------------------------------
INSERT INTO Recycling_Facility (FacilityID, FacilityName, ZoneID, CapacityPerDayTons, OperationalCostPerTon, ContactNumber, Latitude, Longitude, TotalProcessedTons, Status) VALUES
(1,  'EcoCycle Green Composting Plant',     3,  150.00,  850.00, '+91-20-25671111', 18.53200000, 73.85400000, 1420.50, 'Operational'),
(2,  'PolyReclaim Plastics Refinery',       5,  200.00, 1400.00, '+91-20-25672222', 18.51000000, 73.91000000, 2180.00, 'Operational'),
(3,  'KagazCraft Pulp & Cardboard Mills',   13, 120.00,  950.00, '+91-20-25673333', 18.49500000, 73.83200000,  980.25, 'Operational'),
(4,  'MetalForge Scrap Smelting Yard',      5,  250.00, 1800.00, '+91-20-25674444', 18.50500000, 73.92500000, 3120.80, 'Operational'),
(5,  'Vitreous Clean Glass Melting Works',  11,  80.00, 1100.00, '+91-20-25675555', 18.57000000, 73.89000000,  640.40, 'Operational'),
(6,  'CircuitSafe Urban E-Waste Recycler',  2,   50.00, 3200.00, '+91-20-25676666', 18.56000000, 73.79000000,  410.15, 'Operational'),
(7,  'BioClean Medical Autoclave Facility', 8,   40.00, 4500.00, '+91-20-25677777', 18.48000000, 73.86000000,  325.60, 'Operational'),
(8,  'Apex Material Recovery Facility (MRF)',1, 300.00, 1600.00, '+91-20-25678888', 18.52500000, 73.85000000, 4100.00, 'Operational'),
(9,  'Western Suburbs Composting Yard',     9,   90.00,  880.00, '+91-20-25679999', 18.51500000, 73.78000000,  710.00, 'Operational'),
(10, 'Harbor Secondary Smelting Unit',      5,  180.00, 1950.00, '+91-20-25670000', 18.50200000, 73.93000000, 1850.20, 'At Capacity');

-- -----------------------------------------------------------------------------
-- 8. BIN (30 Smart Receptacles with Geo-coordinates and IoT parameters)
-- -----------------------------------------------------------------------------
INSERT INTO Bin (BinID, BinCode, ZoneID, CategoryID, CapacityLitres, CurrentFillLevel, Latitude, Longitude, Status, LastCleanedAt) VALUES
(1,  'BIN-Z01-ORG-01', 1,  1, 1100, 45.50, 18.52043000, 73.85674000, 'NORMAL',            NOW() - INTERVAL 12 HOUR),
(2,  'BIN-Z01-PLS-02', 1,  2, 1100, 92.40, 18.52110000, 73.85720000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 36 HOUR),
(3,  'BIN-Z01-PPR-03', 1,  3, 1100, 68.00, 18.51980000, 73.85590000, 'NORMAL',            NOW() - INTERVAL 18 HOUR),
(4,  'BIN-Z02-ORG-01', 2,  1, 1500, 88.50, 18.55820000, 73.79150000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 24 HOUR),
(5,  'BIN-Z02-EWT-02', 2,  6,  660, 32.00, 18.55940000, 73.79280000, 'NORMAL',            NOW() - INTERVAL 48 HOUR),
(6,  'BIN-Z02-PLS-03', 2,  2, 1100, 94.80, 18.55760000, 73.79040000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 40 HOUR),
(7,  'BIN-Z03-ORG-01', 3,  1, 1100, 52.00, 18.53150000, 73.85320000, 'NORMAL',            NOW() - INTERVAL 10 HOUR),
(8,  'BIN-Z03-GLS-02', 3,  5,  660, 25.50, 18.53240000, 73.85410000, 'NORMAL',            NOW() - INTERVAL 72 HOUR),
(9,  'BIN-Z04-ORG-01', 4,  1, 1500, 96.20, 18.51450000, 73.85880000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 28 HOUR),
(10, 'BIN-Z04-MTL-02', 4,  4, 1100, 74.00, 18.51520000, 73.85950000, 'NORMAL',            NOW() - INTERVAL 16 HOUR),
(11, 'BIN-Z05-MTL-01', 5,  4, 2000, 60.00, 18.50850000, 73.91820000, 'NORMAL',            NOW() - INTERVAL 20 HOUR),
(12, 'BIN-Z05-PLS-02', 5,  2, 1500, 89.00, 18.50920000, 73.91900000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 26 HOUR),
(13, 'BIN-Z06-ORG-01', 6,  1, 1100, 40.00, 18.54200000, 73.82100000, 'NORMAL',            NOW() - INTERVAL 8 HOUR),
(14, 'BIN-Z06-PPR-02', 6,  3, 1100, 58.50, 18.54310000, 73.82220000, 'NORMAL',            NOW() - INTERVAL 14 HOUR),
(15, 'BIN-Z07-PPR-01', 7,  3, 1500, 91.50, 18.52800000, 73.83400000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 32 HOUR),
(16, 'BIN-Z07-EWT-02', 7,  6,  660, 44.00, 18.52900000, 73.83500000, 'NORMAL',            NOW() - INTERVAL 50 HOUR),
(17, 'BIN-Z08-HAZ-01', 8,  7,  660, 78.00, 18.48500000, 73.86200000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 18 HOUR),
(18, 'BIN-Z08-ORG-02', 8,  1, 1100, 35.00, 18.48620000, 73.86310000, 'NORMAL',            NOW() - INTERVAL 6 HOUR),
(19, 'BIN-Z09-ORG-01', 9,  1, 1100, 62.00, 18.51800000, 73.78200000, 'NORMAL',            NOW() - INTERVAL 15 HOUR),
(20, 'BIN-Z10-PLS-01', 10, 2, 1100, 95.00, 18.53600000, 73.84200000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 42 HOUR),
(21, 'BIN-Z11-MTL-01', 11, 4, 1500, 50.00, 18.57200000, 73.89200000, 'NORMAL',            NOW() - INTERVAL 22 HOUR),
(22, 'BIN-Z12-ORG-01', 12, 1, 1500, 93.50, 18.52200000, 73.86800000, 'OVERFLOW_CRITICAL', NOW() - INTERVAL 30 HOUR),
(23, 'BIN-Z13-PPR-01', 13, 3, 1100, 71.00, 18.49800000, 73.83500000, 'NORMAL',            NOW() - INTERVAL 16 HOUR),
(24, 'BIN-Z14-EWT-01', 14, 6,  660, 82.00, 18.54800000, 73.80500000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 35 HOUR),
(25, 'BIN-Z15-ORG-01', 15, 1, 1100, 89.50, 18.51100000, 73.86400000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 25 HOUR),
(26, 'BIN-Z01-GLS-04', 1,  5,  660, 15.00, 18.52250000, 73.85800000, 'NORMAL',            NOW() - INTERVAL 60 HOUR),
(27, 'BIN-Z02-MTL-04', 2,  4, 1100, 64.00, 18.56000000, 73.79300000, 'NORMAL',            NOW() - INTERVAL 19 HOUR),
(28, 'BIN-Z03-PLS-03', 3,  2, 1100, 77.00, 18.53300000, 73.85500000, 'NEEDS_ATTENTION',   NOW() - INTERVAL 21 HOUR),
(29, 'BIN-Z04-PPR-03', 4,  3, 1100, 48.00, 18.51600000, 73.86000000, 'NORMAL',            NOW() - INTERVAL 11 HOUR),
(30, 'BIN-Z05-HAZ-03', 5,  7,  660, 20.00, 18.51000000, 73.92000000, 'NORMAL',            NOW() - INTERVAL 45 HOUR);

-- -----------------------------------------------------------------------------
-- 9. COLLECTION_ROUTE (15 Operational Routes)
-- -----------------------------------------------------------------------------
INSERT INTO Collection_Route (RouteID, RouteName, ZoneID, VehicleID, DriverID, ScheduledDate, ScheduledStartTime, EstimatedDistanceKm, RouteStatus) VALUES
(1,  'ROUTE-CBD-MORNING',        1,  1, 1, CURDATE(), '06:00:00', 14.50, 'Completed'),
(2,  'ROUTE-TECH-MORNING',       2,  2, 2, CURDATE(), '06:30:00', 22.00, 'In Progress'),
(3,  'ROUTE-MEADOWS-EVENING',    3,  4, 3, CURDATE(), '14:00:00', 16.00, 'Scheduled'),
(4,  'ROUTE-OLDTOWN-NIGHT',      4,  3, 5, CURDATE(), '22:00:00', 12.00, 'Scheduled'),
(5,  'ROUTE-HARBOR-HEAVY',       5, 10, 4, CURDATE(), '07:00:00', 35.00, 'Completed'),
(6,  'ROUTE-RIVERDALE-EVENING',  6,  6, 3, CURDATE(), '15:30:00', 18.50, 'Scheduled'),
(7,  'ROUTE-CAMPUS-MORNING',     7,  5, 6, CURDATE(), '06:00:00', 13.00, 'Completed'),
(8,  'ROUTE-HOSPITAL-HAZARD',    8,  7, 7, CURDATE(), '05:00:00', 11.00, 'Completed'),
(9,  'ROUTE-WESTHILL-MORNING',   9,  8, 1, CURDATE(), '08:00:00', 25.00, 'Scheduled'),
(10, 'ROUTE-LAKESIDE-TOURISM',  10,  4, 2, CURDATE(), '16:00:00', 10.50, 'Scheduled'),
(11, 'ROUTE-AIRPORT-LOGISTICS', 11, 11, 4, CURDATE(), '07:30:00', 32.00, 'Scheduled'),
(12, 'ROUTE-METRO-JUNCTION',    12,  1, 5, CURDATE(), '10:00:00', 15.00, 'Completed'),
(13, 'ROUTE-TEXTILE-EVENING',   13,  6, 6, CURDATE(), '17:00:00', 17.50, 'Scheduled'),
(14, 'ROUTE-CYBERHILLS-NIGHT',  14,  2, 7, CURDATE(), '21:30:00', 20.00, 'Scheduled'),
(15, 'ROUTE-HERITAGE-MORNING',  15,  5, 1, CURDATE(), '06:30:00',  9.00, 'Completed');

-- -----------------------------------------------------------------------------
-- 10. RECYCLING_BATCH (20 Realistic Transformation Batches)
-- -----------------------------------------------------------------------------
INSERT INTO Recycling_Batch (BatchID, FacilityID, CategoryID, InputWeightKg, ProcessedWeightKg, OutputRecycledKg, ProcessingDate, PurityRate, BatchStatus) VALUES
(1,  1, 1, 15000.00, 14800.00, 12500.00, CURDATE() - INTERVAL 5 DAY, 96.50, 'Quality Passed'),
(2,  2, 2,  8500.00,  8200.00,  6900.00, CURDATE() - INTERVAL 4 DAY, 92.00, 'Quality Passed'),
(3,  3, 3, 11000.00, 10700.00,  9800.00, CURDATE() - INTERVAL 4 DAY, 95.00, 'Quality Passed'),
(4,  4, 4, 18000.00, 17800.00, 16900.00, CURDATE() - INTERVAL 3 DAY, 98.20, 'Quality Passed'),
(5,  5, 5,  6500.00,  6300.00,  5400.00, CURDATE() - INTERVAL 3 DAY, 89.50, 'Quality Passed'),
(6,  6, 6,  3200.00,  3000.00,  2100.00, CURDATE() - INTERVAL 2 DAY, 86.00, 'Quality Passed'),
(7,  1, 1, 14000.00, 13700.00, 11600.00, CURDATE() - INTERVAL 2 DAY, 94.80, 'Quality Passed'),
(8,  2, 2,  9200.00,  8900.00,  7400.00, CURDATE() - INTERVAL 1 DAY, 91.50, 'Quality Passed'),
(9,  3, 3, 12500.00, 12200.00, 11100.00, CURDATE() - INTERVAL 1 DAY, 96.00, 'Quality Passed'),
(10, 4, 4, 21000.00, 20600.00, 19600.00, CURDATE(),                  98.50, 'Processing'),
(11, 7, 7,  2500.00,  2450.00,  1200.00, CURDATE() - INTERVAL 1 DAY, 75.00, 'Quality Passed'),
(12, 8, 2, 16000.00, 15500.00, 13100.00, CURDATE(),                  93.20, 'Processing'),
(13, 9, 1,  8000.00,  7800.00,  6600.00, CURDATE() - INTERVAL 2 DAY, 95.50, 'Quality Passed'),
(14, 2, 2,  7500.00,  7100.00,  5800.00, CURDATE() - INTERVAL 6 DAY, 90.00, 'Quality Passed'),
(15, 3, 3,  9500.00,  9200.00,  8300.00, CURDATE() - INTERVAL 5 DAY, 94.00, 'Quality Passed'),
(16, 4, 4, 14500.00, 14200.00, 13500.00, CURDATE() - INTERVAL 7 DAY, 97.80, 'Quality Passed'),
(17, 5, 5,  5200.00,  5000.00,  4200.00, CURDATE() - INTERVAL 5 DAY, 88.00, 'Quality Passed'),
(18, 6, 6,  2800.00,  2600.00,  1800.00, CURDATE() - INTERVAL 4 DAY, 84.50, 'Quality Passed'),
(19, 8, 3, 13000.00, 12600.00, 11400.00, CURDATE() - INTERVAL 3 DAY, 95.80, 'Quality Passed'),
(20, 1, 1, 16500.00, 16100.00, 13700.00, CURDATE(),                  96.20, 'In Sorting');

-- -----------------------------------------------------------------------------
-- 11. COMPLAINT (20 Realistic Grievance Filings)
-- -----------------------------------------------------------------------------
INSERT INTO Complaint (ComplaintID, CitizenID, BinID, ComplaintType, Description, Status, LodgedAt, ResolvedAt, ResolutionRemarks) VALUES
(1,  1,  2,  'Overflowing Bin',  'Plastic waste spilling onto pedestrian pavement near Royal Residency.', 'Resolved',    NOW() - INTERVAL 48 HOUR, NOW() - INTERVAL 24 HOUR, 'Emergency compacting truck dispatched; emptied.'),
(2,  2,  6,  'Overflowing Bin',  'IT Park phase 1 bin full since weekend. Urgent collection requested.',  'Resolved',    NOW() - INTERVAL 36 HOUR, NOW() - INTERVAL 12 HOUR, 'Cleared by Route 2 morning shift.'),
(3,  3,  8,  'Damaged Bin',      'Lid hinge broken; stray animals accessing glass shards.',               'In Progress', NOW() - INTERVAL 30 HOUR, NULL,                      'Assigned to maintenance workshop crew.'),
(4,  4,  9,  'Foul Odour',       'Wet organic waste emitting severe stench in old bazaar lane.',          'Pending',     NOW() - INTERVAL 26 HOUR, NULL,                      NULL),
(5,  5,  14, 'Missed Collection','Scheduled Thursday pickup did not happen on Palm Avenue.',             'Resolved',    NOW() - INTERVAL 52 HOUR, NOW() - INTERVAL 40 HOUR, 'Driver re-routed and emptied.'),
(6,  6,  15, 'Overflowing Bin',  'Paper recycling bin overflowing outside university library.',           'In Progress', NOW() - INTERVAL 18 HOUR, NULL,                      'Added to afternoon route queue.'),
(7,  7,  17, 'Foul Odour',       'Medical waste container left unsealed near outpatient gate.',           'Resolved',    NOW() - INTERVAL 60 HOUR, NOW() - INTERVAL 46 HOUR, 'Specialized biohazard vehicle dispatched.'),
(8,  8,  19, 'Illegal Dumping',  'Commercial construction debris dumped beside green residential bin.',   'Pending',     NOW() - INTERVAL 12 HOUR, NULL,                      NULL),
(9,  9,  20, 'Overflowing Bin',  'Lakeview boulevard promenade bin packed with tourist food cartons.',    'In Progress', NOW() - INTERVAL 14 HOUR, NULL,                      'Driver alerted for immediate clearance.'),
(10, 10, 24, 'Damaged Bin',      'E-waste secure drop slot jammed shut.',                                  'Pending',     NOW() - INTERVAL 8 HOUR,  NULL,                      NULL),
(11, 1,  1,  'Foul Odour',       'Organic bin needs sanitization spray after clearance.',                 'Resolved',    NOW() - INTERVAL 90 HOUR, NOW() - INTERVAL 70 HOUR, 'Sanitized with sodium hypochlorite spray.'),
(12, 2,  4,  'Overflowing Bin',  'Vegetable waste pile spilling into road gutter.',                       'Resolved',    NOW() - INTERVAL 75 HOUR, NOW() - INTERVAL 50 HOUR, 'Compactor cleared area.'),
(13, 3,  7,  'Missed Collection','Morning van skipped 2nd cross bin.',                                   'Resolved',    NOW() - INTERVAL 65 HOUR, NOW() - INTERVAL 45 HOUR, 'Resolved in evening run.'),
(14, 4,  10, 'Damaged Bin',      'Wheels damaged on metal scrap receptacle.',                             'In Progress', NOW() - INTERVAL 22 HOUR, NULL,                      'Scheduled for wheel replacement.'),
(15, 5,  13, 'Foul Odour',       'Compost bin emitting smell in humid afternoon.',                        'Pending',     NOW() - INTERVAL 10 HOUR, NULL,                      NULL),
(16, 6,  16, 'Illegal Dumping',  'Discarded monitors placed on sidewalk next to e-waste bin.',            'Pending',     NOW() - INTERVAL 6 HOUR,  NULL,                      NULL),
(17, 7,  18, 'Missed Collection','Saturday cleaning missed.',                                            'Resolved',    NOW() - INTERVAL 110 HOUR,NOW() - INTERVAL 85 HOUR, 'Verified and completed.'),
(18, 8,  21, 'Damaged Bin',      'Dent on metal body preventing complete closure.',                       'Resolved',    NOW() - INTERVAL 95 HOUR, NOW() - INTERVAL 80 HOUR, 'Repaired on site.'),
(19, 9,  22, 'Overflowing Bin',  'Railway colony market bin overflow.',                                   'Pending',     NOW() - INTERVAL 4 HOUR,  NULL,                      NULL),
(20, 10, 25, 'Foul Odour',       'Food stalls dumping sauce runoff inside heritage zone.',                'Pending',     NOW() - INTERVAL 2 HOUR,  NULL,                      NULL);
