#!/bin/bash

# TAKERMAN AI SERVER - Minimal Debian Setup Script
# High-performance AI server configuration with NVIDIA GPU support

set -e  # Exit on any error

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\0# Password was set during installation - no first boot change needed
# User already chose their secure password during the installation process

# Show system stats on login='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# TAKERMAN branded logging
log() {
    echo -e "${CYAN}[TAKERMAN AI]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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

# Display TAKERMAN ASCII art
show_takerman_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
 ████████╗ █████╗ ██╗  ██╗███████╗██████╗ ███╗   ███╗ █████╗ ███╗   ██╗
 ╚══██╔══╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗████╗ ████║██╔══██╗████╗  ██║
    ██║   ███████║█████╔╝ █████╗  ██████╔╝██╔████╔██║███████║██╔██╗ ██║
    ██║   ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║
    ██║   ██║  ██║██║  ██╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║
    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                           
                        🚀 AI SERVER INITIALIZATION 🚀
                         https://takerman.net/projects/os
EOF
    echo -e "${NC}"
    sleep 3
}

show_takerman_banner
log "Initializing TAKERMAN AI Server..."

# 1. System preparation
log "Preparing minimal AI server environment..."
mkdir -p /etc/apt/keyrings /root/.config /root/.takerman /var/log/takerman
chmod 700 /root /root/.takerman

# 2. Repository setup and minimal package installation
log "Configuring repositories for AI server components..."

# Add Docker repository (latest version)
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Add NVIDIA Container Toolkit repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
echo "deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/$(dpkg --print-architecture) /" | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Enable non-free repositories for NVIDIA drivers
sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list

# Update package lists
apt-get update

log "Installing essential server packages for AI workloads..."

# Core system packages (organized by category)
CORE_PACKAGES=(
    # SSH and remote access
    "openssh-server"
    
    # Essential utilities
    "curl" "wget" "git" "rsync" "sudo"
    
    # Text editors and file management
    "vim" "nano" "tree" "less" "mc"
    
    # Archive and compression
    "zip" "unzip"
    
    # Python environment (required for AI)
    "python3" "python3-pip" "python3-venv"
    
    # Security and firewall
    "ufw" "fail2ban"
)

# Networking and monitoring tools (useful for server management)
NETWORK_PACKAGES=(
    # Network utilities (including netstat in net-tools)
    "net-tools" "iputils-ping" "traceroute" "dnsutils"
    "nmap" "netcat-openbsd" "tcpdump"
    
    # System monitoring
    "htop" "iotop" "iftop" "lm-sensors" "smartmontools"
    
    # Performance testing
    "iperf3"
)

# Development and debugging tools
DEV_PACKAGES=(
    # Terminal multiplexers
    "screen" "tmux"
    
    # System utilities
    "bash-completion" "man-db" "locate"
    "psmisc" "procps" "lsof" "strace"
    
    # File and network tools
    "file" "whois" "openssl"
)

# Combine all essential packages
ESSENTIAL_PACKAGES=("${CORE_PACKAGES[@]}" "${NETWORK_PACKAGES[@]}" "${DEV_PACKAGES[@]}")

# Check and install missing packages
MISSING_PACKAGES=()
for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        MISSING_PACKAGES+=("$package")
    fi
done

# Create APT preferences to prevent unwanted packages
log "Configuring package preferences to prevent desktop packages..."
cat > /etc/apt/preferences.d/no-desktop << 'EOF'
# Prevent installation of desktop environment packages
Package: libreoffice* gnome* kde* xfce* lxde* mate* cinnamon* x11-common xorg*
Pin: version *
Pin-Priority: -1

# Prevent games and multimedia packages
Package: games-* *-games *game* vlc* totem* rhythmbox* 
Pin: version *
Pin-Priority: -1

# Prevent documentation packages that are large
Package: *-doc-* doc-*
Pin: version *
Pin-Priority: -1
EOF

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    log "Installing missing packages: ${MISSING_PACKAGES[*]}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${MISSING_PACKAGES[@]}"
else
    log_success "All essential packages are already installed"
fi

# Install Docker packages (essential for AI services)
log "Installing Docker and container tools..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install additional tools that might not be in preseed
log "Installing additional tools..."
ADDITIONAL_PACKAGES=(
    "rclone" "timeshift" "nvtop" "pyenv"
    "openvpn" "easy-rsa" 
    "telnet" "ftp" "ncftp" "lftp"
)

