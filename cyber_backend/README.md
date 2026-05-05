# ⚙️ CyberShield Backend System

The **CyberShield Backend** is the core engine of the CyberShield AI Cybersecurity System.
It processes user inputs, runs machine learning models, performs threat analysis, and returns results to the frontend (Flutter app).

This backend integrates multiple cybersecurity modules into a unified system.

---

## 🧠 Core Responsibilities

* 🔍 Analyze files, emails, URLs, and USB activity
* 🤖 Run machine learning models for threat detection
* 📡 Provide REST APIs for frontend communication
* 🗄️ Store logs, results, and configurations
* ⚡ Deliver real-time cybersecurity insights

---

## 🏗️ Backend Architecture

```text id="arch1"
Flutter App → API Request → Backend Server → ML Models → Analysis → Response → App
```

### 🔹 Layers

1. **API Layer** → Handles requests (Flask / FastAPI)
2. **Processing Layer** → Data cleaning & feature extraction
3. **ML Layer** → Prediction models
4. **Storage Layer** → Logs, CSV, database

---

## 📦 Modules Overview

### 🦠 Malware Detection

* Static file analysis
* PE parsing & string extraction
* ML-based classification

---

### 📧 Email Phishing Detection

* NLP-based text analysis
* TF-IDF vectorization
* Phishing classification model
* Gmail integration (optional)

---

### 🌐 URL Safety Checker

* URL pattern analysis
* Blacklist detection
* API-based validation

---

### 🔌 USB Security Module

* Detect connected USB devices
* Monitor file activities
* Trigger alerts for suspicious behavior

---

### 🤖 Cybersecurity Chatbot

* AI-powered assistant
* Answers user queries
* Helps explain threats

---

## 📁 Project Structure

```bash id="v9d1rx"
cyber_backend/
│
├── CyberSecurity Chatbot/
├── malware/
├── email/
├── url/
├── usb/
└── README.md
```

---

## 🔗 API Endpoints

| Endpoint   | Method | Description                 |
| ---------- | ------ | --------------------------- |
| `/malware` | POST   | Scan file for malware       |
| `/email`   | POST   | Detect phishing email       |
| `/url`     | POST   | Check website safety        |
| `/usb`     | GET    | Monitor USB activity        |
| `/chatbot` | POST   | Ask cybersecurity questions |
| `/login`   | POST   | User login                  |
| `/signup`  | POST   | User registration           |

---

## 🔄 Request–Response Flow

```text id="flow1"
User → Flutter App → API Request → Backend → ML Processing → Result → App UI
```

---

## ⚙️ Setup & Installation

### 🔹 Step 1: Clone Repository



### 🔹 Step 2: Install Dependencies



### 🔹 Step 3: Run Backend Server

---

### 🔹 Step 4: Access API



## 🧠 Machine Learning Integration

Each module uses ML models trained on cybersecurity datasets.

### 🔹 Techniques Used

* TF-IDF (Email detection)
* Static analysis (Malware)
* Pattern matching (URL detection)

---

## 📊 Output Format

Example JSON response:

```json id="json1"
{
  "status": "Phishing",
  "confidence": 0.92
}
```

---

## 🔐 Security Practices

* ❌ No sensitive data stored in repo
* 🔒 Environment variables for secrets
* ⚠️ Input validation before processing
* 🛡️ API-based controlled access

---

## ⚠️ Limitations

* Accuracy depends on training data
* Limited real-time monitoring
* Needs continuous model updates

---

## 💡 Future Improvements

* 🔄 Real-time threat detection
* 🌐 Cloud deployment (AWS / Azure)
* 🧠 Deep learning models (BERT, LSTM)
* 📊 Dashboard analytics
* 🔐 Role-based authentication

---

