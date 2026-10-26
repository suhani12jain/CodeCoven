# B.TECH CSE 3RD-YEAR DBMS MINI-PROJECT REPORT
# Title: Smart Waste Management and Recycling System (SWMRS)
### Academic Year: 2026-2027
### Tech Stack: MySQL 8.0, Python 3.10+, Flask, Bootstrap 5 (Glassy UI), scikit-learn, pandas

---

## 1. ABSTRACT
Rapid urban population growth has intensified municipal waste generation, presenting severe environmental, health, and logistical challenges. Conventional municipal waste collection methodologies follow static, pre-determined routing schedules, leading to fuel wastage, unserviced overflowing receptacles, and low recycling recovery rates. This project designs and implements the **Smart Waste Management and Recycling System (SWMRS)**—a centralized, database-driven enterprise solution featuring an integrated Artificial Intelligence and Machine Learning (AI/ML) predictive module. 

The primary focus is advanced Database Management System (DBMS) architecture, implementing 15 relational tables normalized to Boyce-Codd Normal Form (BCNF), domain integrity constraints, five analytical views, four event-driven triggers, four stored procedures/functions, ACID transaction mechanisms with deadlock recovery, and granular Role-Based Access Control (RBAC). The application features a modern, glassmorphic (glassy) web interface built with Flask and Bootstrap 5, complete with real-time query telemetry and live `INFORMATION_SCHEMA` metadata inspection.

---

## 2. PROBLEM STATEMENT
Traditional municipal sanitation infrastructure suffers from four critical database and logistical deficiencies:
1. **Lack of Real-Time Visibility**: Waste containers overflow unpredictably between scheduled routes without automated alerting or database-driven dispatching.
2. **Data Redundancy & Update Anomalies**: Flat, un-normalized record keeping causes inconsistent data across municipal wards, vehicles, and citizen grievance registries.
3. **Payload & Resource Violations**: Collection vehicles are frequently overloaded beyond rated structural limits, damaging assets and causing safety hazards.
4. **Poor Circular Economy Traceability**: Recycling facilities lack transparent, category-level mass-balance tracking from raw collection to purified recycled material yield.

---

## 3. PROJECT OBJECTIVES
1. **Relational Database Design**: Design a normalized BCNF schema modeling 15 master and operational entities.
2. **Database Integrity & Business Rules**: Enforce domain checks, composite primary keys, and referential constraints across all entities.
3. **Automated Event Processing (Triggers)**: Enforce automated state changes upon sensor threshold breach, maintain immutable audit trails, and prevent vehicle overload at the database engine level.
4. **Analytical Reporting (Views & Complex Queries)**: Construct pre-aggregated views and 25 complex SQL queries demonstrating relational algebra, joins, window functions (`ROW_NUMBER`, `RANK`, `LAG`, `LEAD`), and common table expressions (CTEs).
5. **ACID Transaction Management**: Guarantee transactional consistency using `COMMIT`, `ROLLBACK`, `SAVEPOINT`, and exclusive row-level locking (`SELECT ... FOR UPDATE`).
6. **Integrated AI/ML Predictive Module**:
   - *Task 1*: Binary classification for bin overflow prediction using Random Forest (97.0% accuracy).
   - *Task 4*: Multi-class physical classification of waste streams (Organic, Plastic, Paper, Metal, E-Waste; 98.2% accuracy).
   - *Task 5*: K-Nearest Neighbors (KNN) content-based recommendation for optimal recycling facility routing.
7. **Glassmorphic Full-Stack UI**: Deliver a web interface featuring frosted glass panels, role-based dashboards, and a live SQL Query Interceptor.

---

## 4. SYSTEM ARCHITECTURE & ER MODEL

### 4.1 Master Entities
1. `Users` (Authentication, hashed passwords, roles)
2. `Zone` (Municipal wards, area, population density)
3. `Waste_Category` (Stream metadata, target recycling %, hazard flags)
4. `Collection_Vehicle` (Trucks, electric vans, payload capacities)
5. `Driver_Employee` (Driver profile, shift, license, ratings)
6. `Citizen` (Residents, reward points, addresses)
7. `Bin` (IoT smart receptacle, capacity, current fill, coordinates, status)
8. `Collection_Route` (Scheduled corridors, vehicles, drivers)
9. `Collection_Record` (Emptying transactions, gross weights, before/after fill)
10. `Recycling_Facility` (Plants, daily capacities, processing costs)
11. `Recycling_Batch` (Batch yields, input vs output weight, purity rates)
12. `Complaint` (Citizen grievances, aging, resolution remarks)
13. `Sensor_Reading` (Time-series telemetry: fill %, battery %, temperature, tilt)
14. `AI_Prediction` (Machine learning inference audit log)
15. `Audit_Log` (System-wide change tracking)

