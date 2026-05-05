import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import time
import logging
from datetime import datetime
from collections import defaultdict
from dotenv import load_dotenv
load_dotenv()

# ── APP SETUP ─────────────────────────────────────────────────────────────────
app = Flask(__name__)
CORS(app)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
log = logging.getLogger(__name__)

# ── CONFIG ────────────────────────────────────────────────────────────────────
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_URL      = "https://api.groq.com/openai/v1/chat/completions"

# Upgraded to the best available free Groq model
MODEL         = "llama-3.3-70b-versatile"
MAX_TOKENS    = 2048       # increased for detailed answers
TEMPERATURE   = 0.6
MAX_HISTORY   = 20         # max conversation turns to keep

# Rate limiting — max requests per IP per minute
RATE_LIMIT    = 15
rate_tracker  = defaultdict(list)

# In-memory chat session store  { session_id: [messages] }
sessions      = {}

# Stats counter
stats = {"total_requests": 0, "successful": 0, "failed": 0, "start_time": datetime.now()}


# ── SYSTEM PROMPT ─────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """You are CyberGuard AI, a highly knowledgeable, friendly, and professional cybersecurity expert assistant.

YOUR IDENTITY:
- Name: CyberGuard AI
- Role: Dedicated Cybersecurity Specialist
- Personality: Friendly, clear, educational, and practical

YOUR PURPOSE:
Help users understand cybersecurity concepts, threats, and best practices in a user-friendly way.
You ONLY answer cybersecurity-related questions.

TOPICS YOU ARE EXPERT IN:
1. Threats & Attacks
   - Phishing (email, spear, smishing, vishing, whaling)
   - Malware (viruses, trojans, worms, spyware, adware, keyloggers, rootkits)
   - Ransomware (WannaCry, LockBit, REvil, prevention & recovery)
   - Social engineering (pretexting, baiting, quid pro quo, tailgating)
   - DDoS attacks, botnets, zero-day exploits
   - Man-in-the-middle attacks, replay attacks, brute force

2. Network Security
   - Firewalls (packet filtering, stateful, NGFW, WAF)
   - VPN (types, protocols, when to use)
   - IDS/IPS systems
   - Network segmentation, DMZ, honeypots
   - Wi-Fi security (WPA3, rogue APs, evil twin)
   - Zero Trust Architecture

3. Web & App Security
   - OWASP Top 10 (all 10 in detail)
   - SQL injection, XSS, CSRF, SSRF, XXE
   - Broken authentication, insecure deserialization
   - Secure coding practices, input validation
   - API security

4. Cryptography & Encryption
   - Symmetric encryption (AES-128/256, DES, 3DES)
   - Asymmetric encryption (RSA, ECC, Diffie-Hellman)
   - Hashing (MD5, SHA-1, SHA-256, bcrypt)
   - TLS/SSL, HTTPS, digital certificates
   - PKI, digital signatures, end-to-end encryption
   - Password hashing and salting

5. Identity & Access
   - Strong passwords, password managers (Bitwarden, 1Password)
   - 2FA/MFA (TOTP, hardware keys, SMS)
   - Single Sign-On (SSO), OAuth, SAML
   - Principle of least privilege, RBAC, PAM

6. Data Protection
   - Data breaches (causes, impact, response)
   - GDPR, HIPAA, PCI-DSS compliance
   - Data classification, DLP tools
   - Backup strategies (3-2-1 rule)
   - Identity theft prevention & recovery

7. Security Operations
   - Penetration testing phases and methodologies
   - Ethical hacking (tools: Metasploit, Nmap, Burp Suite, Wireshark)
   - Bug bounty programs
   - OSINT (Open Source Intelligence)
   - SIEM, SOC, threat intelligence
   - Incident response lifecycle
   - Digital forensics basics

8. Platform Security
   - Windows security hardening
   - Linux security best practices
   - Mobile security (Android/iOS)
   - Cloud security (AWS, Azure, GCP)
   - IoT security challenges
   - Container/Docker security

9. Emerging Topics
   - AI-powered cyberattacks
   - Deepfake threats
   - Quantum computing & post-quantum cryptography
   - Supply chain attacks
   - Cryptocurrency scams and blockchain security
   - Dark web monitoring

RESPONSE GUIDELINES:
- Start with a direct, clear answer to the question
- Use **bold** for key terms and important points
- Use bullet points for lists — keep them concise
- Use numbered steps for processes/guides
- Give real-world examples when helpful
- Always end with a practical tip or actionable next step
- Keep responses well-structured but not overly long
- Use emojis sparingly for friendliness (🔐 🛡️ ⚠️ ✅)

