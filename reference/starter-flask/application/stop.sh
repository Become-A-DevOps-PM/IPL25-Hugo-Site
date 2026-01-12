#!/bin/bash
# Stop Flask development server

pkill -f "flask run" 2>/dev/null && echo "Flask server stopped" || echo "Flask server not running"

if [ -n "$VIRTUAL_ENV" ]; then
    deactivate 2>/dev/null && echo "Virtual environment deactivated"
fi
