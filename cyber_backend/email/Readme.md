# 📧 Email Phishing Detection Module

This module is part of the **CyberShield AI Cybersecurity System** and is designed to detect **phishing emails** using machine learning and text analysis techniques.

It can analyze both:

* 📥 Emails fetched directly from Gmail

---

## 🚀 Features

* 🔍 Detects phishing emails using ML model
* 🧠 Uses **TF-IDF Vectorization** for text processing
* 📊 Trained classification model for prediction
* ⚡ Fast API-based detection
* 📬 Gmail integration for real-time email scanning
* 🗂️ Supports CSV dataset for training & testing
* 🔐 Helps protect users from email-based attacks

---

## 🏗️ Project Structure

```bash id="x6v7qk"
email/
│
├── app.py                      # Main application
├── email_checker.py            # Detection logic
├── train_model.py              # Model training
├── phishing_model.pkl          # ML model
├── tfidf_vectorizer.pkl        # Vectorizer
├── Phishing_validation_emails.csv
├── Phishing_validation_emails_features.csv
├── blocklist.txt
├── config.json
├── email_status.csv
└── README.md
```

---

## ⚙️ How It Works

1. 📥 Email is received (manual or Gmail)
2. 🧹 Text preprocessing is applied
3. 🧠 TF-IDF converts text → features
4. 🤖 ML model classifies email
5. 📊 Output: **Safe / Phishing**

---

## 📬 Gmail Integration (Real-Time Detection)

This module can connect to a Gmail account and scan emails automatically.

### 🔹 Features

* 📥 Fetch emails from Gmail inbox
* 🔍 Analyze email subject + content
* ⚠️ Detect phishing emails in real-time
* 📊 Display results to user

---

### 🔹 How Gmail Integration Works

1. User connects Gmail account
2. System fetches recent emails
3. Each email is passed to ML model
4. Output is shown:

   * Safe ✅
   * Phishing ❌

---

### 🔹 Requirements

To enable Gmail integration:

* Gmail account
* App password / OAuth credentials
* IMAP enabled in Gmail

---

### 🔹 Example Flow

```text id="t1v6yo"
Gmail Inbox → Fetch Email → Analyze → Prediction → Result
```

---

## 🧠 Machine Learning Details

* Algorithm: *(e.g. Logistic Regression / Naive Bayes)*
* Feature Extraction: TF-IDF
* Dataset: Email phishing dataset (CSV)

---

## ▶️ How to Run

### Install dependencies

```bash id="w1mwhd"
pip install -r requirements.txt
```

### Run module

```bash id="9u4nsf"
python app.py
```

---

## 🧪 Example

### Input:

```text id="2rz2nb"
"Urgent! Your account will be blocked. Click here to verify."
```

### Output:

```text id="8s9h7f"
Phishing Email ❌
```

---

## 🔗 API Endpoints

| Endpoint | Method | Description               |
| -------- | ------ | ------------------------- |
| `/email` | POST   | Detect phishing           |
| `/gmail` | GET    | Fetch & scan Gmail emails |

---

## 📊 Output

* ✅ Safe Email
* ❌ Phishing Email

---

## ⚠️ Limitations

* May miss new phishing patterns
* Depends on dataset quality
* Gmail API rate limits

---

## 🔐 Security Note

🚫 Do NOT upload:

* Gmail credentials
* API keys
* `.env` files

---

## 💡 Future Improvements

* 🔄 Live Gmail monitoring
* 🧠 Deep learning (BERT / LSTM)
* 📱 Mobile notifications
* 🌐 Browser extension integration

---
