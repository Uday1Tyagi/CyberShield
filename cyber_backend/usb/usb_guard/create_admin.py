import bcrypt
from database import connect_db

password = "admin123"
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

conn = connect_db()
cursor = conn.cursor()

# Check if admin already exists
cursor.execute("SELECT * FROM admin_users WHERE username=%s", ("admin",))
existing = cursor.fetchone()

if existing:
    print("Admin already exists.")
else:
    cursor.execute(
        "INSERT INTO admin_users (username, password_hash) VALUES (%s, %s)",
        ("admin", hashed.decode())
    )
    conn.commit()
    print("Admin created successfully.")

conn.close()