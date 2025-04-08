import os
import time
import logging
import requests
from flask import Flask, request, make_response

logging.basicConfig(level=logging.INFO)
app = Flask(__name__)

# In-memory store: ip -> {cookie, expires_at}
# Production tip: use Redis or a database instead
SESSIONS = {}

# Example configuration: these might be environment variables or secrets
BACKEND_USERNAME = os.getenv("BACKEND_USERNAME", "copilot_ro_user")
BACKEND_PASSWORD = os.getenv("BACKEND_PASSWORD", "copilot_pwd")
BACKEND_URL     = os.getenv("BACKEND_URL", "copilot_fqdn")

SESSION_TTL = 3600  # 1 hour, for example

import requests

def copilot_login(username, password, copilot_url):
    s = requests.Session()
    payload = {"username": username, "password": password}
    r = s.post(f"https://{copilot_url}/api/login", json=payload, verify=True)

    if r.status_code == 200:
        # The session object (s) should have both cookies if the backend sets them
        session_cookie     = s.cookies.get("session")
        session_sig_cookie = s.cookies.get("session.sig")
        if session_cookie and session_sig_cookie:
            return (session_cookie, session_sig_cookie), None
        else:
            return None, "Missing 'session' or 'session.sig' in the login response."
    else:
        return None, f"Login failed: {r.status_code} {r.text}"


SESSIONS = {}  # e.g. { client_ip: {"session": "...", "session_sig": "...", "expires_at": 123456789 } }

def store_session(client_ip, session_cookie, session_sig_cookie):
    SESSIONS[client_ip] = {
        "session": session_cookie,
        "session_sig": session_sig_cookie,
        "expires_at": time.time() + SESSION_TTL
    }

def get_session(client_ip):
    return SESSIONS.get(client_ip)

@app.route("/validate", methods=["GET"])
def validate():
    client_ip = request.headers.get("X-Forwarded-For") or request.remote_addr
    stored = get_session(client_ip)
    if stored and time.time() < stored["expires_at"]:
        # already have a valid session
        session_str = f"session={stored['session']}; session.sig={stored['session_sig']}"
        return build_ok_response(session_str, client_ip)

    # Need to login or re-login
    (sess, sig), error = copilot_login(BACKEND_USERNAME, BACKEND_PASSWORD, BACKEND_URL)
    if error:
        return make_response(error, 401)

    # Store in memory
    store_session(client_ip, sess, sig)

    session_str = f"session={sess}; session.sig={sig}"
    return build_ok_response(session_str, client_ip)

def build_ok_response(cookie_value, client_ip):
    resp = make_response("", 200)
    # We'll combine both cookies into a single custom header "Session-Cookie"
    resp.headers["Session-Cookie"] = cookie_value
    resp.headers["X-User-Id"] = f'demo-user-${client_ip.replace(".", "-")}'
    return resp


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
