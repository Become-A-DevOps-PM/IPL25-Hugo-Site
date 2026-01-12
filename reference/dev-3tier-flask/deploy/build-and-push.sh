#!/bin/bash
# =============================================================================
# BUILD AND PUSH DOCKER IMAGE TO ACR
# =============================================================================
# Builds the Flask application Docker image and pushes it to Azure Container
# Registry. Must be run after infrastructure provisioning.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

APP_DIR="$PROJECT_DIR/application"

echo "=== Build and Push Docker Image ==="
echo ""

# -----------------------------------------------------------------------------
# Prerequisites check
# -----------------------------------------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found. Install from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker daemon is not running. Start Docker Desktop or docker service."
    exit 1
fi

# Get ACR login server
ACR_LOGIN_SERVER=$(get_acr_login_server)
if [ -z "$ACR_LOGIN_SERVER" ]; then
    echo "ERROR: Could not get ACR login server. Is the infrastructure deployed?"
    echo "Run: ./infrastructure/provision-containerapp.sh"
    exit 1
fi

FULL_IMAGE_NAME="${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Configuration:"
echo "  ACR Login Server: $ACR_LOGIN_SERVER"
echo "  Image Name:       $FULL_IMAGE_NAME"
echo ""

# -----------------------------------------------------------------------------
# Login to ACR
# -----------------------------------------------------------------------------
echo "Logging in to Azure Container Registry..."
az acr login --name "$ACR_NAME" --output none
echo "  Logged in to ACR."
echo ""

# -----------------------------------------------------------------------------
# Build Docker image
# -----------------------------------------------------------------------------
echo "Building Docker image..."
echo "  Context: $APP_DIR"
echo ""

docker build \
    --tag "$FULL_IMAGE_NAME" \
    --file "$APP_DIR/Dockerfile" \
    "$APP_DIR"

echo ""
echo "  Image built successfully."
echo ""

# -----------------------------------------------------------------------------
# Push to ACR
# -----------------------------------------------------------------------------
echo "Pushing image to ACR..."
docker push "$FULL_IMAGE_NAME"
echo ""
echo "  Image pushed successfully."
echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=== Image Ready ==="
echo ""
echo "Image: $FULL_IMAGE_NAME"
echo ""
echo "Next step:"
echo "  Deploy Container App: ./deploy/deploy-containerapp.sh"
echo ""
