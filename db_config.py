import os
import mysql.connector

ENV = os.getenv("ENV", "server").lower()

if ENV == "server":
    DB_CONFIG = {
        'host': os.getenv('SERVER_DB_HOST', '123.19.254.158'),
        'user': os.getenv('SERVER_DB_USER', 'apebond'),
        'password': os.getenv('SERVER_DB_PASS', 'it.d@2025'),
        'database': os.getenv('SERVER_DB_NAME', 'apebond'),
        'port': int(os.getenv('SERVER_DB_PORT', 3307)),
        'connect_timeout': 10
    }
else:
    DB_CONFIG = {
        'host': 'localhost',
        'user': 'root',
        'password': '',
        'database': 'transaction_storage',
        'port': 3306,
        'connect_timeout': 10
    }

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)