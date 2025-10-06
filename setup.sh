#!/bin/bash
# TAKERMAN AI Server - Simple Setup Script
# Installs Docker, NVIDIA drivers, and AI services

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[TAKERMAN]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Banner
clear
cat << 'EOF'
 ████████╗ █████╗ ██╗  ██╗███████╗██████╗ ███╗   ███╗ █████╗ ███╗   ██╗
 ╚══██╔══╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗████╗ ████║██╔══██╗████╗  ██║
    ██║   ███████║█████╔╝ █████╗  ██████╔╝██╔████╔██║███████║██╔██╗ ██║
    ██║   ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║
    ██║   ██║  ██║██║  ██╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║
    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                     🚀 AI SERVER SETUP 🚀
EOF
echo ""

# Check if running as root
[[ $EUID -ne 0 ]] && error "Run as root: sudo bash setup.sh"

log "Installing essential packages..."
apt-get update
apt-get install -y curl wget git htop vim sudo ufw

# Install Docker
log "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    success "Docker installed"
else
    success "Docker already installed"
fi

# Install Docker Compose
log "Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
    apt-get install -y docker-compose-plugin
    success "Docker Compose installed"
else
    success "Docker Compose already installed"
fi

# Setup NVIDIA (if GPU detected)
if lspci | grep -i nvidia &> /dev/null; then
    log "NVIDIA GPU detected, installing drivers..."
    
    # Add contrib/non-free repos
    apt-add-repository contrib non-free -y 2>/dev/null || true
    apt-get update
    
    # Install NVIDIA drivers and container toolkit
    apt-get install -y nvidia-driver nvidia-container-toolkit
    
    # Configure Docker for NVIDIA
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
    
    success "NVIDIA support installed"
fi

# Setup firewall
log "Configuring firewall..."
ufw --force enable
ufw allow 22/tcp     # SSH
ufw allow 8888/tcp   # Jupyter
ufw allow 8188/tcp   # ComfyUI
ufw allow 9443/tcp   # Portainer
ufw allow 8050/tcp   # Dozzle
success "Firewall configured"

# Setup directories
log "Creating directories..."
mkdir -p /root/server /root/volumes/{ai,monitoring,devops}
success "Directories created"

# Install bash aliases
log "Installing TAKERMAN commands..."
cat >> /root/.bashrc << 'ALIASES'

# TAKERMAN Commands
alias takstats='echo "=== TAKERMAN AI SERVER ===" && docker ps --format "table {{.Names}}\t{{.Status}}" && echo "" && nvidia-smi 2>/dev/null || echo "No GPU"'
alias takhelp='echo "takstats  - Show system status" && echo "takup     - Start all services" && echo "takdown   - Stop all services" && echo "taklogs   - View logs"'
alias takup='cd /root/server && docker compose up -d'
alias takdown='cd /root/server && docker compose down'
alias taklogs='cd /root/server && docker compose logs -f'
alias takps='docker ps'
alias takgpu='nvidia-smi 2>/dev/null || echo "No GPU detected"'
ALIASES
success "TAKERMAN commands installed"

# Welcome message
cat >> /root/.bashrc << 'WELCOME'

echo "🚀 TAKERMAN AI Server Ready!"
echo "Run 'takhelp' for available commands"
WELCOME

success "Setup complete!"
echo ""
log "Next steps:"
echo "  1. Copy docker-compose.yml to /root/server/"
echo "  2. Run: takup"
echo "  3. Access services at http://$(hostname -I | awk '{print $1}'):PORT"
echo ""