for package in "${ADDITIONAL_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        log "Installing $package..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$package" 2>/dev/null || log_warning "Package $package not available in repos, will install later"
    fi
done

# AI/ML Python packages will be installed in containers, not on host system
log "Host system setup completed - AI/ML tools will run in containers"

# Configure ClamAV antivirus
log "Configuring ClamAV antivirus system..."
systemctl stop clamav-daemon 2>/dev/null || true
systemctl stop clamav-freshclam 2>/dev/null || true

# Update virus definitions
log "Updating ClamAV virus definitions..."
freshclam

# Configure ClamAV daemon
cat > /etc/clamav/clamd.conf << 'EOF'
LogFile /var/log/clamav/clamav.log
LogTime true
LogClean false
LogSyslog false
LogFacility LOG_LOCAL6
LogVerbose false
ExtendedDetectionInfo true
PidFile /var/run/clamav/clamd.pid
LocalSocket /var/run/clamav/clamd.ctl
LocalSocketGroup clamav
LocalSocketMode 666
FixStaleSocket true
TCPSocket 3310
TCPAddr 127.0.0.1
MaxConnectionQueueLength 15
StreamMaxLength 25M
MaxThreads 12
ReadTimeout 180
CommandReadTimeout 30
SendBufTimeout 200
MaxQueue 100
IdleTimeout 30
ExcludePath ^/proc/
ExcludePath ^/sys/
ExcludePath ^/dev/
ExcludePath ^/run/
ExcludePath ^/var/lib/docker/
User clamav
ScanMail true
ScanArchive true
ArchiveBlockEncrypted false
ScanPE true
ScanELF true
ScanOLE2 true
ScanPDF true
ScanSWF true
ScanHTML true
MaxScanSize 100M
MaxFileSize 25M
MaxRecursion 16
MaxFiles 10000
MaxEmbeddedPE 10M
MaxHTMLNormalize 10M
MaxHTMLNoTags 2M
MaxScriptNormalize 5M
MaxZipTypeRcg 1M
SelfCheck 3600
Foreground false
Debug false
ScanOnAccess false
OnAccessMaxFileSize 5M
CrossFilesystems true
FollowDirectorySymlinks false
FollowFileSymlinks false
EOF

# Configure freshclam for automatic updates
cat > /etc/clamav/freshclam.conf << 'EOF'
DatabaseOwner clamav
UpdateLogFile /var/log/clamav/freshclam.log
LogVerbose false
LogSyslog false
LogFacility LOG_LOCAL6
LogFileMaxSize 0
LogRotate true
LogTime true
Foreground false
Debug false
MaxAttempts 5
DatabaseDirectory /var/lib/clamav
DNSDatabaseInfo current.cvd.clamav.net
ConnectTimeout 30
ReceiveTimeout 0
TestDatabases yes
ScriptedUpdates yes
CompressLocalDatabase no
Bytecode true
NotifyClamd /etc/clamav/clamd.conf
Checks 24
DatabaseMirror db.local.clamav.net
DatabaseMirror database.clamav.net
EOF

# Set up ClamAV services
systemctl enable clamav-daemon
systemctl enable clamav-freshclam
systemctl start clamav-freshclam
sleep 5
systemctl start clamav-daemon

# Create daily scan script
cat > /usr/local/bin/takerman-clamscan << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/takerman/clamav-scan.log"
mkdir -p /var/log/takerman

echo "$(date): Starting daily ClamAV scan..." >> $LOG_FILE
clamscan -r --bell -i /home /opt /usr/local/bin /etc --log=$LOG_FILE
echo "$(date): Daily ClamAV scan completed" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/takerman-clamscan

# Set up daily scan cron job
echo "0 2 * * * root /usr/local/bin/takerman-clamscan" >> /etc/crontab

log_success "ClamAV antivirus configured and enabled"

# Remove snapd and prevent installation
log "Removing snapd and blocking snap packages..."
systemctl stop snapd 2>/dev/null || true
systemctl disable snapd 2>/dev/null || true
apt-get remove --purge -y snapd 2>/dev/null || true

