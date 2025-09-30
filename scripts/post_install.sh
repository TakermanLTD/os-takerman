#!/bin/bash

# TAKERMAN AI Server Post-Installation Setup
# This runs during the Debian installation process

set -e

log() {
    echo "[TAKERMAN-INSTALL] $1"
}

log "Setting up TAKERMAN AI Server post-installation..."

# Create systemd service for AI setup
cat > /etc/systemd/system/takerman-ai-setup.service << 'EOF'
[Unit]
Description=TAKERMAN AI Server Setup
After=network-online.target multi-user.target
Wants=network-online.target
ConditionPathExists=!/var/lib/takerman-setup-completed

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 30
ExecStart=/tmp/custom-install/ai_setup_debian.sh
ExecStartPost=/bin/touch /var/lib/takerman-setup-completed
StandardOutput=journal
StandardError=journal
RemainAfterExit=yes
Environment=DEBIAN_FRONTEND=noninteractive
TimeoutStartSec=1800

[Install]
WantedBy=multi-user.target
EOF

# Create a wrapper script that handles the setup and cleanup
cat > /tmp/custom-install/takerman_setup_wrapper.sh << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/takerman/ai-setup.log"
mkdir -p /var/log/takerman

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting TAKERMAN AI Server setup at $(date)"

# Run the AI setup script
if /tmp/custom-install/ai_setup_debian.sh; then
    echo "TAKERMAN AI Server setup completed successfully at $(date)"
    # Clean up
    systemctl disable takerman-ai-setup.service
    rm -rf /tmp/custom-install
    
    # Set final hostname
    hostnamectl set-hostname TAKERMAN
    echo "127.0.0.1 TAKERMAN" >> /etc/hosts
else
    echo "TAKERMAN AI Server setup failed at $(date)"
    exit 1
fi
EOF

chmod +x /tmp/custom-install/takerman_setup_wrapper.sh

# Update the service to use the wrapper
sed -i 's|ExecStart=.*|ExecStart=/tmp/custom-install/takerman_setup_wrapper.sh|' /etc/systemd/system/takerman-ai-setup.service

# Configure root account for secure access
# Root home directory setup
mkdir -p /root/.ssh /root/.takerman
chmod 700 /root /root/.ssh /root/.takerman

# Set up Plymouth boot screen
if [ -f "/tmp/custom-install/../branding/setup-plymouth.sh" ]; then
    cp /tmp/custom-install/../branding/setup-plymouth.sh /tmp/
    chmod +x /tmp/setup-plymouth.sh
fi

# Enable the service (will run on next boot)
systemctl enable takerman-ai-setup.service

# Disable unnecessary services for minimal system
systemctl mask bluetooth.service
systemctl mask cups.service  
systemctl mask avahi-daemon.service
systemctl mask ModemManager.service

log "TAKERMAN post-installation setup completed"