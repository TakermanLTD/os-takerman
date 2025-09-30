#!/bin/bash

# Custom Debian ISO Builder
# This script creates a custom Debian ISO with automated AI setup

set -e

# Configuration - Use latest Debian 12 (Bookworm)
DEBIAN_ARCH="amd64"
ISO_NAME="debian-12-netinst-${DEBIAN_ARCH}.iso"
CUSTOM_ISO_NAME="TAKERMAN-AI-SERVER-debian-12-${DEBIAN_ARCH}.iso"
# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_ROOT/build"
WORK_DIR="$BUILD_DIR/work"
ISO_DIR="$BUILD_DIR/iso"
EXTRACT_DIR="$BUILD_DIR/extracted"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log "Checking dependencies..."
    
    local deps=("wget" "genisoimage" "syslinux-utils" "xorriso" "isolinux")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null && ! dpkg -l | grep -q "^ii.*$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log "Installing missing dependencies..."
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}"
    fi
    
    log_success "All dependencies are available"
}

clean_build_dir() {
    log "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$WORK_DIR" "$ISO_DIR" "$EXTRACT_DIR"
    log_success "Build directory prepared"
}

download_debian_iso() {
    log "Downloading latest Debian ISO..."
    
    if [ -f "$BUILD_DIR/$ISO_NAME" ]; then
        log_warning "ISO already exists, skipping download"
        return
    fi
    
    cd "$BUILD_DIR"
    
    # Array of possible Debian ISO URLs to try
    local urls=(
        "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
        "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso" 
        "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
        "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-amd64-netinst.iso"
        "https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/mini.iso"
        "https://cdimage.debian.org/debian-cd/12.8.0/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
        "https://cdimage.debian.org/debian-cd/12.7.0/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
    )
    
    local success=false
    
    for url in "${urls[@]}"; do
        log "Trying: $url"
        
        if wget -c "$url" -O "$ISO_NAME" --timeout=30 --tries=2; then
            success=true
            break
        else
            log_warning "Failed to download from: $url"
            # Clean up partial download
            rm -f "$ISO_NAME"
        fi
    done
    
    if [ "$success" = false ]; then
        log_error "Failed to download Debian ISO from all mirrors"
        log ""
        log "🔧 Manual download options:"
        log "  1. Visit: https://www.debian.org/distrib/netinst"
        log "  2. Download any Debian 12 (Bookworm) netinst ISO"
        log "  3. Place it as: $BUILD_DIR/$ISO_NAME"
        log "  4. Run this script again"
        log ""
        log "📋 Suggested filenames to look for:"
        log "  - debian-12.8.0-amd64-netinst.iso"
        log "  - debian-12.7.0-amd64-netinst.iso" 
        log "  - debian-12.x.x-amd64-netinst.iso"
        exit 1
    fi
    
    # Verify download
    if [ ! -f "$ISO_NAME" ] || [ ! -s "$ISO_NAME" ]; then
        log_error "Download failed or file is empty"
        exit 1
    fi
    
    # Check if it's actually an ISO file (basic check)
    if ! file "$ISO_NAME" | grep -q "ISO 9660\|boot sector"; then
        log_error "Downloaded file doesn't appear to be a valid ISO"
        log "File info: $(file "$ISO_NAME")"
        exit 1
    fi
    
    # Show file size for verification
    local file_size=$(du -h "$ISO_NAME" | cut -f1)
    log_success "Debian ISO downloaded successfully (Size: $file_size)"
}

extract_iso() {
    log "Extracting original ISO..."
    
    cd "$BUILD_DIR"
    
    # Mount the ISO and copy contents
    sudo mkdir -p /mnt/debian-iso
    sudo mount -o loop "$ISO_NAME" /mnt/debian-iso
    
    # Copy all files
    cp -rT /mnt/debian-iso "$EXTRACT_DIR"
    
    # Unmount
    sudo umount /mnt/debian-iso
    sudo rmdir /mnt/debian-iso
    
    # Make files writable
    chmod -R +w "$EXTRACT_DIR"
    
    log_success "ISO extracted successfully"
}

