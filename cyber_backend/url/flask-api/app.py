# app.py — URL Shield Flask API Backend
# Run: python app.py
# API will start at http://localhost:5002

import re
import os
import time
import socket
import hashlib
import json
import requests
import tldextract
from datetime import datetime
from urllib.parse import urlparse
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # allow desktop app to call this API

# ── CONFIG ────────────────────────────────────────────────────────────────────
VT_API_KEY     = os.environ.get("VT_API_KEY", "")   # set your VirusTotal key here
CACHE_FILE     = "scan_cache.json"
CACHE_TTL      = 1800  # 30 minutes

WHITELIST = {
    "google.com", "youtube.com", "github.com", "stackoverflow.com",
    "wikipedia.org", "amazon.com", "microsoft.com", "apple.com",
    "mozilla.org", "cloudflare.com", "reddit.com", "twitter.com",
    "facebook.com", "instagram.com", "linkedin.com", "netflix.com",
    "python.org", "pypi.org", "npmjs.com", "anthropic.com",
}

# ── CACHE ─────────────────────────────────────────────────────────────────────
def load_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE) as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def save_cache(cache):
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump(cache, f, indent=2)
    except Exception:
        pass

def cache_get(url):
    cache = load_cache()
    key = hashlib.md5(url.encode()).hexdigest()
    entry = cache.get(key)
    if entry and (time.time() - entry.get("ts", 0)) < CACHE_TTL:
        return entry
    return None

def cache_set(url, result):
    cache = load_cache()
    key = hashlib.md5(url.encode()).hexdigest()
    result["ts"] = time.time()
    cache[key] = result
    # Keep only last 500 entries
    if len(cache) > 500:
        oldest = sorted(cache.items(), key=lambda x: x[1].get("ts", 0))
        cache = dict(oldest[-500:])
    save_cache(cache)

# ── WHITELIST ─────────────────────────────────────────────────────────────────
def is_whitelisted(url):
    try:
        hostname = urlparse(url).hostname.replace("www.", "")
        return any(hostname == w or hostname.endswith("." + w) for w in WHITELIST)
    except Exception:
        return False

# ── HEURISTIC SCANNER ─────────────────────────────────────────────────────────
def scan_heuristics(url):
    signals = []
    score   = 0

    try:
        parsed   = urlparse(url)
        hostname = parsed.hostname or ""
        full     = url.lower()
        ext      = tldextract.extract(url)

        # 1. IP as hostname
        try:
            socket.inet_aton(hostname)
            signals.append({"text": "IP address used as hostname", "severity": "danger", "points": 30})
            score += 30
        except Exception:
            pass

        # 2. URL length
        if len(url) > 75:
            signals.append({"text": f"Unusually long URL ({len(url)} chars)", "severity": "warn", "points": 10})
            score += 10

        # 3. @ symbol
        if "@" in url:
            signals.append({"text": "@ symbol in URL (redirect trick)", "severity": "danger", "points": 25})
            score += 25

        # 4. No HTTPS
        if parsed.scheme != "https":
            signals.append({"text": "No HTTPS encryption", "severity": "warn", "points": 10})
            score += 10

        # 5. Excessive subdomains
        subdomain_count = len(ext.subdomain.split(".")) if ext.subdomain else 0
        if subdomain_count >= 3:
            signals.append({"text": f"Too many subdomains ({subdomain_count})", "severity": "warn", "points": 15})
            score += 15

        # 6. Hyphens in domain
        if ext.domain.count("-") >= 3:
            signals.append({"text": "Excessive hyphens in domain", "severity": "warn", "points": 10})
            score += 10

        # 7. Phishing keywords
        KEYWORDS = ["login", "verify", "secure", "account", "update",
                    "banking", "paypal", "confirm", "password", "signin", "webscr"]
        hits = [k for k in KEYWORDS if k in full]
        if hits:
            pts = min(len(hits) * 8, 25)
            signals.append({"text": f"Phishing keywords: {', '.join(hits)}", "severity": "warn", "points": pts})
            score += pts

        # 8. URL shortener
        SHORTENERS = ["bit.ly", "tinyurl.com", "t.co", "goo.gl", "ow.ly", "rb.gy"]
        if any(s in hostname for s in SHORTENERS):
            signals.append({"text": "URL shortener (hides real destination)", "severity": "warn", "points": 15})
            score += 15

        # 9. Brand spoofing in subdomain
        BRANDS = ["paypal", "amazon", "google", "apple", "microsoft",
                  "facebook", "netflix", "instagram", "twitter", "bank"]
        if ext.subdomain:
            brand = next((b for b in BRANDS if b in ext.subdomain.lower()), None)
            if brand:
                signals.append({"text": f'Brand "{brand}" spoofed in subdomain', "severity": "danger", "points": 40})
                score += 40

        # 10. Double extension
        if re.search(r'\.(exe|php|js|bat|sh)\.(html?|jpg|png|pdf)$', parsed.path, re.I):
            signals.append({"text": "Double file extension (possible malware)", "severity": "danger", "points": 20})
            score += 20

        # 11. Encoded chars in hostname
        if re.search(r'%[0-9a-fA-F]{2}', hostname):
            signals.append({"text": "Encoded characters in hostname", "severity": "danger", "points": 20})
            score += 20

    except Exception as e:
        signals.append({"text": f"Parse error: {str(e)}", "severity": "warn", "points": 5})
        score += 5

    return signals, score

