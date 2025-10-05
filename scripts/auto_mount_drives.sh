#!/bin/bash

# TAKERMAN Auto-Mount Script
# Automatically discovers and mounts additional drives in /mnt

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[AUTO-MOUNT]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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

# Function to safely mount a drive
mount_drive() {
    local device="$1"
    local mount_point="$2"
    local filesystem="$3"
    
    # Create mount point if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        mkdir -p "$mount_point"
        log "Created mount point: $mount_point"
    fi
    
    # Check if already mounted
    if mountpoint -q "$mount_point"; then
        log_warning "$mount_point is already mounted"
        return 0
    fi
    
    # Attempt to mount
    if mount -t "$filesystem" "$device" "$mount_point"; then
        log_success "Mounted $device to $mount_point (filesystem: $filesystem)"
        
        # Set appropriate permissions
        chmod 755 "$mount_point"
        
        # Add to fstab for persistent mounting
        if ! grep -q "$device" /etc/fstab; then
            echo "$device $mount_point $filesystem defaults,nofail 0 2" >> /etc/fstab
            log "Added $device to /etc/fstab for persistent mounting"
        fi
        
        return 0
    else
        log_error "Failed to mount $device to $mount_point"
        rmdir "$mount_point" 2>/dev/null || true
        return 1
    fi
}

# Main auto-mount function
auto_mount_drives() {
    log "Scanning for unmounted drives..."
    
    # Create /mnt directory if it doesn't exist
    mkdir -p /mnt
    
    # Get all block devices that are not already mounted and not the root/boot partitions
    local mounted_devices=$(mount | awk '{print $1}' | sort)
    local all_devices=$(lsblk -rno NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT | grep -E "part|disk" | grep -v "SWAP")
    
    local mount_counter=1
    
    while IFS= read -r line; do
        # Parse lsblk output
        local device_name=$(echo "$line" | awk '{print $1}')
        local device_type=$(echo "$line" | awk '{print $2}')
        local filesystem=$(echo "$line" | awk '{print $3}')
        local size=$(echo "$line" | awk '{print $4}')
        local current_mount=$(echo "$line" | awk '{print $5}')
        
        # Skip if no filesystem or already mounted
        if [ -z "$filesystem" ] || [ "$filesystem" = "" ] || [ -n "$current_mount" ]; then
            continue
        fi
        
        # Skip if it's a system partition (root, boot, etc.)
        local full_device="/dev/$device_name"
        if echo "$mounted_devices" | grep -q "^$full_device$"; then
            continue
        fi
        
        # Skip if it's the root device or boot device
        if [[ "$device_name" == *"1" ]] || [[ "$device_name" == *"2" ]] && [[ "$size" < "10G" ]]; then
            log_warning "Skipping $full_device - appears to be system partition ($size)"
            continue
        fi
        
        # Determine mount point name
        local mount_name
        if [ "$device_type" = "disk" ]; then
            mount_name="disk$mount_counter"
        else
            # For partitions, use device name
            mount_name="$device_name"
        fi
        
        local mount_point="/mnt/$mount_name"
        
        log "Found unmounted device: $full_device ($filesystem, $size)"
        
        # Mount the device
        if mount_drive "$full_device" "$mount_point" "$filesystem"; then
            ((mount_counter++))
        fi
        
    done <<< "$all_devices"
    
    # Display mounted drives summary
    log "Auto-mount completed. Current /mnt contents:"
    ls -la /mnt/ 2>/dev/null || log_warning "/mnt directory is empty"
    
    # Show disk usage
    echo
    log "Disk usage summary:"
    df -h | grep -E "/mnt|Filesystem"
}

# Create systemd service for auto-mounting at boot
create_automount_service() {
    log "Creating auto-mount systemd service..."
    
    cat > /etc/systemd/system/takerman-automount.service << 'EOF'
[Unit]
Description=TAKERMAN Auto-Mount Additional Drives
After=local-fs.target
Before=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/takerman-automount
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Copy this script to system location
    cp "$0" /usr/local/bin/takerman-automount 2>/dev/null || true
    chmod +x /usr/local/bin/takerman-automount
    
    # Enable the service
    systemctl daemon-reload
    systemctl enable takerman-automount.service
    
    log_success "Auto-mount service created and enabled"
}

# Main execution
main() {
    log "TAKERMAN Auto-Mount System starting..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Perform auto-mounting
    auto_mount_drives
    
    # Create service if we're being run during setup
    if [ ! -f /etc/systemd/system/takerman-automount.service ]; then
        create_automount_service
    fi
    
    log_success "Auto-mount system ready"
}

# Run main function
main "$@"