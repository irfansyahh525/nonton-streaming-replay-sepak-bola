import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # MySQL Configuration
    MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')
    MYSQL_USER = os.getenv('MYSQL_USER', 'root')
    MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
    MYSQL_DB = os.getenv('MYSQL_DB', 'streaming_bola')
    
    # App Configuration
    SECRET_KEY = os.getenv('SECRET_KEY', 'streaming-bola-secret-key-2024')
    DEBUG = os.getenv('DEBUG', True)