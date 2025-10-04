#!/bin/bash

# TAKERMAN SSH Configuration Fix
# Run this on your installed TAKERMAN AI Server to enable root SSH on port 22

echo "🔧 Fixing SSH configuration for root access on port 22..."

# Backup current SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Create new SSH configuration
cat > /etc/ssh/sshd_config << 'EOF'
# TAKERMAN AI Server SSH Configuration
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication - Allow root login from anywhere
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes

# Allow connections from anywhere
AllowUsers root

# Security settings
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60

# Disable unused features
X11Forwarding no
AllowTcpForwarding yes
GatewayPorts no
PermitTunnel no

# Logging
SyslogFacility AUTH
LogLevel INFO

# Banner
Banner /etc/ssh/takerman_banner
EOF

# Update firewall to allow SSH on port 22
echo "🔥 Updating firewall rules..."
ufw allow 22/tcp
ufw --force enable

# Remove old port 1991 rule if it exists
ufw delete allow 1991/tcp 2>/dev/null || true

# Restart SSH service
echo "🔄 Restarting SSH service..."
systemctl restart sshd
systemctl enable sshd

# Test SSH configuration
echo "✅ Testing SSH configuration..."
sshd -t
if [ $? -eq 0 ]; then
    echo "✅ SSH configuration is valid!"
else
    echo "❌ SSH configuration error! Restoring backup..."
    cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
    systemctl restart sshd
    exit 1
fi

echo ""
echo "🎉 SSH configuration updated successfully!"
echo ""
echo "📝 You can now connect with:"
echo "   ssh root@$(hostname -I | awk '{print $1}')"
echo ""
echo "🔍 Active SSH settings:"
echo "   Port: 22"
echo "   Root login: Enabled"
echo "   Password auth: Enabled"
echo "   Key auth: Enabled"
echo ""
echo "🛡️  Firewall status:"
ufw status | grep -E "(22/tcp|Status)"