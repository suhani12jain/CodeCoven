@echo off
echo ===============================================================================
echo SMART WASTE MANAGEMENT AND RECYCLING SYSTEM (SWMRS) - AUTOMATED SETUP
echo ===============================================================================

echo [1/4] Checking Python version...
python --version
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH! Please install Python 3.10+.
    pause
    exit /b 1
)

echo [2/4] Installing Required Python Dependencies...
pip install -r requirements.txt

echo [3/4] Generating Synthetic Bulk Data for Sensor Readings and Collections...
python database\seed_bulk_data.py

echo [4/4] Training AI/ML Models (Tasks 1, 4, 5)...
python ml\train_models.py

echo ===============================================================================
echo [SUCCESS] SWMRS setup is complete! 
echo Run 'run.bat' to launch the web application.
echo ===============================================================================
pause