# Block snapd from being installed
cat > /etc/apt/preferences.d/no-snap << 'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# Clean up any unwanted packages that may have been installed
log "Cleaning up unwanted packages..."
UNWANTED_PACKAGES=(
    libreoffice-common libreoffice-core libreoffice-writer libreoffice-calc
    gnome-core kde-plasma-desktop xfce4 lxde-core mate-desktop-environment
    games-* *-games firefox-esr chromium
    vlc totem rhythmbox snapd
)

for package in "${UNWANTED_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package"; then
        log_warning "Removing unwanted package: $package"
        apt-get remove --purge -y "$package" 2>/dev/null || true
    fi
done

# Clean up package cache and orphaned packages
apt-get autoremove -y
apt-get autoclean

# Set up auto-mount system for additional drives
log "Setting up automatic drive mounting..."
if [ -f "/tmp/custom-install/auto_mount_drives.sh" ]; then
    cp /tmp/custom-install/auto_mount_drives.sh /usr/local/bin/takerman-automount
    chmod +x /usr/local/bin/takerman-automount
    /usr/local/bin/takerman-automount
    log_success "Auto-mount system configured"
fi

git clone https://github.com/TakermanLTD/os-takerman.git /root/server

# Install latest Docker Compose if not available
if ! docker compose version &> /dev/null; then
    log "Installing latest Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 3. System configuration
log "Configuring TAKERMAN AI Server environment..."

# 3.1 Create TAKERMAN aliases and functions
log "Setting up TAKERMAN command aliases..."

# Add aliases directly to ~/.bashrc
cat >> /root/.bashrc << 'EOF'

# TAKERMAN AI Server Aliases
# GPU and AI Management (Universal)
alias takgpu='/usr/local/bin/takgpu'
alias takgpuwatch='watch -n 1 /usr/local/bin/takgpu'
alias takgpustats='takgpu'
alias takgputemp='/usr/local/bin/takgputemp'

# Docker Management
alias takdocker='docker'
alias takps='docker ps'
alias takpsa='docker ps -a'
alias takimages='docker images'
alias takstop='docker stop $(docker ps -q)'
alias takclean='docker system prune -f'
alias takcompose='docker-compose'
alias takup='docker-compose up -d'
alias takdown='docker-compose down'
alias taklogs='docker-compose logs -f'
alias takservices='/root/takerman_services.sh'
alias takgpusetup='/root/setup_universal_gpu.sh'
alias takgpureset='/root/reset_gpu.sh'

# System Monitoring
alias takstats='takerman-stats'
alias taktop='htop'
alias takiot='iotop'
alias taknet='iftop'
alias taktemp='sensors'
alias takdisk='df -h'
alias takmem='free -h'
alias takcpu='lscpu'

# Network and Security  
alias takports='netstat -tulpn'
alias takfw='ufw status'
alias takfail='fail2ban-client status'
alias takssh='systemctl status sshd'

# System Control
alias takreboot='systemctl reboot'
alias takshutdown='systemctl poweroff'
alias takservices='systemctl list-units --type=service --state=running'
alias takupdate='apt update && apt upgrade -y'

# Useful shortcuts
alias taklog='tail -f /var/log/takerman/ai-server.log'

# System Information
alias takpkgs='dpkg -l | grep "^ii" | wc -l; echo "packages installed"'
alias taksize='du -sh / --exclude=/proc --exclude=/sys --exclude=/dev 2>/dev/null | head -1'
alias takerror='journalctl -f -p err'
alias takconfig='cd /root/.takerman'

# Auto-mount alias
alias takmount='/usr/local/bin/takerman-automount'

# ClamAV aliases
alias takscan='/usr/local/bin/takerman-clamscan'
alias takavirus='tail -f /var/log/takerman/clamav-scan.log'

# Enhanced ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

# 3.2 Create system stats dashboard
log "Creating TAKERMAN system dashboard..."
cat > /usr/local/bin/takerman-stats << 'EOF'
#!/bin/bash

# TAKERMAN AI Server System Statistics Dashboard
clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}                    ${WHITE}🚀 TAKERMAN AI SERVER 🚀${NC}                    ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}                     ${CYAN}https://takerman.net${NC}                      ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"

