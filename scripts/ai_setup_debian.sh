#!/bin/bash

# TAKERMAN AI SERVER - Minimal Debian Setup Script
# High-performance AI server configuration with NVIDIA GPU support

set -e  # Exit on any error

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\0# Run first boot setup if needed (interactive password change)
if [ -f "/var/lib/takerman-password-change-needed" ] && [ -t 0 ]; then
    # Source the first boot setup functions
    if [ -f "/root/.takerman/first_boot_setup.sh" ]; then
        source /root/.takerman/first_boot_setup.sh
        force_password_change
    else
        echo -e "\\033[1;31m⚠️  SECURITY: Please change default password with 'passwd root'\\033[0m"
    fi
fi

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

log "Installing minimal AI server packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server curl wget git htop nvtop iotop \
    python3 python3-pip python3-venv \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    nvidia-driver nvidia-settings nvidia-smi nvidia-container-toolkit \
    ufw fail2ban \
    vim nano screen tmux tree \
    net-tools iperf3 \
    lm-sensors smartmontools

# Install OpenVPN
log "Installing OpenVPN server..."
DEBIAN_FRONTEND=noninteractive apt-get install -y openvpn easy-rsa

# Install additional AI/ML tools
log "Installing AI development tools..."
pip3 install --break-system-packages \
    nvitop gpustat \
    nvidia-ml-py3

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
cat > /root/.takerman_aliases << 'EOF'
# TAKERMAN AI Server Aliases
# GPU and AI Management
alias takgpu='nvidia-smi'
alias takgpuwatch='watch -n 1 nvidia-smi'
alias takgpustats='gpustat -i 1'
alias taknvtop='nvtop'
alias takgputemp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits'

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
alias takerror='journalctl -f -p err'
alias takconfig='cd /root/.takerman'
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
cat > /root/.bashrc << 'EOF'
# TAKERMAN AI Server Root Shell Configuration

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# Colors for prompt
export PS1='\[\033[01;35m\][\[\033[01;37m\]TAKERMAN\[\033[01;35m\]]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Load TAKERMAN aliases
if [ -f ~/.takerman_aliases ]; then
    . ~/.takerman_aliases
fi

# Ensure aliases are available in all new bash sessions
if ! grep -q "source.*takerman_aliases" /etc/bash.bashrc 2>/dev/null; then
    echo "" >> /etc/bash.bashrc
    echo "# TAKERMAN AI Server aliases" >> /etc/bash.bashrc
    echo "if [ -f /root/.takerman_aliases ]; then" >> /etc/bash.bashrc
    echo "    source /root/.takerman_aliases" >> /etc/bash.bashrc
    echo "fi" >> /etc/bash.bashrc
fi

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

# 3.4 Configure NVIDIA Container Toolkit  
log "Configuring NVIDIA Docker integration..."
nvidia-ctk runtime configure --runtime=docker

# Get GPU UUID for resource allocation
log "Detecting GPU UUID for resource allocation..."
GPU_UUID=$(nvidia-smi -a | grep "GPU UUID" | head -1 | awk '{print $4}')
if [ -z "$GPU_UUID" ]; then
    log_warning "Could not detect GPU UUID, using placeholder"
    GPU_UUID="GPU-placeholder-uuid"
fi
log "Using GPU UUID: $GPU_UUID"

# Create optimized Docker daemon configuration with GPU sharing
cat > /etc/docker/daemon.json << EOF
{
    "default-runtime": "nvidia",
    "node-generic-resources": [
        "NVIDIA_GPU_1=$GPU_UUID",
        "NVIDIA_GPU_2=$GPU_UUID",
        "NVIDIA_GPU_3=$GPU_UUID",
        "NVIDIA_GPU_4=$GPU_UUID",
        "NVIDIA_GPU_5=$GPU_UUID"
    ],
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "args": []
        }
    },
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

# 3.5 Configure secure SSH for root access
log "Configuring SSH security with Hakerman91! password..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Create SSH configuration for security
cat > /etc/ssh/sshd_config << 'EOF'
# TAKERMAN AI Server SSH Configuration
Port 1991
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes

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
ufw allow 1991/tcp      # SSH
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

# 3.9 Create AI workspace directories (containers will handle volume creation)
log "Setting up base directories for Docker volumes..."
mkdir -p /root/volumes
chmod -R 755 /root/volumes

# Copy the main docker-compose.yml from server repo
log "Setting up Docker Compose configuration..."
if [ -f "/root/server/docker-compose.yml" ]; then
    cp /root/server/docker-compose.yml /root/docker-compose.yml
    log_success "Docker Compose configuration ready"
else
    log_warning "Docker Compose file not found in server repo"
fi

# 4. System optimization for AI workloads
log "Optimizing system for AI performance..."

# Increase shared memory for large models
echo 'tmpfs /dev/shm tmpfs defaults,size=8G 0 0' >> /etc/fstab

# GPU performance settings
cat > /etc/systemd/system/gpu-performance.service << 'EOF'
[Unit]
Description=TAKERMAN GPU Performance Optimization
After=graphical.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi --auto-boost-default=DISABLED
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

systemctl enable gpu-performance.service

# 5. Final system configuration
log "Finalizing TAKERMAN AI Server setup..."

# Set system timezone
timedatectl set-timezone UTC

# Enable automatic updates for security
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Create password change reminder flag (will be removed after password change)
touch /var/lib/takerman-password-change-needed

# Create startup log
echo "TAKERMAN AI Server initialized at $(date)" >> /var/log/takerman/ai-server.log
chmod 644 /var/log/takerman/ai-server.log

# Start Docker services
log "Starting TAKERMAN AI Docker services..."
if [ -f "/root/server/scripts/start_docker_services.sh" ]; then
    chmod +x /root/server/scripts/start_docker_services.sh
    /root/server/scripts/start_docker_services.sh
else
    log_warning "Docker services startup script not found, services will need to be started manually"
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
nvidia-smi "$@"
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
log "   SSH: ssh root@<server-ip>:1991"
log "   Jupyter: http://<server-ip>:5104 (Token: Hakerman91!)"
log "   ComfyUI: http://<server-ip>:5100"
log "   Open WebUI: http://<server-ip>:5102"
log "   N8N: http://<server-ip>:5103 (takerman/Hakerman91!)"
log "   Portainer: https://<server-ip>:9443"
log ""
log "💡 Use 'takhelp' for available commands"
log "📈 Use 'takstats' for system overview"