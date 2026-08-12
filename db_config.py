import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv()

def get_connection():
    env = os.getenv('ENV', 'local')

    if env == 'server':
        config = {
            'host': os.getenv('SERVER_DB_HOST'),
            'user': os.getenv('SERVER_DB_USER'),
            'password': os.getenv('SERVER_DB_PASS'),
            'database': os.getenv('SERVER_DB_NAME'),
            'port': int(os.getenv('SERVER_DB_PORT', 3306)),
            'charset': 'utf8mb4',
            'use_unicode': True,
            'collation': 'utf8mb4_unicode_ci',
            'connect_timeout': 30,
            'autocommit': True,
        }
    else:
        config = {
            'host': os.getenv('LOCAL_DB_HOST', 'localhost'),
            'user': os.getenv('LOCAL_DB_USER', 'root'),
            'password': os.getenv('LOCAL_DB_PASS', ''),
            'database': os.getenv('LOCAL_DB_NAME', 'transaction_storage'),
            'port': int(os.getenv('LOCAL_DB_PORT', 3306)),
            'charset': 'utf8mb4',
            'use_unicode': True,
            'collation': 'utf8mb4_unicode_ci',
            'connect_timeout': 30,
            'autocommit': True,
        }

    return mysql.connector.connect(**config)