# System Info
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
KERNEL=$(uname -r)
echo -e "${PURPLE}║${NC} ${YELLOW}Hostname:${NC} $HOSTNAME"
echo -e "${PURPLE}║${NC} ${YELLOW}Uptime:${NC} $UPTIME"
echo -e "${PURPLE}║${NC} ${YELLOW}Kernel:${NC} $KERNEL"

# CPU Info
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} ${GREEN}CPU:${NC} $CPU_MODEL"
echo -e "${PURPLE}║${NC} ${GREEN}Cores:${NC} $CPU_CORES | ${GREEN}Usage:${NC} ${CPU_USAGE}%"

# Memory Info
MEM_INFO=$(free -h | grep "Mem:")
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_FREE=$(echo $MEM_INFO | awk '{print $4}')
echo -e "${PURPLE}║${NC} ${BLUE}Memory:${NC} ${MEM_USED}/${MEM_TOTAL} used | ${MEM_FREE} free"

# GPU Info
if command -v nvidia-smi &> /dev/null; then
    GPU_COUNT=$(nvidia-smi -L | wc -l)
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -1)
    GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -1)
    GPU_MEM=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -1)
    echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC} ${RED}GPU:${NC} $GPU_NAME (${GPU_COUNT} GPU(s))"
    echo -e "${PURPLE}║${NC} ${RED}Temperature:${NC} ${GPU_TEMP}°C | ${RED}Usage:${NC} ${GPU_USAGE}%"
    echo -e "${PURPLE}║${NC} ${RED}VRAM:${NC} $GPU_MEM"
fi

# Disk Info
DISK_USAGE=$(df -h / | tail -1)
DISK_USED=$(echo $DISK_USAGE | awk '{print $3}')
DISK_TOTAL=$(echo $DISK_USAGE | awk '{print $2}')
DISK_PERCENT=$(echo $DISK_USAGE | awk '{print $5}')
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} ${CYAN}Disk Usage:${NC} ${DISK_USED}/${DISK_TOTAL} (${DISK_PERCENT})"

# Network Info
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo -e "${PURPLE}║${NC} ${WHITE}IP Address:${NC} $IP_ADDRESS"

# Docker Info
if command -v docker &> /dev/null; then
    DOCKER_CONTAINERS=$(docker ps -q | wc -l)
    DOCKER_IMAGES=$(docker images -q | wc -l)
    echo -e "${PURPLE}║${NC} ${GREEN}Docker:${NC} $DOCKER_CONTAINERS containers, $DOCKER_IMAGES images"
fi

echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}💡 Tip: Use 'tak' prefixed commands for AI server management${NC}"
echo -e "${CYAN}   Examples: takgpu, takstats, takdocker, takup, takclean${NC}"
echo ""
EOF

chmod +x /usr/local/bin/takerman-stats

# 3.3 Configure custom root bashrc
log "Setting up TAKERMAN shell environment..."

# Update .bashrc with TAKERMAN customizations (aliases already added above)
cat >> /root/.bashrc << 'EOF'

# TAKERMAN AI Server Root Shell Configuration
# Colors for prompt
export PS1='\[\033[01;35m\][\[\033[01;37m\]TAKERMAN\[\033[01;35m\]]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Environment variables
export EDITOR=nano
export TERM=xterm-256color
export HISTSIZE=10000
export HISTFILESIZE=10000
export PATH="/usr/local/bin:$PATH"

# CUDA environment
export CUDA_VISIBLE_DEVICES=all
export NVIDIA_VISIBLE_DEVICES=all

# Force password change on first login if still using default
if [ -f "/var/lib/takerman-password-change-needed" ]; then
    echo -e "\033[1;31m⚠️  SECURITY ALERT: You must change the default password now!\033[0m"
    echo -e "\033[1;33mEnter a new secure password for root account:\033[0m"
    if passwd root; then
        rm -f /var/lib/takerman-password-change-needed
        echo -e "\033[1;32m✅ Password changed successfully!\033[0m"
    else
        echo -e "\033[1;31m❌ Password change failed. You will be prompted again on next login.\033[0m"
    fi
    echo
fi

# Show system stats on login
if [ -t 0 ] && [ -z "$TAKERMAN_STATS_SHOWN" ]; then
    export TAKERMAN_STATS_SHOWN=1
    takerman-stats
fi

