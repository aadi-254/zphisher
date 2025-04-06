#!/bin/bash

PYTHON_FILE="server.py"
PORT=5000

echo "🔍 Checking for Python3..."
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 is not installed. Please install it first."
    exit 1
fi
echo "✅ Python3 is available."

# Required Python packages
REQUIRED_PKG=("flask")

echo "🔍 Checking required Python modules..."
for pkg in "${REQUIRED_PKG[@]}"; do
    python3 -c "import $pkg" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "📦 Installing missing package: $pkg"
        pip install $pkg
    else
        echo "✅ $pkg is already installed."
    fi
done

echo "🔍 Checking for cloudflared..."
if ! command -v cloudflared &>/dev/null; then
    echo "📦 Installing cloudflared..."
    sudo apt update && sudo apt install -y cloudflared
else
    echo "✅ cloudflared is already installed."
fi

# Kill any process running on the required port
echo "🧹 Checking for processes on port $PORT..."
PID=$(lsof -t -i:$PORT)
if [ -n "$PID" ]; then
    echo "⚠️ Port $PORT is already in use. Killing process $PID..."
    kill -9 $PID
    echo "✅ Killed process on port $PORT."
else
    echo "✅ Port $PORT is free."
fi

# Clear old logs
rm -f cf_tunnel.log

# Final info and launch
echo "🚀 Starting $PYTHON_FILE..."
python3 "$PYTHON_FILE"
