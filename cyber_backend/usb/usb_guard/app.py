from flask import Flask, request, jsonify
from security_core import verify_user, is_system_locked

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "USB Guard API Running"})


@app.route("/status", methods=["GET"])
def status():
    locked, lock_until = is_system_locked()
    return jsonify({
        "locked": locked,
        "lock_until": str(lock_until) if lock_until else None
    })


@app.route("/verify", methods=["POST"])
def verify():
    data = request.json
    password = data.get("password")

    if not password:
        return jsonify({"error": "Password required"}), 400

    result = verify_user(password)
    return jsonify(result)

@app.route("/logs", methods=["GET"])
def get_logs():
    from database import connect_db

    conn = connect_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT action_taken, system_user, lock_until 
        FROM usb_logs 
        ORDER BY id DESC 
        LIMIT 10
    """)

    rows = cursor.fetchall()
    conn.close()

    logs = []
    for row in rows:
        logs.append({
            "action": row[0],
            "user": row[1],
            "lock_until": str(row[2]) if row[2] else None
        })

    return jsonify(logs)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, debug=True)