# Useful functions
function takhelp() {
    echo -e "\033[1;35m=== TAKERMAN AI SERVER COMMANDS ===\033[0m"
    echo -e "\033[1;32mGPU Management:\033[0m"
    echo "  takgpu, takgpuwatch, takgpustats, taknvtop"
    echo -e "\033[1;32mDocker Management:\033[0m"  
    echo "  takdocker, takps, takimages, takup, takdown, taklogs"
    echo -e "\033[1;32mSystem Monitoring:\033[0m"
    echo "  takstats, taktop, takiot, taknet, taktemp, takdisk"
    echo -e "\033[1;32mSecurity & Network:\033[0m"
    echo "  takports, takfw, takfail, takssh"
    echo -e "\033[1;32mSystem Control:\033[0m"
    echo "  takreboot, takshutdown, takservices, takupdate"
}

function takquick() {
    echo "🚀 TAKERMAN AI Server Quick Status:"
    echo "GPU: $(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu --format=csv,noheader,nounits | head -1)"
    echo "Docker: $(docker ps -q | wc -l) containers running"
    echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo "Uptime: $(uptime -p)"
}
EOF

# 3.4 Configure Docker (GPU setup will be done separately)
log "Configuring Docker daemon..."

# Create basic Docker daemon configuration (GPU will be added by universal GPU setup)
cat > /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "live-restore": true,
    "userland-proxy": false,
    "experimental": false,
    "metrics-addr": "0.0.0.0:9323",
    "default-ulimits": {
        "nofile": {
            "Hard": 64000,
            "Name": "nofile",
            "Soft": 64000
        }
    }
}
EOF

systemctl enable docker
systemctl restart docker

# Run universal GPU detection and setup
log "Running universal GPU detection and setup..."
if [ -f "/tmp/custom-install/setup_universal_gpu.sh" ]; then
    chmod +x /tmp/custom-install/setup_universal_gpu.sh
    /tmp/custom-install/setup_universal_gpu.sh
else
    log_warning "Universal GPU setup script not found - GPU support may be limited"
fi

# 3.5 Configure secure SSH for root access
log "Configuring SSH security with Hakerman91! password..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Create SSH configuration for security
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
#AllowGroups ssh

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

# Create SSH banner
cat > /etc/ssh/takerman_banner << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    🚀 TAKERMAN AI SERVER 🚀                  ║
║                     https://takerman.net                     ║
║                                                              ║
║  ⚠️  WARNING: Authorized access only!                        ║
║     All activities are monitored and logged.                ║
╚══════════════════════════════════════════════════════════════╝
EOF

systemctl restart sshd
systemctl enable sshd

# 3.6 Configure Git for TAKERMAN
log "Setting up Git configuration..."
git config --global user.name "takerman"
git config --global user.email "tivanov@takerman.net"
git config --global init.defaultBranch main

# 3.7 Set up OpenVPN server
log "Configuring OpenVPN server..."
mkdir -p /etc/openvpn/{server,client,easy-rsa}

# Create OpenVPN server configuration template
cat > /etc/openvpn/server/takerman.conf << 'EOF'
# TAKERMAN AI Server OpenVPN Configuration
port 5194
proto udp
dev tun
ca ca.crt
cert takerman-server.crt
key takerman-server.key
dh dh.pem
auth SHA512
tls-crypt tc.key
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
verb 3
crl-verify crl.pem
explicit-exit-notify
EOF

# 3.8 Configure enhanced firewall with fail2ban
log "Setting up advanced security..."
ufw --force enable
ufw allow 22/tcp        # SSH
ufw allow 443/tcp      # HTTPS  
ufw allow 80/tcp       # HTTP (for nginx proxy)
ufw allow 5194/udp     # OpenVPN
ufw allow 81/tcp       # Nginx Proxy Manager
ufw allow 8050/tcp     # Dozzle logs
ufw allow 8088/tcp     # Service Publish API
ufw allow 5100/tcp     # ComfyUI
ufw allow 5101/tcp     # Ollama
ufw allow 5102/tcp     # OpenWebUI
ufw allow 5103/tcp     # N8N
ufw allow 5104/tcp     # Jupyter
ufw allow 9443/tcp     # Portainer
ufw deny 23/tcp        # Telnet
ufw deny 135/tcp       # RPC

# Configure fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Verify critical services are installed and running
log "Verifying critical system services..."

