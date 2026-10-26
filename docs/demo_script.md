# EXAMINER DEMO SCRIPT & PRESENTATION GUIDE
## Smart Waste Management and Recycling System (SWMRS)

Follow this structured 8-step sequence during your project demonstration to showcase the DBMS depth, Front End, and AI/ML capabilities.

---

### Step 1: Login & Role-Based Access Control (RBAC)
- **Action**: Open `http://127.0.0.1:5000/login`.
- **Examiner Highlight**: Click on the quick-fill button for **Admin**, then **Driver**, then **Citizen**. Show that different roles have different permissions (e.g. Citizen cannot delete bins or assign routes).
- **Point Out**: Passwords are securely hashed with PBKDF2/SHA-256.

---

### Step 2: The Glassy Executive Dashboard & Real-Time KPI Cards
- **Action**: Log in as Admin and land on the Dashboard (`/`).
- **Examiner Highlight**: 
  - Point out the 4 KPI metric cards: Total Bins, Gross Waste Collected, Recycling Recovery Rate, Active Grievances.
  - Show the **Critical Overflow Alerts** table (populated via `vw_overflowing_bins`).
  - Click **"⚡ Dispatch Pickup"** on an overflowing bin. Explain that this executes the MySQL Stored Procedure `sp_assign_emergency_pickup`, which pairs the bin with an available vehicle and driver.

---

### Step 3: Reveal the "Live SQL Query Interceptor" Drawer
- **Action**: Click the floating green **"⚡ SQL Query Log"** button at the bottom-right of the screen.
- **Examiner Highlight**:
  - Show the examiner the exact parameterized SQL query that generated the dashboard, along with its execution time in milliseconds.
  - Explain: *"Every single user interaction flows from Front End -> Parameterized Query -> MySQL Engine -> Result Set."*

---

### Step 4: Database Views & Analytical Visualizations
- **Action**: Navigate to **"Reports & Views"** (`/reports`).
- **Examiner Highlight**:
  - Click through the 5 View tabs:
    1. `vw_zone_waste_summary`
    2. `vw_recycling_rate_by_category`
    3. `vw_overflowing_bins`
    4. `vw_driver_performance`
    5. `vw_pending_complaints`
  - Explain: *"Views encapsulate multi-table join complexity and protect base table structures while exposing clean analytical abstractions."*

---

### Step 5: Database Triggers in Action (Overload & Audit)
- **Action**: Go to **"Smart Bins"** (`/bins`), click **Edit** on any bin, change the fill level from 45% to 92%, and save.
- **Examiner Highlight**:
  - Explain: *"Trigger `trg_audit_bin_update` automatically caught this change and recorded an immutable audit trail in the `Audit_Log` table."*
- **Action 2**: Go to **"Collections"** (`/collections`) and try logging a collection with a weight exceeding the vehicle capacity (e.g., 9,999 kg on a mini tipper).
- **Examiner Highlight**:
  - The database raises SQLSTATE `45000` from trigger `trg_prevent_vehicle_overload` and aborts the insert.

---

### Step 6: Interactive SQL Console & Academic Query Presets
- **Action**: Navigate to **"SQL Console"** (`/sql-console`).
- **Examiner Highlight**:
  - Click the preset buttons:
    - **Q1**: 3-Table Inner Join
    - **Q8**: Scalar Subquery
    - **Q11**: Correlated Subquery
    - **Q15**: Multi-Column GROUP BY with ROLLUP
    - **Q20**: Window Function `ROW_NUMBER()`
    - **Q25**: Complex CTE
  - Execute the query and show the execution time and tabular result grid.

---

### Step 7: Live INFORMATION_SCHEMA & Vector ER Diagram
- **Action**: Navigate to **"ER & Schema"** (`/schema-view`).
- **Examiner Highlight**:
  - Show the live vector Mermaid ER diagram rendering all 15 entities and their cardinalities.
  - Scroll down to show table schemas being read directly from MySQL `INFORMATION_SCHEMA.COLUMNS`.

---

### Step 8: Integrated AI/ML Predictive Module (Tasks 1, 4, 5)
- **Action**: Navigate to **"AI Insights"** (`/ai-insights`).
- **Examiner Highlight**:
  - **Task 1 (Bin Overflow)**: Adjust sliders (current fill, weekend flag, festival index) and click *"Run Inference"*. Show the predicted probability from the Random Forest model. Click *"💾 Write Prediction to MySQL"* to demonstrate model-to-database writeback.
  - **Task 4 (Waste Classification)**: Enter physical features (density, moisture, reflectivity) and classify into Organic, Plastic, Paper, Metal, or E-Waste.
  - **Task 5 (Recycling Recommender)**: Select category and batch tonnage; show the Top-3 nearest capacity-ready recycling plants ranked by KNN Euclidean scoring.