IF THE QUESTION IS NOT ABOUT CYBERSECURITY:
Respond with exactly: "🛡️ I'm CyberGuard AI — a specialist in cybersecurity only. I can't help with that topic, but I'd love to answer any cybersecurity questions you have! Try asking me about phishing, malware, encryption, or how to stay safe online."

NEVER answer questions about: cooking, sports, entertainment, general coding, mathematics, history, geography, or any non-security topic.
"""


# ── HELPERS ───────────────────────────────────────────────────────────────────

def is_rate_limited(ip):
    """Allow max RATE_LIMIT requests per IP per 60 seconds."""
    now = time.time()
    rate_tracker[ip] = [t for t in rate_tracker[ip] if now - t < 60]
    if len(rate_tracker[ip]) >= RATE_LIMIT:
        return True
    rate_tracker[ip].append(now)
    return False


def call_groq(messages):
    """Call Groq API and return (reply_text, usage_dict, error)."""
    headers = {
        "Content-Type":  "application/json",
        "Authorization": f"Bearer {GROQ_API_KEY}"
    }
    payload = {
        "model":       MODEL,
        "messages":    messages,
        "max_tokens":  MAX_TOKENS,
        "temperature": TEMPERATURE,
        "stream":      False,
    }
    resp   = requests.post(GROQ_URL, headers=headers, json=payload, timeout=30)
    result = resp.json()

    if resp.status_code != 200:
        err = result.get("error", {}).get("message", "Groq API error")
        return None, None, err

    reply = result["choices"][0]["message"]["content"]
    usage = result.get("usage", {})
    return reply, usage, None


# ── ROUTES ────────────────────────────────────────────────────────────────────

@app.route("/api/health", methods=["GET"])
def health():
    """Health check with server stats."""
    uptime = str(datetime.now() - stats["start_time"]).split(".")[0]
    return jsonify({
        "status":         "✅ running",
        "service":        "CyberGuard AI",
        "model":          MODEL,
        "uptime":         uptime,
        "total_requests": stats["total_requests"],
        "successful":     stats["successful"],
        "failed":         stats["failed"],
        "active_sessions":len(sessions),
    }), 200


@app.route("/api/chat", methods=["POST"])
def chat():
    """
    Main chat endpoint — supports multi-turn conversation via session_id.

    Request body (JSON):
    {
        "message":    "What is phishing?",       ← required
        "session_id": "user123",                 ← optional, for conversation memory
        "history": [...]                         ← optional, manual history override
    }

    Response:
    {
        "reply":      "Phishing is ...",
        "session_id": "user123",
        "model":      "llama-3.3-70b-versatile",
        "usage":      { "prompt_tokens": 50, "completion_tokens": 200 }
    }
    """
    ip   = request.remote_addr
    data = request.get_json()

    stats["total_requests"] += 1

    # ── Validate input
    if not data or not data.get("message"):
        stats["failed"] += 1
        return jsonify({"error": "Missing 'message' field in request body"}), 400

    user_message = data["message"].strip()
    if not user_message:
        stats["failed"] += 1
        return jsonify({"error": "Message cannot be empty"}), 400

    if len(user_message) > 2000:
        stats["failed"] += 1
        return jsonify({"error": "Message too long. Keep it under 2000 characters."}), 400

    # ── Rate limit
    if is_rate_limited(ip):
        stats["failed"] += 1
        return jsonify({"error": "Too many requests. Please wait a moment and try again."}), 429

    # ── Session / history management
    session_id = data.get("session_id", "default")

    if data.get("history"):
        # Manual history provided — use it directly
        conversation = data["history"]
    else:
        # Use server-side session memory
        if session_id not in sessions:
            sessions[session_id] = []
        conversation = sessions[session_id]

    # Build full messages array
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    messages += conversation[-MAX_HISTORY:]   # keep last N turns
    messages.append({"role": "user", "content": user_message})

    # ── Call Groq
    log.info(f"[{session_id}] User: {user_message[:80]}...")

    try:
        reply, usage, error = call_groq(messages)

        if error:
            stats["failed"] += 1
            log.error(f"Groq error: {error}")
            return jsonify({"error": error}), 502

        # Save to session memory
        if session_id not in sessions:
            sessions[session_id] = []
        sessions[session_id].append({"role": "user",      "content": user_message})
        sessions[session_id].append({"role": "assistant", "content": reply})

        # Trim old history
        if len(sessions[session_id]) > MAX_HISTORY * 2:
            sessions[session_id] = sessions[session_id][-MAX_HISTORY * 2:]

        stats["successful"] += 1
        log.info(f"[{session_id}] Bot replied ({usage.get('completion_tokens', '?')} tokens)")

        return jsonify({
            "reply":      reply,
            "session_id": session_id,
            "model":      MODEL,
            "usage":      usage,
        }), 200

    except requests.exceptions.Timeout:
        stats["failed"] += 1
        return jsonify({"error": "⏱️ Request timed out. Please try again."}), 504

    except requests.exceptions.ConnectionError:
        stats["failed"] += 1
        return jsonify({"error": "🌐 Cannot connect to Groq API. Check your internet connection."}), 503

    except Exception as e:
        stats["failed"] += 1
        log.error(f"Unexpected error: {e}")
        return jsonify({"error": f"Internal error: {str(e)}"}), 500


@app.route("/api/chat/clear", methods=["POST"])
def clear_session():
    """Clear conversation history for a session."""
    data       = request.get_json() or {}
    session_id = data.get("session_id", "default")
    if session_id in sessions:
        sessions.pop(session_id)
    return jsonify({"message": f"Session '{session_id}' cleared ✅"}), 200


@app.route("/api/chat/history", methods=["GET"])
def get_history():
    """Get conversation history for a session."""
    session_id = request.args.get("session_id", "default")
    history    = sessions.get(session_id, [])
    return jsonify({
        "session_id": session_id,
        "turns":      len(history) // 2,
        "history":    history
    }), 200


@app.route("/api/topics", methods=["GET"])
def topics():
    """List all cybersecurity topics covered."""
    return jsonify({
        "total": 9,
        "categories": {
            "Threats & Attacks":        ["Phishing", "Malware", "Ransomware", "Social Engineering", "DDoS", "Zero-Day"],
            "Network Security":         ["Firewalls", "VPN", "IDS/IPS", "Wi-Fi Security", "Zero Trust"],
            "Web & App Security":       ["OWASP Top 10", "SQL Injection", "XSS", "CSRF", "API Security"],
            "Cryptography":             ["AES", "RSA", "TLS/SSL", "Hashing", "Digital Signatures"],
            "Identity & Access":        ["Passwords", "2FA/MFA", "Password Managers", "SSO", "Least Privilege"],
            "Data Protection":          ["Data Breaches", "GDPR", "Backup Strategy", "Identity Theft"],
            "Security Operations":      ["Pen Testing", "Ethical Hacking", "OSINT", "SIEM", "Incident Response"],
            "Platform Security":        ["Windows", "Linux", "Mobile", "Cloud", "IoT", "Containers"],
            "Emerging Threats":         ["AI Attacks", "Deepfakes", "Quantum Crypto", "Supply Chain", "Dark Web"],
        }
    }), 200


@app.route("/api/quicktips", methods=["GET"])
def quicktips():
    """Returns security tips."""
    return jsonify({
        "tips": [
            "Use a password manager — never reuse passwords across sites.",
            "Enable 2FA on all important accounts — email, banking, social media.",
            "Keep all software and OS updated — patches fix known vulnerabilities.",
            "Verify links by hovering before clicking — check the real URL.",
            "Follow the 3-2-1 backup rule: 3 copies, 2 media types, 1 offsite.",
            "Only use HTTPS websites when entering sensitive information.",
            "Use a VPN on public Wi-Fi networks.",
            "Check haveibeenpwned.com to see if your email was in a breach.",
            "Never share OTP/verification codes with anyone — banks never ask.",
            "Lock your screen when stepping away from your device.",
        ]
    }), 200


# ── RUN ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n" + "=" * 58)
    print("   🛡️  CyberGuard AI — Upgraded Groq Backend")
    print("=" * 58)
    print(f"   Model        : {MODEL}")
    print(f"   Max Tokens   : {MAX_TOKENS}")
    print(f"   Rate Limit   : {RATE_LIMIT} requests/minute per IP")
    print(f"   Session Mem  : last {MAX_HISTORY} conversation turns")
    print(f"   API Key      : {'SET ✅' if GROQ_API_KEY else 'NOT SET ❌'}")
    print("=" * 58)
    print("   📡 Endpoints:")
    print("   GET  /api/health           → server stats")
    print("   POST /api/chat             → send message")
    print("   GET  /api/chat/history     → view history")
    print("   POST /api/chat/clear       → clear session")
    print("   GET  /api/topics           → all topics")
    print("   GET  /api/quicktips        → security tips")
    print("=" * 58)
    print("   🌐 Running at: http://localhost:5004\n")
    app.run(debug=True, port=5004)