# Check UFW
if command -v ufw >/dev/null 2>&1; then
    log_success "UFW firewall is installed"
    ufw status
else
    log_error "UFW not found - installing now"
    apt-get update && apt-get install -y ufw
    ufw --force enable
fi

# Check fail2ban
if systemctl is-active --quiet fail2ban; then
    log_success "fail2ban is running"
else
    log_warning "fail2ban not running - attempting to start"
    systemctl enable fail2ban
    systemctl start fail2ban
fi

# Check Docker
if command -v docker >/dev/null 2>&1; then
    log_success "Docker is installed"
    systemctl enable docker
    systemctl start docker
else
    log_error "Docker not found - this is critical!"
fi

# Check GPU drivers (universal)
if command -v nvidia-smi >/dev/null 2>&1; then
    log_success "NVIDIA GPU drivers detected"
elif command -v radeontop >/dev/null 2>&1; then
    log_success "AMD GPU drivers detected"
elif command -v intel_gpu_top >/dev/null 2>&1; then
    log_success "Intel GPU tools detected"
else
    log_warning "No GPU-specific tools found - using integrated/basic graphics"
fi

# Check SSH
if systemctl is-active --quiet ssh; then
    log_success "SSH service is running"
else
    log_warning "SSH not running - attempting to start"
    systemctl enable ssh
    systemctl start ssh
fi

# 3.9 Create AI workspace directories (containers will handle volume creation)
log "Setting up base directories for Docker volumes..."
mkdir -p /root/volumes
chmod -R 755 /root/volumes

# Copy Docker Compose templates and configurations
log "Setting up Docker Compose configurations..."

# Create docker directory
mkdir -p /root/docker

