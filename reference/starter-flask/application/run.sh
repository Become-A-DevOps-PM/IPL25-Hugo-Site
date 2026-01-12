#!/bin/bash
# =============================================================================
# Local development server startup script
# =============================================================================
# Runs migrations and starts Flask. Safe to run multiple times (idempotent).
# =============================================================================

set -e

cd "$(dirname "$0")"

# Activate virtual environment
if [ -d ".venv" ]; then
    source .venv/bin/activate
else
    echo "Creating virtual environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
fi

# Use SQLite for local development
export USE_SQLITE=true

# Run migrations (idempotent - only applies pending migrations)
echo "Running database migrations..."
flask db upgrade

# Start Flask
echo "Starting Flask on http://localhost:5005"
flask run --port 5005
