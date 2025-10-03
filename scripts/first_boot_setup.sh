#!/bin/bash

# TAKERMAN AI Server First Boot Setup
# Ensures proper password security and command availability

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

log() {
    echo -e "${CYAN}[TAKERMAN-FIRST-BOOT]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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

show_password_warning() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    🚨 SECURITY ALERT 🚨                      ║
║                                                              ║
║  You are using a temporary default password!                 ║
║  For security, you MUST change it now.                      ║
║                                                              ║
║  Current password: TakeRm@n2024!Temp                        ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
}

force_password_change() {
    show_password_warning
    
    echo -e "${YELLOW}Please enter a new secure password for the root account:${NC}"
    echo -e "${BLUE}Requirements:${NC}"
    echo "  - At least 8 characters"
    echo "  - Mix of uppercase, lowercase, numbers, and symbols"
    echo "  - Avoid common passwords"
    echo
    
    # Force password change
    local password_changed=false
    local attempts=0
    local max_attempts=3
    
    while [ "$password_changed" = false ] && [ $attempts -lt $max_attempts ]; do
        if passwd root; then
            password_changed=true
            log_success "Password changed successfully!"
            
            # Remove the password change flag
            rm -f /var/lib/takerman-password-change-needed
            
            echo
            echo -e "${GREEN}🎉 Welcome to TAKERMAN AI Server!${NC}"
            echo -e "${CYAN}Your system is now secure and ready to use.${NC}"
            
        else
            attempts=$((attempts + 1))
            if [ $attempts -lt $max_attempts ]; then
                echo
                log_warning "Password change failed. Please try again. (Attempt $attempts/$max_attempts)"
                echo
            else
                log_error "Maximum password change attempts reached."
                log_error "System will create a reminder for next login."
                break
            fi
        fi
    done
    
    if [ "$password_changed" = false ]; then
        log_warning "Password not changed. You will be prompted again on next login."
    fi
}

setup_tak_commands() {
    log "Ensuring TAKERMAN commands are available..."
    
    # Make sure aliases are loaded in all bash sessions
    if ! grep -q "source /root/.takerman_aliases" /etc/bash.bashrc; then
        echo "" >> /etc/bash.bashrc
        echo "# TAKERMAN AI Server aliases" >> /etc/bash.bashrc
        echo "if [ -f /root/.takerman_aliases ]; then" >> /etc/bash.bashrc
        echo "    source /root/.takerman_aliases" >> /etc/bash.bashrc
        echo "fi" >> /etc/bash.bashrc
        log_success "TAKERMAN aliases added to global bash configuration"
    fi
    
    # Also ensure they're loaded for the current session
    if [ -f /root/.takerman_aliases ]; then
        source /root/.takerman_aliases
        log_success "TAKERMAN aliases loaded for current session"
    fi
    
    # Create symbolic links for key commands to make them available as actual commands
    local commands_to_link=(
        "takstats:takerman-stats"
        "takgpu:nvidia-smi"
        "takdocker:docker"
        "takps:docker ps"
    )
    
    for cmd_pair in "${commands_to_link[@]}"; do
        local cmd_name="${cmd_pair%%:*}"
        local cmd_target="${cmd_pair##*:}"
        
        # Create wrapper script for complex commands
        if [[ "$cmd_target" == *" "* ]]; then
            cat > "/usr/local/bin/$cmd_name" << EOF
#!/bin/bash
$cmd_target "\$@"
EOF
            chmod +x "/usr/local/bin/$cmd_name"
        else
            if command -v "$cmd_target" &> /dev/null; then
                ln -sf "$(which $cmd_target)" "/usr/local/bin/$cmd_name" 2>/dev/null || true
            fi
        fi
    done
    
    log_success "Key TAKERMAN commands are available system-wide"
}

create_first_login_message() {
    # Create a message that shows on first login
    cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    🚀 TAKERMAN AI SERVER 🚀                  ║
║                     https://takerman.net                     ║
║                                                              ║
║  Welcome to your high-performance AI development server!     ║
║                                                              ║
║  💡 Quick Commands:                                          ║
║    takstats  - System overview dashboard                     ║
║    takhelp   - Show all available commands                   ║
║    takgpu    - GPU status                                    ║
║    takdocker - Docker management                             ║
║                                                              ║
║  📊 Services: http://YOUR_SERVER_IP:PORT                     ║
║    Jupyter Lab (5104), ComfyUI (5100), Open WebUI (5102)   ║
║    N8N (5103), Portainer (9443)                             ║
╚══════════════════════════════════════════════════════════════╝

EOF
}

main() {
    log "Starting TAKERMAN AI Server first boot setup..."
    
    # Check if password change is needed
    if [ -f "/var/lib/takerman-password-change-needed" ]; then
        force_password_change
    fi
    
    # Setup tak commands
    setup_tak_commands
    
    # Create welcome message
    create_first_login_message
    
    log_success "First boot setup completed!"
    
    # Self-destruct this service after successful run
    if [ ! -f "/var/lib/takerman-password-change-needed" ]; then
        systemctl disable takerman-first-boot.service 2>/dev/null || true
        log "First boot service disabled (will not run again)"
    fi
}

# Only run if this is being executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi