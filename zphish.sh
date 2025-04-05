#!/bin/bash

PYTHON_FILE="server.py"

echo "🔍 Checking for resources.we are going to first installed all dependencies (Only Once)"
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 is not installed. Please install it first."
    exit 1
fi

echo "✅ Python3 is available."

# Required Python packages
REQUIRED_PKG=("flask" "pyngrok")

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

echo "🚀 Starting $PYTHON_FILE..."
python3 "$PYTHON_FILE"
