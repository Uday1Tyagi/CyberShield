# 📱 CyberShield Mobile App (Flutter)

CyberShield Mobile App is the **frontend interface** of the CyberShield AI Cybersecurity System.
It allows users to interact with all cybersecurity modules like malware detection, phishing detection, URL safety, and USB security through a clean and user-friendly interface.

---

## 🚀 Features

* 🔐 User Authentication (Login / Signup)
* 🤖 AI Chatbot Assistant
* 🦠 Malware Detection Interface
* 📧 Email Phishing Detection
* 🌐 URL Safety Checker
* 🔌 USB Monitoring Integration
* 📡 Real-time API communication with backend
* 🎨 Modern UI with responsive design

---

## 🏗️ Project Structure

```bash id="4q6xtu"
cyber_app_new/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── chatbot_screen.dart
│   │   ├── malware_screen.dart
│   │   ├── email_screen.dart
│   │   ├── url_screen.dart
│   │   └── usb_screen.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   └── auth_service.dart
│   │
│   └── widgets/
│
├── assets/
├── android/
└── README.md
```

---

## 🔐 Authentication System

### 🔹 Login

* Users can log in using email & password
* Validates credentials via backend API
* Secure session handling

### 🔹 Signup

* New users can create an account
* Stores user data securely
* Prevents duplicate accounts

---

## 🔗 Backend Integration

The app communicates with the **CyberShield backend APIs**.

### 🔹 API Connection

* Uses HTTP requests to connect with backend
* JSON-based request/response system
* Handles real-time cybersecurity analysis

---

### 🔹 Example API Flow

```text id="y6f3ok"
User Input → Flutter App → API Call → Backend Processing → Response → UI Display
```

---

### 🔹 API Endpoints Used

| Module  | Endpoint            | Description         |
| ------- | ------------------- | ------------------- |
| Malware | `/malware`          | Scan files          |
| Email   | `/email`            | Detect phishing     |
| URL     | `/url`              | Check website       |
| USB     | `/usb`              | Monitor devices     |
| Auth    | `/login`, `/signup` | User authentication |

---

## 🦠 Malware Detection (Frontend)

* Upload file or provide input
* Sends request to backend
* Displays result: Safe / Malicious

---

## 📧 Email Detection

* User enters email text
* App sends data to backend
* Displays phishing result

---

## 🌐 URL Checker

* User enters website link
* Backend analyzes URL
* Result displayed instantly

---

## 🔌 USB Module

* Shows connected USB status
* Alerts for suspicious activity

---

## 🤖 Chatbot Integration

* AI-powered chatbot
* Helps users understand threats
* Answers cybersecurity queries

---

## ▶️ How to Run

### 🔹 Install Flutter dependencies

```bash id="4p9qhb"
flutter pub get
```

### 🔹 Run app

```bash id="sk6bht"
flutter run
```

---

## ⚙️ Requirements

* Flutter SDK
* Android Studio / VS Code
* Connected device or emulator
* Backend server running

---

## 🔧 Configuration

Make sure backend is running at:

```text id="ksc3ap"
http://127.0.0.1:8000
```

Update API base URL in:

```bash id="yrc5h8"
lib/services/api_service.dart
```

---

## 🎨 UI Highlights

* Clean and modern design
* Smooth navigation
* Mobile-first approach
* Interactive modules

---

## ⚠️ Limitations

* Requires backend to be active
* Internet connection needed
* Some modules depend on system-level access

---

## 💡 Future Improvements

* 🔔 Push notifications for threats
* 🌐 Cloud deployment
* 🧠 Advanced AI chatbot
* 📊 Dashboard analytics
* 🔐 Biometric authentication

---

## 👨‍💻 Author

Uday Tyagi
CyberShield Project