# Copy all GPU-specific Docker Compose templates
if [ -d "/root/server/docker" ]; then
    cp -r /root/server/docker/* /root/docker/
    log "Copied GPU-specific Docker Compose templates"
fi

# Copy the main docker-compose.yml (will be replaced by GPU setup)
if [ -f "/root/server/docker-compose.yml" ]; then
    cp /root/server/docker-compose.yml /root/docker-compose.yml
    log_success "Docker Compose configuration ready (will be updated for detected GPU)"
else
    log_warning "Docker Compose file not found in server repo"
fi

# Copy service management script
if [ -f "/tmp/custom-install/takerman_services.sh" ]; then
    cp /tmp/custom-install/takerman_services.sh /root/takerman_services.sh
    chmod +x /root/takerman_services.sh
    log_success "TAKERMAN services management script ready"
fi

# Copy GPU management scripts
if [ -f "/tmp/custom-install/setup_universal_gpu.sh" ]; then
    cp /tmp/custom-install/setup_universal_gpu.sh /root/setup_universal_gpu.sh
    chmod +x /root/setup_universal_gpu.sh
    log_success "Universal GPU setup script ready"
fi

if [ -f "/tmp/custom-install/reset_gpu.sh" ]; then
    cp /tmp/custom-install/reset_gpu.sh /root/reset_gpu.sh
    chmod +x /root/reset_gpu.sh
    log_success "GPU reset script ready"
fi

# 4. System optimization for AI workloads
log "Optimizing system for AI performance..."

# Increase shared memory for large models
echo 'tmpfs /dev/shm tmpfs defaults,size=8G 0 0' >> /etc/fstab

# GPU performance settings will be handled by universal GPU setup

# Create service to auto-start Docker containers on boot
log "Creating Docker auto-start service..."
cat > /etc/systemd/system/takerman-docker-start.service << 'EOF'
[Unit]
Description=TAKERMAN Docker Services Auto-Start
After=docker.service
Requires=docker.service
ConditionPathExists=/root/docker-compose.yml

[Service]
Type=oneshot
User=root
WorkingDirectory=/root
ExecStartPre=/bin/sleep 30
ExecStart=/usr/bin/docker compose up -d
RemainAfterExit=yes
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl enable takerman-docker-start.service

# 5. Final system configuration
log "Finalizing TAKERMAN AI Server setup..."

# Set system timezone
timedatectl set-timezone UTC

# Enable automatic updates for security
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# No longer needed - user sets password during installation
# touch /var/lib/takerman-password-change-needed

# Create startup log
echo "TAKERMAN AI Server initialized at $(date)" >> /var/log/takerman/ai-server.log
chmod 644 /var/log/takerman/ai-server.log

# Start Docker services
log "Starting TAKERMAN AI Docker services..."

# GPU setup and Docker Compose configuration is handled by universal GPU detection
# The docker-compose.yml will be replaced by the GPU-specific version automatically
log "Docker Compose will be configured based on detected GPU hardware"

# Check if we have the docker-compose file
if [ -f "/root/docker-compose.yml" ]; then
    log "Found docker-compose.yml, starting services..."
    cd /root
    
    # Wait for Docker to be fully ready
    log "Waiting for Docker daemon to be ready..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker info >/dev/null 2>&1; then
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon is ready"
        
        # Create volume directories
        log "Creating volume directories..."
        mkdir -p /root/volumes/{devops,monitoring,ai}
        mkdir -p /root/volumes/devops/{portainer,nginx-proxy-manager/{data,letsencrypt}}
        mkdir -p /root/volumes/monitoring/dozzle
        mkdir -p /root/volumes/ai/{generated/{videos/generated,pictures/artificialpics},ollama,comfyui/{models,output,input,custom_nodes,config},openwebui,n8n/{data,local_files,backups/{daily,weekly,monthly,emergency}},jupyter/{notebooks,models,config}}
        
        # Start essential services first
        log "Starting essential infrastructure services..."
        if docker compose up -d devops_portainer monitoring_dozzle 2>/dev/null; then
            log_success "Infrastructure services started"
        else
            log_warning "Some infrastructure services failed to start"
        fi
        
        # Wait a moment for infrastructure
        sleep 5
        
        # Start AI services
        log "Starting AI services..."
        if docker compose up -d ai_ollama ai_comfyui ai_openwebui tool_jupyter 2>/dev/null; then
            log_success "AI services started"
        else
            log_warning "Some AI services failed to start"
        fi
        
        # Show running containers
        log "Docker services status:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
    else
        log_warning "Docker daemon not ready, services will need to be started manually"
        log "Run 'docker compose up -d' in /root directory after reboot"
    fi
else
    log_warning "docker-compose.yml not found, services will need to be started manually"
fi

# Also run the dedicated startup script if available
if [ -f "/root/server/scripts/start_docker_services.sh" ]; then
    log "Running additional Docker services script..."
    chmod +x /root/server/scripts/start_docker_services.sh
    /root/server/scripts/start_docker_services.sh || log_warning "Additional Docker services script had issues"
fi

# Create symbolic links for key TAKERMAN commands to ensure they work as actual commands
log "Creating TAKERMAN command links..."
mkdir -p /usr/local/bin

# Create wrapper scripts for key commands
cat > /usr/local/bin/takstats << 'EOF'
#!/bin/bash
/usr/local/bin/takerman-stats "$@"
EOF

cat > /usr/local/bin/takgpu << 'EOF'
#!/bin/bash
# Universal GPU monitoring - will be overwritten by GPU setup script
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi "$@"
else
    echo "GPU monitoring not yet configured"
    lspci | grep -i "vga\|3d\|display"
fi
EOF

cat > /usr/local/bin/takdocker << 'EOF'
#!/bin/bash
docker "$@"
EOF

cat > /usr/local/bin/takps << 'EOF'
#!/bin/bash
docker ps "$@"
EOF

cat > /usr/local/bin/takhelp << 'EOF'
#!/bin/bash
source /root/.takerman_aliases 2>/dev/null
takhelp "$@"
EOF

# Make them executable
chmod +x /usr/local/bin/tak*

log_success "TAKERMAN commands are now available system-wide"

log_success "🎉 TAKERMAN AI Server setup completed successfully!"
log "🔥 System is ready for high-performance AI workloads!"
log "🚀 All Docker services are starting up!"
log ""
log "📊 Access your services:"
log "   SSH: ssh root@<server-ip>"
log "   Jupyter: http://<server-ip>:5104 (Token: Hakerman91!)"
log "   ComfyUI: http://<server-ip>:5100"
log "   Open WebUI: http://<server-ip>:5102"
log "   N8N: http://<server-ip>:5103 (takerman/Hakerman91!)"
log "   Portainer: https://<server-ip>:9443"
log ""
log "💡 Use 'takhelp' for available commands"
log "📈 Use 'takstats' for system overview"