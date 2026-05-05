# ==============================
# 📦 Required Imports
# ==============================

from imapclient import IMAPClient
import email
import ssl
import sys
import re
import json
from email.header import decode_header

# ==============================
# 🔐 LOAD CONFIG
# ==============================

with open("config.json") as f:
    config = json.load(f)

EMAIL = config["email"]
PASSWORD = config["password"]
IMAP_SERVER = config["imap_server"]

# ==============================
# 📌 Track emails
# ==============================

last_uid = None
processed_uids = set()

# ==============================
# 🚨 Suspicious Keyword List
# ==============================

SUSPICIOUS_KEYWORDS = [
    "urgent", "lottery", "winner",
    "verify", "bank", "account suspended",
    "click here", "free money",
    "password reset", "limited offer",
    "claim now", "crypto", "investment"
]

SUSPICIOUS_DOMAINS = [
    ".xyz", ".top", ".ru", ".tk"
]

# ==============================
# 🔤 Decode Text
# ==============================

def decode_text(text):
    if text:
        decoded, encoding = decode_header(text)[0]
        if isinstance(decoded, bytes):
            return decoded.decode(encoding if encoding else "utf-8", errors="ignore")
        return decoded
    return ""

# ==============================
# 🔎 Suspicious Detection Logic
# ==============================

def is_suspicious(subject, sender, body):

    text = f"{subject} {sender} {body}".lower()
    score = 0

    for word in SUSPICIOUS_KEYWORDS:
        if word in text:
            score += 1

    links = re.findall(r'https?://\S+', text)
    if len(links) >= 2:
        score += 1

    for domain in SUSPICIOUS_DOMAINS:
        if domain in text:
            score += 1

    if subject and subject.isupper():
        score += 1

    return score >= 2

# ==============================
# 📧 Extract Email Body
# ==============================

def extract_body(msg):

    body = ""

    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                try:
                    body = part.get_payload(decode=True).decode(errors="ignore")
                except:
                    pass
    else:
        try:
            body = msg.get_payload(decode=True).decode(errors="ignore")
        except:
            pass

    return body

# ==============================
# 📩 Check Emails (UPDATED)
# ==============================

def check_emails(server, update_callback):

    global last_uid, processed_uids

    if last_uid:
        messages = server.search(['UID', f'{last_uid+1}:*'])
    else:
        messages = []

    for uid in messages:

        if uid in processed_uids:
            continue
        processed_uids.add(uid)

        response = server.fetch(uid, ["RFC822"])
        raw_message = response[uid][b"RFC822"]

        msg = email.message_from_bytes(raw_message)

        subject = decode_text(msg.get("subject", "No Subject"))
        sender = decode_text(msg.get("from", ""))
        body = extract_body(msg)

        print("\n📩 New Email Detected")
        print("From:", sender)
        print("Subject:", subject)

        if is_suspicious(subject, sender, body):
            status = "Phishing"
            print("🚨 Suspicious Email Detected!")
        else:
            status = "Safe"
            print("✅ Safe Email")

        # 🔥 SEND DATA TO FLASK
        update_callback(sender, subject, status)

        last_uid = uid

# ==============================
# 🔄 Live Monitoring
# ==============================

def start_monitoring(update_callback):

    global last_uid
    context = ssl.create_default_context()

    try:
        with IMAPClient(IMAP_SERVER, ssl=True, ssl_context=context) as server:

            server.login(EMAIL, PASSWORD)
            server.select_folder("INBOX")

            uids = server.search(["ALL"])
            if uids:
                last_uid = uids[-1]

            print("🚀 Live Email Monitoring Started")

            while True:
                try:
                    check_emails(server, update_callback)

                    server.idle()
                    server.idle_check(timeout=10)
                    server.idle_done()

                except KeyboardInterrupt:
                    print("\n🛑 Monitoring Stopped.")
                    server.logout()
                    sys.exit()

    except Exception as e:
        print("❌ Error:", e)