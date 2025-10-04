#!/bin/bash

# TAKERMAN AI Server - System Verification Script
# Run this to check if all components are properly installed and configured

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

log_check() {
    echo -e "${CYAN}[CHECK]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✅ OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠️  WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                🔍 TAKERMAN SYSTEM VERIFICATION 🔍             ║
║                     https://takerman.net                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_essential_commands() {
    log_check "Checking essential commands..."
    
    local commands=(
        "curl:Web downloading"
        "wget:File downloading" 
        "git:Version control"
        "docker:Container platform"
        "python3:Python interpreter"
        "pip3:Python package manager"
        "nano:Text editor"
        "vim:Advanced text editor"
        "htop:Process monitor"
        "netstat:Network statistics"
        "ifconfig:Network interface config"
        "ping:Network connectivity"
        "ssh:Secure shell"
        "ufw:Firewall management"
        "systemctl:Service management"
    )
    
    local missing=()
    
    for cmd_info in "${commands[@]}"; do
        local cmd="${cmd_info%%:*}"
        local desc="${cmd_info##*:}"
        
        if command -v "$cmd" >/dev/null 2>&1; then
            log_success "$cmd ($desc)"
        else
            log_error "$cmd ($desc) - NOT FOUND"
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo
        log_warning "Missing commands detected. Install with:"
        echo "apt update && apt install -y ${missing[*]}"
    fi
}

check_takerman_commands() {
    log_check "Checking TAKERMAN commands..."
    
    local tak_commands=(
        "takgpu:GPU monitoring"
        "takstats:System dashboard"
        "takdocker:Docker management"
        "takhelp:Command help"
    )
    
    for cmd_info in "${tak_commands[@]}"; do
        local cmd="${cmd_info%%:*}"
        local desc="${cmd_info##*:}"
        
        if command -v "$cmd" >/dev/null 2>&1; then
            log_success "$cmd ($desc)"
        else
            log_error "$cmd ($desc) - NOT FOUND"
        fi
    done
    
    # Check aliases
    if [ -f "/root/.takerman_aliases" ]; then
        log_success "TAKERMAN aliases file exists"
    else
        log_error "TAKERMAN aliases file missing"
    fi
}

check_services() {
    log_check "Checking system services..."
    
    local services=(
        "ssh:SSH server"
        "docker:Docker daemon"
        "fail2ban:Intrusion prevention"
        "ufw:Firewall service"
    )
    
    for svc_info in "${services[@]}"; do
        local svc="${svc_info%%:*}"
        local desc="${svc_info##*:}"
        
        if systemctl is-active --quiet "$svc"; then
            log_success "$svc ($desc) - RUNNING"
        else
            if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
                log_warning "$svc ($desc) - INSTALLED but not running"
            else
                log_error "$svc ($desc) - NOT INSTALLED or DISABLED"
            fi
        fi
    done
}

check_network_config() {
    log_check "Checking network configuration..."
    
    # Check SSH port
    local ssh_port=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
    if [ "$ssh_port" = "22" ]; then
        log_success "SSH running on port 22 (standard)"
    elif [ -n "$ssh_port" ]; then
        log_warning "SSH running on port $ssh_port (non-standard)"
    else
        log_warning "SSH port configuration not found"
    fi
    
    # Check firewall status
    if ufw status >/dev/null 2>&1; then
        local ufw_status=$(ufw status | grep -o "Status: [a-zA-Z]*" | cut -d' ' -f2)
        if [ "$ufw_status" = "active" ]; then
            log_success "UFW firewall is active"
        else
            log_warning "UFW firewall is inactive"
        fi
    else
        log_error "UFW firewall not available"
    fi
    
    # Check network connectivity
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_success "Internet connectivity working"
    else
        log_warning "No internet connectivity detected"
    fi
}

check_gpu_support() {
    log_check "Checking GPU support..."
    
    if command -v nvidia-smi >/dev/null 2>&1; then
        if nvidia-smi >/dev/null 2>&1; then
            local gpu_count=$(nvidia-smi -L | wc -l)
            log_success "NVIDIA drivers working - $gpu_count GPU(s) detected"
        else
            log_warning "NVIDIA drivers installed but not working"
        fi
    else
        log_warning "NVIDIA drivers not installed"
    fi
    
    if command -v docker >/dev/null 2>&1; then
        if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi >/dev/null 2>&1; then
            log_success "Docker GPU support working"
        else
            log_warning "Docker GPU support not working"
        fi
    fi
}

check_docker_setup() {
    log_check "Checking Docker setup..."
    
    if systemctl is-active --quiet docker; then
        log_success "Docker daemon is running"
        
        # Check Docker Compose
        if docker compose version >/dev/null 2>&1; then
            log_success "Docker Compose is available"
        else
            log_warning "Docker Compose not available"
        fi
        
        # Check for TAKERMAN compose file
        if [ -f "/root/docker-compose.yml" ]; then
            log_success "TAKERMAN docker-compose.yml found"
        else
            log_warning "TAKERMAN docker-compose.yml not found"
        fi
        
    else
        log_error "Docker daemon not running"
    fi
}

show_system_summary() {
    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                      ${WHITE}SYSTEM SUMMARY${NC}                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    # System info
    echo -e "${PURPLE}║${NC} ${YELLOW}Hostname:${NC} $(hostname)"
    echo -e "${PURPLE}║${NC} ${YELLOW}OS:${NC} $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"
    echo -e "${PURPLE}║${NC} ${YELLOW}Kernel:${NC} $(uname -r)"
    echo -e "${PURPLE}║${NC} ${YELLOW}Uptime:${NC} $(uptime -p 2>/dev/null || echo "Unknown")"
    
    # Network info
    local ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo -e "${PURPLE}║${NC} ${YELLOW}IP Address:${NC} ${ip:-"Not configured"}"
    
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
}

fix_missing_components() {
    echo
    log_check "Would you like to install missing components? (y/N)"
    read -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_check "Installing missing components..."
        
        # Install essential packages if missing
        apt update
        apt install -y curl wget git docker.io docker-compose ufw fail2ban \
            python3 python3-pip nano vim htop net-tools openssh-server
        
        # Enable services
        systemctl enable --now ssh docker fail2ban
        
        # Configure firewall
        ufw --force enable
        ufw allow 22/tcp
        
        log_success "Installation completed. Run this script again to verify."
    fi
}

main() {
    show_banner
    
    check_essential_commands
    echo
    check_takerman_commands  
    echo
    check_services
    echo
    check_network_config
    echo
    check_gpu_support
    echo
    check_docker_setup
    
    show_system_summary
    
    fix_missing_components
}

main "$@"