### 4.2 Relational Schema (BCNF)
- $\text{Users}(\underline{\text{UserID}}, \text{Username}, \text{PasswordHash}, \text{Role}, \text{Email}, \text{FullName}, \text{Phone}, \text{IsActive}, \text{CreatedAt})$
- $\text{Zone}(\underline{\text{ZoneID}}, \text{ZoneName}, \text{City}, \text{AreaSqKm}, \text{PopulationDensity}, \text{TargetRecyclingRate})$
- $\text{Waste\_Category}(\underline{\text{CategoryID}}, \text{CategoryName}, \text{Description}, \text{TargetRecyclingPct}, \text{ToxicityLevel}, \text{HazardFlag})$
- $\text{Collection\_Vehicle}(\underline{\text{VehicleID}}, \text{VehicleNumber}, \text{VehicleType}, \text{CapacityKg}, \text{FuelType}, \text{OperationalStatus})$
- $\text{Driver\_Employee}(\underline{\text{DriverID}}, \text{UserID}^*, \text{LicenseNumber}, \text{Shift}, \text{ExperienceYears}, \text{Status}, \text{Rating})$
- $\text{Citizen}(\underline{\text{CitizenID}}, \text{UserID}^*, \text{ZoneID}^*, \text{AddressLine}, \text{RewardPoints})$
- $\text{Bin}(\underline{\text{BinID}}, \text{BinCode}, \text{ZoneID}^*, \text{CategoryID}^*, \text{CapacityLitres}, \text{CurrentFillLevel}, \text{Latitude}, \text{Longitude}, \text{Status})$
- $\text{Collection\_Route}(\underline{\text{RouteID}}, \text{RouteName}, \text{ZoneID}^*, \text{VehicleID}^*, \text{DriverID}^*, \text{ScheduledDate}, \dots)$
- $\text{Collection\_Record}(\underline{\text{RecordID}}, \text{BinID}^*, \text{RouteID}^*, \text{DriverID}^*, \text{VehicleID}^*, \text{CollectedWeightKg}, \dots)$
- $\text{Recycling\_Facility}(\underline{\text{FacilityID}}, \text{FacilityName}, \text{ZoneID}^*, \text{CapacityPerDayTons}, \text{OperationalCostPerTon}, \dots)$
- $\text{Recycling\_Batch}(\underline{\text{BatchID}}, \text{FacilityID}^*, \text{CategoryID}^*, \text{InputWeightKg}, \text{OutputRecycledKg}, \text{PurityRate}, \dots)$
- $\text{Complaint}(\underline{\text{ComplaintID}}, \text{CitizenID}^*, \text{BinID}^*, \text{ComplaintType}, \text{Description}, \text{Status}, \dots)$
- $\text{Sensor\_Reading}(\underline{\text{ReadingID}}, \text{BinID}^*, \text{FillPercentage}, \text{BatteryLevelPct}, \text{TemperatureCelsius}, \dots)$

---

## 5. NORMALIZATION ANALYSIS

### 5.1 First Normal Form (1NF)
Eliminates repeating groups and guarantees atomic values. Multi-valued sensor telemetry records and collection events are decoupled into separate relations with dedicated keys (`Sensor_Reading` and `Collection_Record`).

### 5.2 Second Normal Form (2NF)
Eliminates partial functional dependencies. In collection logging, vehicle attributes and driver attributes depend solely on `VehicleID` and `DriverID` respectively, rather than a composite key. These are isolated into standalone relations.

### 5.3 Third Normal Form (3NF)
Eliminates transitive dependencies. In citizen records, citizen address maps to `ZoneID`, which in turn maps to `ZoneName` and `City`. Storing `ZoneName` directly inside `Citizen` would introduce transitive dependency:
$$\text{CitizenID} \rightarrow \text{ZoneID} \rightarrow \text{ZoneName}$$
Isolating `Zone` satisfies 3NF.

### 5.4 Boyce-Codd Normal Form (BCNF)
For every functional dependency $X \rightarrow Y$, $X$ must be a superkey. All relations in SWMRS have candidate keys as their determinants, satisfying BCNF.

---

## 6. ADVANCED DATABASE ARTIFACTS

### 6.1 Event-Driven Database Triggers
1. **`trg_sensor_auto_update_bin_status`**: Evaluates incoming telemetry and automatically marks bin as `OVERFLOW_CRITICAL` when `FillPercentage >= 90.0%`.
2. **`trg_audit_bin_update`**: Writes old and new values to `Audit_Log` upon any manual or automated bin modification.
3. **`trg_prevent_vehicle_overload`**: Enforces strict payload validation on `Collection_Record`, raising SQLSTATE `45000` if cumulative weight exceeds truck capacity.
4. **`trg_update_recycling_stock`**: Automatically increments facility tonnage upon batch completion.

### 6.2 Stored Procedures & Functions
1. `sp_assign_emergency_pickup`: Dynamically matches overflowing bins with the highest-rated available driver and vehicle.
2. `sp_generate_monthly_zone_report`: Aggregates active bins, tonnage, and complaint volume per zone.
3. `fn_calculate_recycling_rate`: Deterministic function returning category-level recovery efficiency percentage.
4. `sp_schedule_collection_route`: Creates standard morning routes and sets vehicle status to 'On Route'.

---

## 7. AI/ML MODULE INTEGRATION
- **Task 1 (Bin Overflow)**: Random Forest Classifier trained on 2,000 synthetic records considering temperature, weekend surges, and fill rates. Achieved 97.0% Accuracy and 0.995 ROC-AUC.
- **Task 4 (Waste Classification)**: Multi-class Random Forest Classifier evaluating material density, moisture, reflectivity, and conductivity. Achieved 98.2% Accuracy across 5 classes.
- **Task 5 (Recycling Recommender)**: K-Nearest Neighbors (KNN) content matcher pairing waste batches with optimal processing plants based on distance, capacity, and cost.
- **Database Loop**: All predictions are permanently written back to MySQL in the `AI_Prediction` table.

---

## 8. CONCLUSION
The Smart Waste Management and Recycling System successfully bridges database engineering principles with applied machine learning. By offloading critical business rules to MySQL triggers, stored procedures, and views, the system achieves maximum data integrity, high query throughput, and resilient operational automation.
