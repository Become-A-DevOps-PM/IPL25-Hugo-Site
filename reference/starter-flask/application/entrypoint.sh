#!/bin/bash
# =============================================================================
# CONTAINER ENTRYPOINT SCRIPT
# =============================================================================
# Runs database migrations before starting the Flask application.
# Preserves graceful degradation: app starts even if migrations fail.
# =============================================================================

set -e

# Run migrations if database is configured
if [ -n "$DATABASE_URL" ] || [ "$USE_SQLITE" = "true" ]; then
    echo "Running database migrations..."
    flask db upgrade || {
        echo "WARNING: Migration failed - continuing anyway (graceful degradation)"
    }
else
    echo "No database configured - skipping migrations"
fi

# Start the application with Gunicorn
echo "Starting Flask application..."
exec gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 120 wsgi:app
