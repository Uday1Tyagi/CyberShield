import mysql.connector

def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Uday@2005",
        database="cyber_threat_detection"
    )