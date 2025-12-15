#!/usr/bin/env bash
#
# Build static architecture documentation site with manual layout diagrams.
#
# This script:
# 1. Generates static site using Structurizr Site Generatr
# 2. Starts Structurizr Lite to access manual layout from workspace.json
# 3. Exports SVG diagrams via Puppeteer (headless Chrome)
# 4. Post-processes build to use exported SVGs instead of auto-layout
#
# Prerequisites:
# - Docker
# - Node.js (npm will auto-install Puppeteer locally)
#
# Usage: ./build-site.sh
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
DIAGRAMS_DIR="${SCRIPT_DIR}/diagrams"
STRUCTURIZR_PORT=18080
CONTAINER_NAME="structurizr-lite-export-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker."
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js."
        exit 1
    fi

    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install Node.js with npm."
        exit 1
    fi

    # Install dependencies locally if not present
    if [ ! -d "${SCRIPT_DIR}/node_modules" ]; then
        log_info "Installing dependencies (first run)..."
        cd "${SCRIPT_DIR}"
        npm install
    fi

    # Verify puppeteer is available
    cd "${SCRIPT_DIR}"
    if ! node -e "require('puppeteer')" 2>/dev/null; then
        log_error "Puppeteer installation failed. Try: rm -rf node_modules && npm install"
        exit 1
    fi

    log_info "All prerequisites met."
}

# Step 1: Clean and generate static site
generate_site() {
    log_info "Step 1: Generating static site..."

    # Clean build directory
    if [ -d "${BUILD_DIR}" ]; then
        log_info "Cleaning existing build directory..."
        rm -rf "${BUILD_DIR}"
    fi

    # Run Structurizr Site Generatr
    log_info "Running Structurizr Site Generatr..."
    docker run --rm \
        -v "${SCRIPT_DIR}:/workspace" \
        ghcr.io/avisi-cloud/structurizr-site-generatr \
        generate-site \
        --workspace-file /workspace/workspace.dsl \
        --output-dir /workspace/build

    if [ ! -d "${BUILD_DIR}" ]; then
        log_error "Build directory was not created. Site generation failed."
        exit 1
    fi

    log_info "Static site generated in ${BUILD_DIR}"
}

# Step 2: Start Structurizr Lite
start_structurizr_lite() {
    log_info "Step 2: Starting Structurizr Lite on port ${STRUCTURIZR_PORT}..."

    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${STRUCTURIZR_PORT}:8080" \
        -v "${SCRIPT_DIR}:/usr/local/structurizr" \
        structurizr/lite

    log_info "Waiting for Structurizr Lite to be ready..."

    # Wait for Structurizr Lite to be responsive (max 60 seconds)
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s "http://localhost:${STRUCTURIZR_PORT}" > /dev/null 2>&1; then
            log_info "Structurizr Lite is ready."
            # Give it a moment to fully initialize
            sleep 2
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 2
    done

    log_error "Structurizr Lite failed to start within 60 seconds."
    exit 1
}

# Step 3: Export diagrams via Puppeteer
export_diagrams() {
    log_info "Step 3: Exporting diagrams via Puppeteer..."

    # Ensure diagrams directory exists
    mkdir -p "${DIAGRAMS_DIR}"

    # Clear existing diagrams
    rm -f "${DIAGRAMS_DIR}"/*.svg

    # Run Puppeteer export
    cd "${SCRIPT_DIR}"
    node export-diagrams.js \
        "http://localhost:${STRUCTURIZR_PORT}/workspace/diagrams" \
        "${DIAGRAMS_DIR}"

    # Verify exports
    local svg_count=$(ls -1 "${DIAGRAMS_DIR}"/*.svg 2>/dev/null | wc -l)
    if [ "$svg_count" -eq 0 ]; then
        log_error "No SVG files were exported."
        exit 1
    fi

    log_info "Exported ${svg_count} SVG diagrams to ${DIAGRAMS_DIR}"
}

# Step 4: Post-process build
postprocess_build() {
    log_info "Step 4: Post-processing build output..."

    cd "${SCRIPT_DIR}"
    python3 postprocess-build.py "${BUILD_DIR}" "${DIAGRAMS_DIR}"

    log_info "Post-processing complete."
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  Architecture Site Builder"
    echo "========================================"
    echo ""

    check_prerequisites

    generate_site
    start_structurizr_lite
    export_diagrams
    postprocess_build

    # Cleanup is handled by trap
    cleanup

    echo ""
    echo "========================================"
    log_info "Build complete!"
    echo ""
    echo "To view the site:"
    echo "  cd ${BUILD_DIR}"
    echo "  python3 -m http.server 8000"
    echo "  # Open http://localhost:8000"
    echo "========================================"
    echo ""
}

main "$@"
