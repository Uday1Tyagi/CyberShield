🔐 SecureVault — USB-Based File Protection System

SecureVault is a Windows-based cybersecurity system that protects sensitive files by monitoring USB connections and enforcing authentication before granting access. It combines real-time device detection, secure password verification, and system-level file protection.

---

🚀 Key Highlights

- 🔌 Real-time USB Monitoring using WMI
- 🔐 Secure Authentication with bcrypt password hashing
- 🚫 Unauthorized Access Prevention using Windows ACL ("icacls")
- ⛔ Brute-force Protection (3 failed attempts → temporary lockout)
- ⏳ Session Management with auto-expiry (10 minutes)
- 📊 Audit Logging stored in MySQL
- 🌐 REST APIs built with Flask

---

🧠 How It Works

1. USB device is inserted
2. System detects the device instantly (WMI listener)
3. User is prompted for password authentication
4. If verified:
   - Access to "C:\SecureVault" is granted
5. If failed:
   - Access is denied and attempt is logged
6. Multiple failures trigger temporary lockout

---

🛠 Tech Stack

- Language: Python 3.10
- Backend: Flask
- Database: MySQL
- Security: bcrypt, Windows ACL ("icacls")
- System Integration: WMI (Windows Management Instrumentation)

---

📁 Project Structure

cyber_backend/
├── app.py                  # Main API (USB log receiver)
└── usb_guard/
    ├── app.py              # Authentication & access control API
    ├── config.py           # Configuration settings
    ├── database.py         # MySQL connection
    ├── security_core.py    # Core security logic
    ├── usb_listener.py     # USB detection (WMI)
    ├── create_admin.py     # Admin setup script
    └── requirements.txt    # Dependencies

---

⚙️ Setup Guide

1. Clone Repository

git clone https://github.com/YOUR_USERNAME/cyber_backend.git
cd cyber_backend

2. Create Virtual Environment

python -m venv venv
venv\Scripts\activate
pip install -r cyber_backend/usb_guard/requirements.txt

3. Configure Environment Variables

Create a ".env" file:

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=cyber_threat_detection

---

4. Setup Database

mysql -u root -p < database_schema.sql

---

5. Create Admin User

cd cyber_backend/usb_guard
python create_admin.py

---

6. Run the System

Run in 3 separate terminals:

# Main Backend
python cyber_backend/app.py

# Security Module
python cyber_backend/usb_guard/app.py

# USB Listener (Run as Administrator)
python cyber_backend/usb_guard/usb_listener.py

---

🔒 Security Features

- Passwords stored using bcrypt hashing
- Protection against SQL Injection (parameterized queries)
- Sensitive data stored via environment variables
- System-level access control using Windows ACL
- Activity logging for monitoring and analysis

---

🎯 Use Cases

- Personal file protection
- Cybersecurity learning project
- USB-based authentication systems
- Secure workstation environments

---

📌 Future Improvements

- GUI interface for easier interaction
- Multi-user role-based access
- Cross-platform support (Linux/Mac)
- AI-based anomaly detection

---

👩‍💻 Author

Prachi Singh
B.Tech AIML Student | AI/ML Engineer

---

⚠️ Note

This project is developed for educational and demonstration purposes and currently supports Windows OS only.
