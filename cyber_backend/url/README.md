# 🌐 URL Security Module (CyberShield)

## 📌 Overview

This module of CyberShield is designed to detect whether a URL is **safe or malicious** using a Chrome Extension and a Flask backend API.

It helps users avoid phishing websites and unsafe links in real time.

---

## 📁 Folder Structure

```bash
url/
│── chrome-extension-files/   # Chrome Extension frontend
│── flask-api/                # Backend server for URL checking
│── scan_cache.json           # Stores previously scanned URL results
```

---

## 🔧 Components Explanation

### 1. Chrome Extension (`chrome-extension-files`)

This is the frontend part that interacts with the user.

* `manifest.json` → Configuration of extension
* `background.js` → Runs in background and handles requests
* `content.js` → Reads current webpage URL
* `popup.html` → UI of extension
* `popup.js` → Handles button clicks & display results
* `style.css` → Styling
* `icon.png` → Extension icon

👉 Function:

* Captures the current URL
* Sends it to backend
* Displays result (Safe / Malicious)

---

### 2. Flask API (`flask-api`)

This is the backend server responsible for analyzing URLs.

👉 Function:

* Receives URL from extension
* Checks URL using logic / database / API
* Returns result (Safe or Malicious)

Run using:

```bash
python app.py
```

---

### 3. scan_cache.json

This file is used to **store previously scanned URLs**.

👉 Purpose:

* Improves performance
* Avoids repeated scanning
* Acts like a local database

Example:

```json
{
  "google.com": "safe",
  "malicious-site.com": "danger"
}
```

---

## ⚙️ How It Works

1. User opens a website
2. Extension reads the URL
3. URL is sent to Flask API
4. API checks if URL is safe
5. Result is stored in `scan_cache.json`
6. Extension shows result to user

---

## 🚀 Setup Instructions

### Step 1: Run Backend

```bash
cd flask-api
pip install -r requirements.txt
python app.py
```

---

### Step 2: Load Chrome Extension

1. Open Chrome
2. Go to `chrome://extensions/`
3. Enable **Developer Mode**
4. Click **Load unpacked**
5. Select:

```bash
chrome-extension-files/
```

---

## 🧪 Usage

* Open any website
* Click extension icon
* View URL safety status

---

## ⚠️ Important Notes

* Backend must be running
* Do not delete `scan_cache.json` (used for caching)

---

## 🔮 Future Improvements

* AI-based phishing detection
* Cloud database integration
* Real-time blacklist updates

---