# ── DOMAIN AGE ────────────────────────────────────────────────────────────────
def check_domain_age(url):
    try:
        import whois
        ext    = tldextract.extract(url)
        domain = f"{ext.domain}.{ext.suffix}"
        w      = whois.whois(domain)
        creation = w.creation_date
        if isinstance(creation, list):
            creation = creation[0]
        if creation:
            age_days = (datetime.now() - creation).days
            return domain, age_days
    except Exception:
        pass
    return None, None

# ── VIRUSTOTAL ────────────────────────────────────────────────────────────────
def check_virustotal(url):
    if not VT_API_KEY:
        return None
    try:
        headers = {"x-apikey": VT_API_KEY}
        r = requests.post(
            "https://www.virustotal.com/api/v3/urls",
            headers=headers, data={"url": url}, timeout=10
        )
        if r.status_code != 200:
            return None
        analysis_id = r.json()["data"]["id"]
        time.sleep(3)
        result = requests.get(
            f"https://www.virustotal.com/api/v3/analyses/{analysis_id}",
            headers=headers, timeout=15
        ).json()
        stats = result["data"]["attributes"]["stats"]
        malicious = stats.get("malicious", 0)
        total = sum(stats.values())
        return {"malicious": malicious, "total": total}
    except Exception:
        return None

# ── VERDICT ───────────────────────────────────────────────────────────────────
def get_verdict(score):
    if score >= 50: return "dangerous"
    if score >= 25: return "suspicious"
    return "safe"

# ── MAIN SCAN ─────────────────────────────────────────────────────────────────
def scan_url(url):
    # Normalize
    if not re.match(r"https?://", url):
        url = "http://" + url

    parsed = urlparse(url)
    if not parsed.netloc:
        return {"error": "Invalid URL", "url": url}

    # Cache check
    cached = cache_get(url)
    if cached:
        cached["cached"] = True
        return cached

    # Whitelist
    if is_whitelisted(url):
        result = {
            "url": url, "score": 0, "verdict": "safe",
            "signals": [{"text": "Domain is on trusted whitelist", "severity": "safe", "points": 0}],
            "domain": urlparse(url).hostname,
            "domain_age": None, "vt": None, "cached": False
        }
        cache_set(url, result)
        return result

    total_score = 0

    # Layer 1 — Heuristics
    signals, h_score = scan_heuristics(url)
    total_score += h_score

    # Layer 2 — Domain age
    domain, age_days = check_domain_age(url)
    age_score = 0
    if age_days is not None:
        if age_days < 30:
            age_score = 30
            signals.append({"text": f"New domain — only {age_days} days old", "severity": "danger", "points": 30})
        elif age_days < 90:
            age_score = 20
            signals.append({"text": f"Young domain — {age_days} days old", "severity": "warn", "points": 20})
    total_score += age_score

    # Layer 3 — VirusTotal
    vt = check_virustotal(url)
    vt_score = 0
    if vt and vt["total"] > 0:
        vt_score = min(int((vt["malicious"] / vt["total"]) * 100) * 2, 50)
        if vt["malicious"] > 0:
            signals.append({"text": f"VirusTotal: {vt['malicious']}/{vt['total']} engines flagged", "severity": "danger", "points": vt_score})
    total_score += vt_score

    result = {
        "url": url,
        "domain": domain or urlparse(url).hostname,
        "score": total_score,
        "verdict": get_verdict(total_score),
        "signals": signals,
        "domain_age": age_days,
        "vt": vt,
        "cached": False,
        "scanned_at": datetime.now().isoformat()
    }
    cache_set(url, result)
    return result

# ── ROUTES ────────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/scan", methods=["POST"])
def api_scan():
    data = request.get_json()
    if not data or not data.get("url"):
        return jsonify({"error": "No URL provided"}), 400
    result = scan_url(data["url"].strip())
    return jsonify(result)

@app.route("/api/scan", methods=["GET"])
def api_scan_get():
    url = request.args.get("url", "").strip()
    if not url:
        return jsonify({"error": "No URL provided"}), 400
    result = scan_url(url)
    return jsonify(result)

@app.route("/api/history", methods=["GET"])
def api_history():
    cache = load_cache()
    history = sorted(cache.values(), key=lambda x: x.get("ts", 0), reverse=True)
    return jsonify(history[:50])

@app.route("/api/stats", methods=["GET"])
def api_stats():
    cache = load_cache()
    entries = list(cache.values())
    return jsonify({
        "total_scanned": len(entries),
        "safe": sum(1 for e in entries if e.get("verdict") == "safe"),
        "suspicious": sum(1 for e in entries if e.get("verdict") == "suspicious"),
        "dangerous": sum(1 for e in entries if e.get("verdict") == "dangerous"),
    })

if __name__ == "__main__":
    print("\n  🛡  URL Shield API starting...")
    print("  📡  API:     http://localhost:5002/api/scan")
    print("  🌐  Web UI:  http://localhost:5002\n")
    app.run(host="0.0.0.0", port=5002, debug=False)
