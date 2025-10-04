#!/bin/bash

# TAKERMAN AI Server - Save Docker Images for Offline Installation
# This script downloads and saves all required Docker images to tar files

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

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Create output directory
OUTPUT_DIR="./build/docker-images-offline"
mkdir -p "$OUTPUT_DIR"

log "Starting Docker images download and save process..."
log "This may take 30-60 minutes depending on your internet connection"
log "Total download size: ~15-20GB"
echo ""

# List of all Docker images from docker-compose.yml
declare -a IMAGES=(
    "portainer/portainer-ce:latest"
    "amir20/dozzle:latest"
    "ollama/ollama:latest"
    "ghcr.io/takermanltd/takerman.comfyui:latest"
    "ghcr.io/open-webui/open-webui:latest"
    "n8nio/n8n:latest"
    "ghcr.io/takermanltd/takerman.jupyter:latest"
    "grafana/grafana:latest"
    "prom/prometheus:latest"
    "prom/node-exporter:latest"
    "gcr.io/cadvisor/cadvisor:latest"
    "nvidia/cuda:12.0-base-ubuntu20.04"
)

# Counter for progress
TOTAL=${#IMAGES[@]}
CURRENT=0

# Pull and save each image
for IMAGE in "${IMAGES[@]}"; do
    CURRENT=$((CURRENT + 1))
    IMAGE_NAME=$(echo "$IMAGE" | sed 's|/|_|g' | sed 's|:|_|g')
    TAR_FILE="$OUTPUT_DIR/${IMAGE_NAME}.tar"
    
    echo ""
    log "[$CURRENT/$TOTAL] Processing: $IMAGE"
    
    # Pull image
    log "Pulling image..."
    if docker pull "$IMAGE"; then
        log_success "Pull completed"
    else
        log_error "Failed to pull $IMAGE"
        continue
    fi
    
    # Save image
    log "Saving to: ${IMAGE_NAME}.tar"
    if docker save "$IMAGE" -o "$TAR_FILE"; then
        SIZE=$(du -h "$TAR_FILE" | cut -f1)
        log_success "Saved successfully ($SIZE)"
    else
        log_error "Failed to save $IMAGE"
        rm -f "$TAR_FILE"
        continue
    fi
done

echo ""
log "All images saved to: $OUTPUT_DIR"
log "Compressing images into single archive..."

# Compress all tar files
cd "$OUTPUT_DIR"
ARCHIVE_NAME="docker-images-offline.tar.gz"
tar czf "../$ARCHIVE_NAME" *.tar

# Move archive to build directory
mv "../$ARCHIVE_NAME" "../"
cd ../..

# Clean up individual tar files
rm -rf "$OUTPUT_DIR"

# Calculate sizes
ARCHIVE_PATH="./build/docker-images-offline.tar.gz"
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

echo ""
log_success "Docker images offline package created successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Archive Location:${NC} $ARCHIVE_PATH"
echo -e "${GREEN}Archive Size:${NC} $ARCHIVE_SIZE"
echo -e "${GREEN}Images Included:${NC} $TOTAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Next Steps:"
echo "1. Copy the archive to your offline machine via USB/network"
echo "2. Run: bash docker/load_images_offline.sh"
echo "3. Start services: cd /root/server && docker compose up -d"
echo ""

# Create checksum
cd build
sha256sum docker-images-offline.tar.gz > docker-images-offline.tar.gz.sha256
log_success "Checksum created: docker-images-offline.tar.gz.sha256"

echo ""
log "To verify the archive on the target machine:"
echo "  sha256sum -c docker-images-offline.tar.gz.sha256"
echo ""