customize_iso() {
    log "Customizing ISO for TAKERMAN AI Server..."
    
    # Copy preseed configuration
    cp "$PROJECT_ROOT/configs/preseed.cfg" "$EXTRACT_DIR/preseed.cfg"
    
    # Create directories in ISO
    mkdir -p "$EXTRACT_DIR/scripts" "$EXTRACT_DIR/branding"
    
    # Copy all custom files
    cp "$PROJECT_ROOT/scripts/"*.sh "$EXTRACT_DIR/scripts/"
    cp "$PROJECT_ROOT/docker-compose.yml" "$EXTRACT_DIR/"
    cp "$PROJECT_ROOT/branding/"* "$EXTRACT_DIR/branding/" 2>/dev/null || true
    
    # Make scripts executable
    chmod +x "$EXTRACT_DIR/scripts/"*.sh
    chmod +x "$EXTRACT_DIR/branding/"*.sh 2>/dev/null || true
    
    # Modify isolinux configuration for automatic installation
    local isolinux_cfg="$EXTRACT_DIR/isolinux/isolinux.cfg"
    
    if [ -f "$isolinux_cfg" ]; then
        # Backup original
        cp "$isolinux_cfg" "$isolinux_cfg.backup"
        
        # Create new configuration
        cat > "$isolinux_cfg" << EOF
default takerman
prompt 0
timeout 30

label takerman
    menu label ^TAKERMAN AI Server (Auto Install)
    kernel /install.amd/vmlinuz
    append vga=788 initrd=/install.amd/initrd.gz auto=true priority=critical preseed/file=/cdrom/preseed.cfg debian-installer/allow_unauthenticated=true quiet splash

label manual
    menu label ^Manual Debian Installation
    kernel /install.amd/vmlinuz
    append vga=788 initrd=/install.amd/initrd.gz

label rescue
    menu label ^Rescue Mode
    kernel /install.amd/vmlinuz
    append vga=788 initrd=/install.amd/initrd.gz rescue/enable=true
EOF
    fi
    
    # Modify GRUB configuration for UEFI boot
    local grub_cfg="$EXTRACT_DIR/boot/grub/grub.cfg"
    
    if [ -f "$grub_cfg" ]; then
        # Backup original
        cp "$grub_cfg" "$grub_cfg.backup"
        
        # Add TAKERMAN automated installation entry at the top
        sed -i '1i\
menuentry "🚀 TAKERMAN AI Server (Auto Install)" {\
    set background_color=black\
    linux    /install.amd/vmlinuz auto=true priority=critical preseed/file=/cdrom/preseed.cfg debian-installer/allow_unauthenticated=true quiet splash ---\
    initrd   /install.amd/initrd.gz\
}\
' "$grub_cfg"
        
        # Set default timeout
        sed -i 's/set timeout=.*/set timeout=10/' "$grub_cfg"
    fi
    
    log_success "ISO customization completed"
}

