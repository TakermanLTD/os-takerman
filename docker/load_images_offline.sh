#!/bin/bash

# TAKERMAN AI Server - Load Docker Images from Offline Archive
# This script loads pre-downloaded Docker images on an offline/air-gapped system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[DOCKER OFFLINE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker daemon is running
if ! docker ps &> /dev/null; then
    log_error "Docker daemon is not running. Start Docker first:"
    echo "  systemctl start docker"
    exit 1
fi

# Find the archive
ARCHIVE_PATH=""
if [ -f "./build/docker-images-offline.tar.gz" ]; then
    ARCHIVE_PATH="./build/docker-images-offline.tar.gz"
elif [ -f "./docker-images-offline.tar.gz" ]; then
    ARCHIVE_PATH="./docker-images-offline.tar.gz"
elif [ -f "/tmp/docker-images-offline.tar.gz" ]; then
    ARCHIVE_PATH="/tmp/docker-images-offline.tar.gz"
else
    log_error "Docker images archive not found!"
    echo ""
    echo "Please ensure docker-images-offline.tar.gz is in one of these locations:"
    echo "  - ./build/docker-images-offline.tar.gz"
    echo "  - ./docker-images-offline.tar.gz"
    echo "  - /tmp/docker-images-offline.tar.gz"
    echo ""
    echo "Or specify the path as an argument:"
    echo "  bash $0 /path/to/docker-images-offline.tar.gz"
    exit 1
fi

# Allow custom path as argument
if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        ARCHIVE_PATH="$1"
    else
        log_error "Specified file not found: $1"
        exit 1
    fi
fi

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

echo ""
log "Found archive: $ARCHIVE_PATH ($ARCHIVE_SIZE)"

# Verify checksum if available
CHECKSUM_FILE="${ARCHIVE_PATH}.sha256"
if [ -f "$CHECKSUM_FILE" ]; then
    log "Verifying archive integrity..."
    if sha256sum -c "$CHECKSUM_FILE" &> /dev/null; then
        log_success "Archive integrity verified"
    else
        log_warning "Checksum verification failed. Proceeding anyway..."
    fi
else
    log_warning "No checksum file found. Skipping verification."
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

log "Extracting archive to temporary directory..."
tar xzf "$ARCHIVE_PATH" -C "$TEMP_DIR"

# Count tar files
TAR_COUNT=$(find "$TEMP_DIR" -name "*.tar" | wc -l)
log "Found $TAR_COUNT Docker images to load"

echo ""
log "Loading Docker images (this may take 10-20 minutes)..."

# Counter
CURRENT=0
FAILED=0
SUCCESS=0

# Load each tar file
for TAR_FILE in "$TEMP_DIR"/*.tar; do
    CURRENT=$((CURRENT + 1))
    BASENAME=$(basename "$TAR_FILE" .tar)
    
    echo ""
    log "[$CURRENT/$TAR_COUNT] Loading: $BASENAME"
    
    if docker load -i "$TAR_FILE"; then
        SUCCESS=$((SUCCESS + 1))
        log_success "Loaded successfully"
    else
        FAILED=$((FAILED + 1))
        log_error "Failed to load"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Load Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Successful:${NC} $SUCCESS images"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Failed:${NC} $FAILED images"
fi
echo ""

# Show loaded images
log "Verifying loaded images..."
echo ""
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(REPOSITORY|takerman|ollama|portainer|dozzle|n8n|grafana|prometheus|nvidia|openwebui)"

echo ""
log_success "All Docker images loaded successfully!"
echo ""
echo "📦 Next Steps:"
echo "1. Navigate to server directory: cd /root/server"
echo "2. Start services: docker compose up -d"
echo "3. Check status: docker ps"
echo "4. View dashboard: takstats"
echo ""
echo "🌐 Service URLs (after starting):"
echo "  - Jupyter Lab:  http://$(hostname -I | awk '{print $1}'):8888"
echo "  - ComfyUI:      http://$(hostname -I | awk '{print $1}'):8188"
echo "  - Grafana:      http://$(hostname -I | awk '{print $1}'):3001"
echo "  - Portainer:    https://$(hostname -I | awk '{print $1}'):9443"
echo "  - N8N:          http://$(hostname -I | awk '{print $1}'):5103"
echo ""
