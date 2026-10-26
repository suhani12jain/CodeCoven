# Smart Waste Management and Recycling System (SWMRS)
### B.Tech CSE 3rd-Year DBMS Mini-Project with Integrated AI/ML Module

A complete, enterprise-grade municipal sanitation and circular economy management system built with MySQL 8.0, Python Flask, modern Glassmorphic (Glassy) UI theme, and integrated scikit-learn predictive models.

---

## 🚀 Quick Start Instructions (Windows)

### 1. Database Setup (MySQL 8.0)
1. Open **MySQL Workbench** or MySQL CLI.
2. Run the DDL script to create the schema, tables, views, triggers, and stored procedures:
   ```sql
   SOURCE database/schema.sql;
   ```
3. Load the master seed data:
   ```sql
   SOURCE database/data.sql;
   ```
4. Load the generated 1,300+ sensor telemetry rows and 540+ collection transactions:
   ```sql
   SOURCE database/bulk_data.sql;
   ```

### 2. Python Environment Setup
1. Open PowerShell or Command Prompt in the project folder:
   ```cmd
   cd C:\Users\suhan\.gemini\antigravity\scratch\waste_management_system
   ```
2. Double-click `setup.bat` OR run:
   ```cmd
   pip install -r requirements.txt
   python ml\train_models.py
   ```

### 3. Launch Application
Double-click `run.bat` OR run:
```cmd
python app.py
```
Open your browser and navigate to: **http://127.0.0.1:5000**

---

## 🔑 Login Credentials (RBAC)
- **Admin**: `admin` / `password123`
- **Supervisor**: `super_rahul` / `password123`
- **Driver**: `driver_amit` / `password123`
- **Citizen**: `citizen_anita` / `password123`
*(Quick-fill 1-click test buttons are available directly on the login page!)*

---

## 📂 Project Architecture
```
waste_management_system/
├── app.py                     # Flask web app & query interceptor
├── config.py                  # MySQL & app configuration
├── requirements.txt           # Dependencies
├── setup.bat / run.bat        # Windows automation scripts
├── database/
│   ├── schema.sql             # 15 Tables, 5 Views, 4 Triggers, 4 Stored Procedures
│   ├── data.sql               # Master tables realistic seed data
│   ├── seed_bulk_data.py      # Telemetry & collection transaction generator
│   ├── bulk_data.sql          # 1,363 Sensor Readings & 540 Collections
│   ├── queries.sql            # 25 Advanced academic SQL queries
│   └── concurrency_demo.py    # ACID transactions & deadlock demo script
├── ml/
│   ├── generate_ml_dataset.py # Synthetic dataset generator (weather/festivals)
│   ├── train_models.py        # Pipeline training models 1, 4, 5
│   ├── data/                  # CSV datasets
│   └── models/                # Saved models (.joblib)
├── static/
│   ├── css/glassy_theme.css   # Custom Glassmorphism UI styling
│   └── js/                    # Charts.js & interaction helpers
├── templates/                 # Glassy HTML templates
│   ├── base.html              # Layout with live SQL query drawer
│   ├── index.html             # Executive Dashboard & KPI cards
│   ├── login.html             # Auth with quick test buttons
│   ├── schema_view.html       # ER diagram & live INFORMATION_SCHEMA
│   ├── reports.html           # 5 Views tabs & charts
│   ├── sql_console.html       # Interactive SQL sandbox
│   ├── ai_insights.html       # Models 1, 4, 5 testing forms
│   └── crud/                  # Bins, Collections, Complaints
└── docs/
    ├── report_documentation.md# Academic Mini-Project Report
    ├── demo_script.md         # Examiner presentation guide
    └── viva_questions.md      # 15 Viva Q&As with model answers
```
