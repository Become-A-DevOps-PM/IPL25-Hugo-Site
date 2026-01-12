#!/bin/bash
# Local development server with hot reload

set -e
cd "$(dirname "$0")"

# Create and activate virtual environment
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi
source .venv/bin/activate

# Install dependencies if needed
if [ ! -f ".venv/.installed" ]; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
    touch .venv/.installed
fi

# Run migrations
flask db upgrade

# Start Flask with hot reload
echo "Starting Flask on http://localhost:5000 (hot reload enabled)"
flask run --debug
