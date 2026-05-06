# 🛡️ CyberGuard AI Backend

## 📌 Overview

CyberGuard AI Backend is a Flask-based cybersecurity chatbot API powered by the Groq LLM API.

The system is designed to answer cybersecurity-related questions such as:

* Phishing attacks
* Malware
* Network security
* Encryption
* Ethical hacking
* Data protection
* Cloud security
* AI-powered cyber threats

The backend supports:

* Multi-turn conversation memory
* Rate limiting
* Session management
* Health monitoring
* Security tips API
* Cybersecurity topic listing

---

# 🚀 Features

* 🔐 Cybersecurity-focused AI assistant
* 💬 Multi-session chat support
* ⚡ Fast responses using Groq API
* 🧠 Conversation memory
* 📊 API statistics & health monitoring
* 🛡️ Rate limiting for abuse prevention
* 🌐 REST API architecture
* ✅ JSON-based responses

---

# 🛠️ Technologies Used

* Python
* Flask
* Flask-CORS
* Groq API
* REST API
* JSON
* Logging System

---

# 📁 Project Structure

```bash id="hdb1hi"
project/
│── app.py                # Main Flask backend
│── requirements.txt      # Python dependencies
│── README.md             # Project documentation
```

---

# ⚙️ API Endpoints

## 1. Health Check

```http id="1ghp2u"
GET /api/health
```

Returns:

* Server status
* Active sessions
* Request statistics
* Uptime

---

## 2. Chat Endpoint

```http id="2l4ek4"
POST /api/chat
```

Request Example:

```json id="waj7wp"
{
  "message": "What is phishing?",
  "session_id": "user123"
}
```

Response Example:

```json id="ec79j0"
{
  "reply": "Phishing is a cyberattack...",
  "session_id": "user123"
}
```

---

## 3. Clear Chat History

```http id="fr26fj"
POST /api/chat/clear
```

Clears conversation history for a session.

---

## 4. Get Chat History

```http id="j6c5hc"
GET /api/chat/history
```

Returns previous conversation history.

---

## 5. Cybersecurity Topics

```http id="j0lgqy"
GET /api/topics
```

Returns all cybersecurity categories supported by the AI.

---

## 6. Quick Security Tips

```http id="mt7k6v"
GET /api/quicktips
```

Returns cybersecurity safety tips.

---

# 🔒 Security Features

## ✅ Rate Limiting

The backend allows:

```bash id="6fkhf9"
15 requests per minute per IP
```

This prevents spam and abuse.

---

## ✅ Session Memory

The system stores:

```bash id="j96ynw"
Last 20 conversation turns
```

This helps maintain conversation context.

---

## ✅ Logging System

The backend logs:

* Requests
* Errors
* API activity
* Session activity

---

# 🧠 AI Model

The backend uses:

```bash id="w2t1bi"
llama-3.3-70b-versatile
```

via the Groq API.

---

# 🚀 Installation Guide

## Step 1: Clone Repository

```bash id="p0gnn9"
git clone <repository-url>
cd project-folder
```

---

## Step 2: Install Dependencies

```bash id="zxv5i4"
pip install -r requirements.txt
```

---

## Step 3: Add Groq API Key

Inside `app.py`:

```python id="sjxrw2"
GROQ_API_KEY = "your_api_key_here"
```

---

## Step 4: Run Server

```bash id="b6i53u"
python app.py
```

Server runs at:

```bash id="5tx9mg"
http://localhost:5000
```

---

# 🔄 How It Works

1. User sends message to `/api/chat`
2. Flask backend receives request
3. Session history is loaded
4. System prompt is added
5. Request is sent to Groq API
6. AI generates cybersecurity response
7. Response is returned in JSON format
8. Conversation is stored in memory

---

# 📊 Example Use Cases

* Cybersecurity learning platform
* Security awareness chatbot
* Educational AI assistant
* Threat explanation system
* Phishing awareness tool

---

# ⚠️ Important Notes

* Requires internet connection
* Groq API key is mandatory
* Only cybersecurity questions are supported

---

# 🔮 Future Improvements

* Database integration
* User authentication
* AI threat detection
* Voice assistant integration
* Web dashboard
* Chat history database

---

# 👨‍💻 Developer

Developed as part of the CyberShield Cybersecurity Project.
