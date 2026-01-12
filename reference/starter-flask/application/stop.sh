#!/bin/bash
# =============================================================================
# Stop Flask development server
# =============================================================================
# Stops Flask and deactivates virtual environment.
# Usage: source stop.sh  (or: . stop.sh)
# =============================================================================

# Kill Flask process on port 5005
pkill -f "flask run --port 5005" 2>/dev/null && echo "Flask server stopped" || echo "Flask server not running"

# Deactivate virtual environment (only works if sourced)
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate 2>/dev/null && echo "Virtual environment deactivated"
fi
