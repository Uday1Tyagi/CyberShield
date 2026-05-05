import random
import smtplib
import time
import json
from fastapi import FastAPI

app = FastAPI()

otp_storage = {}

EMAIL = "hello959604@gmail.com"
PASSWORD = "iamn wgix emof occh"


# send styled email
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(receiver, otp):

    subject = "CyberShield OTP Verification 🔐"

    html = f"""

<html>

<body style="margin:0;padding:0;background:#020617;font-family:Arial">

<div style="max-width:600px;margin:auto;background:#0f172a;padding:30px;border-radius:10px">

<h1 style="color:#22c55e;text-align:center">
🛡 CyberShield Security
</h1>

<p style="color:#cbd5f5;font-size:16px">

Hello,

</p>

<p style="color:#cbd5f5;font-size:16px">

We received a request to create or access your account.

Please use the One-Time Password (OTP) below to continue securely.

</p>

<div style="background:#020617;padding:20px;margin:30px 0;text-align:center;border-radius:8px">

<h2 style="letter-spacing:6px;color:#22c55e;font-size:32px">

{otp}

</h2>

</div>

<p style="color:#cbd5f5">

⏳ This OTP will expire in <b>2 minutes</b>.

</p>

<p style="color:#94a3b8">

If you did not request this verification, please ignore this email.

</p>

<hr style="border-color:#1e293b">

<p style="color:#64748b;font-size:13px">

🔒 Security Tip:
Never share your OTP with anyone, even if they claim to be from CyberShield.

</p>

<p style="color:#64748b;font-size:13px">

© CyberShield Security System

</p>

</div>

</body>

</html>

"""

    msg = MIMEMultipart()

    msg["From"] = EMAIL
    msg["To"] = receiver
    msg["Subject"] = subject

    msg.attach(MIMEText(html,"html"))

    server = smtplib.SMTP("smtp.gmail.com",587)
    server.starttls()
    server.login(EMAIL,PASSWORD)

    server.send_message(msg)

    server.quit()



# save user json
def save_user(email,password):

    file="users.json"

    try:
        with open(file) as f:
            users=json.load(f)

    except:
        users=[]

    # check duplicate
    for user in users:

        if user["email"] == email:

            return False

    users.append({

        "email":email,
        "password":password,
        "created":time.ctime()

    })

    with open(file,"w") as f:

        json.dump(users,f,indent=2)

    return True



# send otp
@app.post("/send_otp")
def send_otp(email:str):

    try:

        with open("users.json") as f:

            users=json.load(f)

        for user in users:

            if user["email"] == email:

                return {"status":"exists"}

    except:

        pass


    otp = str(random.randint(100000,999999))

    otp_storage[email] = {

        "otp":otp,
        "time":time.time()

    }

    send_email(email,otp)

    return {"status":"success"}



# verify otp
@app.post("/verify_otp")
def verify_otp(email:str,otp:str,password:str):

    data = otp_storage.get(email)

    if not data:

        return {"status":"error"}

    if time.time() - data["time"] > 120:

        return {"status":"expired"}

    if data["otp"] == otp:

        created = save_user(email,password)

        if not created:

            return {"status":"exists"}

        return {"status":"verified"}

    return {"status":"invalid"}



# login
@app.post("/login")
def login(email:str,password:str):

    try:

        with open("users.json") as f:

            users=json.load(f)

        for user in users:

            if user["email"] == email and user["password"] == password:

                return {"status":"success"}

    except:

        pass

    return {"status":"invalid"}