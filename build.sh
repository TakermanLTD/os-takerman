#!/bin/bash
# Simple Debian ISO Builder for TAKERMAN AI Server

set -e

# Config
ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso"
ISO_NAME="debian-netinst-amd64.iso"
CUSTOM_ISO="TAKERMAN-AI-SERVER.iso"

BUILD_DIR="build"
EXTRACT_DIR="$BUILD_DIR/extracted"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[BUILD]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Check dependencies
log "Checking dependencies..."
for cmd in wget xorriso genisoimage; do
    if ! command -v $cmd &> /dev/null; then
        log "Installing $cmd..."
        sudo apt-get update && sudo apt-get install -y $cmd
    fi
done
success "Dependencies ready"

# Clean and prepare
log "Preparing build directory..."
rm -rf $BUILD_DIR
mkdir -p $EXTRACT_DIR
success "Build directory ready"

# Download ISO
if [ ! -f "$BUILD_DIR/$ISO_NAME" ]; then
    log "Downloading Debian ISO..."
    wget -q --show-progress "$ISO_URL" -O "$BUILD_DIR/$ISO_NAME" || error "Download failed"
    success "ISO downloaded"
else
    success "ISO already exists"
fi

# Extract ISO
log "Extracting ISO..."
sudo mkdir -p /mnt/iso
sudo mount -o loop "$BUILD_DIR/$ISO_NAME" /mnt/iso
cp -rT /mnt/iso $EXTRACT_DIR
sudo umount /mnt/iso
sudo rmdir /mnt/iso
chmod -R +w $EXTRACT_DIR
success "ISO extracted"

# Customize
log "Adding TAKERMAN files..."
cp configs/preseed.cfg $EXTRACT_DIR/
cp setup.sh $EXTRACT_DIR/
cp docker-compose.yml $EXTRACT_DIR/
success "Files added"

# Configure boot
log "Configuring boot menu..."
cat > $EXTRACT_DIR/isolinux/txt.cfg << 'BOOT'
default install
label install
  menu label ^Install TAKERMAN AI Server
  kernel /install.amd/vmlinuz
  append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed.cfg
BOOT
success "Boot menu configured"

# Create ISO
log "Building custom ISO..."
cd $BUILD_DIR
xorriso -as mkisofs \
    -o $CUSTOM_ISO \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    extracted/ 2>&1 | grep -v "^$"

success "ISO created: $BUILD_DIR/$CUSTOM_ISO"
success "Build complete!"

echo ""
log "Next steps:"
echo "  1. Write to USB: sudo dd if=$BUILD_DIR/$CUSTOM_ISO of=/dev/sdX bs=4M status=progress"
echo "  2. Or burn to DVD"
echo "  3. Boot and install"
