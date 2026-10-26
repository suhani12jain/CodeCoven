import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'swmrs-btech-cse-secret-key-2026')
    
    # MySQL Database Configuration
    MYSQL_HOST = os.environ.get('MYSQL_HOST', 'localhost')
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT', 3306))
    MYSQL_USER = os.environ.get('MYSQL_USER', 'root')
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', 'root')  # change if needed
    MYSQL_DB = os.environ.get('MYSQL_DB', 'waste_mgmt_db')
    
    # ML Models directory
    BASE_DIR = os.path.abspath(os.path.dirname(__file__))
    ML_MODELS_DIR = os.path.join(BASE_DIR, 'ml', 'models')
    
    # Connection Pool Settings
    MYSQL_POOL_NAME = 'swmrs_pool'
    MYSQL_POOL_SIZE = 10
