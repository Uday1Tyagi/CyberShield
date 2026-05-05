from flask import Flask, jsonify
import threading
from email_checker import start_monitoring

app = Flask(__name__)

latest_email = {
    "from": "",
    "subject": "",
    "status": ""
}

def update_result(sender, subject, status):
    global latest_email
    latest_email = {
        "from": sender,
        "subject": subject,
        "status": status
    }

@app.route("/get_latest")
def get_latest():
    return jsonify(latest_email)

def run_email():
    start_monitoring(update_result)

if __name__ == "__main__":
    t = threading.Thread(target=run_email)
    t.daemon = True
    t.start()

    app.run(port=5000)