build_new_iso() {
    log "Building new ISO..."
    
    cd "$BUILD_DIR"
    
    # Check for isolinux files and their actual locations
    log "Checking isolinux structure..."
    find "$EXTRACT_DIR" -name "isolinux.bin" -type f
    find "$EXTRACT_DIR" -name "efi.img" -type f
    
    # Determine the correct isolinux path
    local isolinux_bin_path=""
    local efi_img_path=""
    
    # Find isolinux.bin dynamically
    local isolinux_full_path=$(find "$EXTRACT_DIR" -name "isolinux.bin" -type f | head -1)
    if [ -n "$isolinux_full_path" ]; then
        # Convert full path to relative path from EXTRACT_DIR
        isolinux_bin_path="${isolinux_full_path#$EXTRACT_DIR/}"
        log "Found isolinux.bin at: $isolinux_bin_path"
    else
        log_error "Cannot find isolinux.bin file"
        return 1
    fi
    
    # Find EFI image dynamically
    local efi_full_path=$(find "$EXTRACT_DIR" -name "efi.img" -type f | head -1)
    if [ -n "$efi_full_path" ]; then
        # Convert full path to relative path from EXTRACT_DIR
        efi_img_path="${efi_full_path#$EXTRACT_DIR/}"
        log "Found efi.img at: $efi_img_path"
    else
        log_warning "EFI image not found, will create legacy BIOS only ISO"
    fi
    
    log "Using isolinux path: $isolinux_bin_path"
    log "Using EFI path: $efi_img_path"
    
    # Determine boot catalog path based on isolinux location
    local boot_cat_path="boot.cat"
    if [[ "$isolinux_bin_path" == */* ]]; then
        # isolinux.bin is in a subdirectory, put boot.cat there too
        boot_cat_path="$(dirname "$isolinux_bin_path")/boot.cat"
    fi
    
    log "Using boot catalog path: $boot_cat_path"
    
    # Build ISO with proper paths
    if [ -n "$efi_img_path" ]; then
        # Full UEFI + Legacy BIOS support
        xorriso -as mkisofs \
            -r -V "TAKERMAN_AI_SERVER" \
            -o "$CUSTOM_ISO_NAME" \
            -J -joliet-long \
            -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
            -c "$boot_cat_path" \
            -b "$isolinux_bin_path" \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            -eltorito-alt-boot \
            -e "$efi_img_path" \
            -no-emul-boot \
            -isohybrid-gpt-basdat \
            "$EXTRACT_DIR"
    else
        # Legacy BIOS only
        log_warning "UEFI boot image not found, creating legacy BIOS only ISO"
        xorriso -as mkisofs \
            -r -V "TAKERMAN_AI_SERVER" \
            -o "$CUSTOM_ISO_NAME" \
            -J -joliet-long \
            -c "$boot_cat_path" \
            -b "$isolinux_bin_path" \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            "$EXTRACT_DIR"
    fi
    
    # Check if ISO was created successfully
    if [ -f "$CUSTOM_ISO_NAME" ]; then
        # Make ISO hybrid bootable (works with both CD and USB)
        if command -v isohybrid &> /dev/null; then
            isohybrid "$CUSTOM_ISO_NAME" 2>/dev/null || log_warning "isohybrid failed, but ISO should still work"
        fi
        log_success "Custom ISO built: $CUSTOM_ISO_NAME"
    else
        log_error "Failed to create ISO"
        return 1
    fi
}

generate_checksums() {
    log "Generating checksums..."
    
    cd "$BUILD_DIR"
    
    # Generate MD5 and SHA256 checksums
    md5sum "$CUSTOM_ISO_NAME" > "$CUSTOM_ISO_NAME.md5"
    sha256sum "$CUSTOM_ISO_NAME" > "$CUSTOM_ISO_NAME.sha256"
    
    log_success "Checksums generated"
}

cleanup() {
    log "Cleaning up temporary files..."
    rm -rf "$EXTRACT_DIR" "$WORK_DIR"
    log_success "Cleanup completed"
}

print_summary() {
    log_success "Custom Debian ISO creation completed!"
    echo
    echo -e "${GREEN}Generated files:${NC}"
    echo "  - ISO: $BUILD_DIR/$CUSTOM_ISO_NAME"
    echo "  - MD5: $BUILD_DIR/$CUSTOM_ISO_NAME.md5"
    echo "  - SHA256: $BUILD_DIR/$CUSTOM_ISO_NAME.sha256"
    echo
    echo -e "${YELLOW}Usage:${NC}"
    echo "  1. Burn the ISO to a USB drive or CD"
    echo "  2. Boot from the USB/CD on your target machine"
    echo "  3. The installation will proceed automatically"
    echo "  4. After installation, the AI setup will run on first boot"
    echo
    echo -e "${YELLOW}🔐 TAKERMAN AI Server Access:${NC}"
    echo "  - Username: root"
    echo "  - Password: Hakerman91!"
    echo "  - SSH: Port 22 (enabled)"
    echo "  - Jupyter Lab: http://server-ip:8888"
    echo "  - TensorBoard: http://server-ip:6006"
    echo
    echo -e "${RED}⚠️  SECURITY:${NC} This password is for initial setup only!"
    echo -e "${YELLOW}💡 Tip:${NC} Use 'takstats' for system overview and 'takhelp' for commands"
}

main() {
    log "Starting custom Debian ISO build process..."
    
    check_dependencies
    clean_build_dir
    download_debian_iso
    extract_iso
    customize_iso
    build_new_iso
    generate_checksums
    cleanup
    print_summary
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Check if running as root (not recommended)
if [ "$EUID" -eq 0 ]; then
    log_warning "Running as root is not recommended"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run main function
main "$@"