import requests
import wmi
from security_core import verify_user, log_action
from security_core import lock_secure_folder
FLASK_BASE_URL = "http://127.0.0.1:5003"
lock_secure_folder()
c = wmi.WMI()

print("USB Guard Running... Monitoring USB devices 🔌")

# Create watcher object once
usb_watcher = c.watch_for(notification_type="Creation", wmi_class="Win32_PnPEntity")


def check_lock_status():
    try:
        response = requests.get(f"{FLASK_BASE_URL}/status")
        data = response.json()
        return data["locked"], data["lock_until"]
    except:
        return True, None


def verify_password(password):
    try:
        response = requests.post(
            f"{FLASK_BASE_URL}/verify",
            json={"password": password}
        )
        return response.json()
    except:
        return {"status": "error"}


waiting_for_password = False

while True:
    try:
        event = usb_watcher()
        print("\n🔌 USB Device Inserted")

        log_action("USB Device Inserted")

        locked, lock_until = check_lock_status()

        if locked:
            print(f"🚫 SYSTEM LOCKED until {lock_until}")
            continue

        if not waiting_for_password:
            print("🔐 Waiting for password from frontend...")
            waiting_for_password = True

    except Exception as e:
        print("Error:", e)