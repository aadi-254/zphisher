#!/bin/bash

PYTHON_FILE="server.py"
PORT=5000

echo "🔍 Checking for Python3..."
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 is not installed. Please install it first."
    exit 1
fi
echo "✅ Python3 is available."

echo "🔍 Checking for pip3..."
if ! command -v pip3 &>/dev/null; then
    echo "📦 Installing pip3..."
    sudo apt update && sudo apt install -y python3-pip
else
    echo "✅ pip3 is available."
fi

# Required Python packages
REQUIRED_PKG=("flask")

echo "🔍 Checking required Python modules..."
for pkg in "${REQUIRED_PKG[@]}"; do
    python3 -c "import $pkg" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "📦 Installing missing package: $pkg"
        pip3 install $pkg
    else
        echo "✅ $pkg is already installed."
    fi
done
# Check for cloudflared
echo "🔍 Checking for cloudflared..."
if ! command -v cloudflared >/dev/null 2>&1; then
    echo "📦 Installing cloudflared..."
    
    # Detect architecture (assuming x86_64 for simplicity)
    ARCH=$(uname -m)
    CLOUDFLARED_URL=""

    if [[ "$ARCH" == "x86_64" ]]; then
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi

    curl -L -o cloudflared "$CLOUDFLARED_URL"
    chmod +x cloudflared

    # Move to user bin if sudo available, else local bin
    if command -v sudo >/dev/null 2>&1; then
        sudo mv cloudflared /usr/local/bin/
    else
        mkdir -p "$HOME/.local/bin"
        mv cloudflared "$HOME/.local/bin/"
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # persist PATH update
    fi

    echo "✅ cloudflared installed!"
else
    echo "✅ cloudflared is already installed."
fi

echo "🔍 Checking for cloudflared..."
if ! command -v cloudflared &>/dev/null; then
    echo "📦 Installing cloudflared manually..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    sudo apt-get install -f -y
    rm cloudflared-linux-amd64.deb
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

# Optional: Clear old logs (customize this line if you have logs)
if [ -f "log.txt" ]; then
    echo "🧽 Clearing old logs..."
    > log.txt
    echo "✅ Logs cleared."
fi

# Start the Python server
echo "🚀 Starting $PYTHON_FILE..."
python3 "$PYTHON_FILE"
