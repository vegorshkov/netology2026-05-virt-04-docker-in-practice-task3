import os
import mysql.connector

print("Testing MySQL connection...")
print(f"DB_HOST: {os.environ.get('DB_HOST')}")
print(f"DB_USER: {os.environ.get('DB_USER')}")

try:
    conn = mysql.connector.connect(
        host=os.environ.get('DB_HOST'),
        user=os.environ.get('DB_USER'),
        password=os.environ.get('DB_PASSWORD'),
        database=os.environ.get('DB_NAME'),
        port=3306
    )
    print("Connection successful!")
    
    cursor = conn.cursor()
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()
    print(f"Tables in database: {tables}")
    
    conn.close()
except Exception as e:
    print(f"Connection failed: {e}")
