#!/bin/bash

# TAKERMAN GPU Reset Script
# Completely removes all GPU drivers and configurations, then reinstalls appropriate drivers

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[GPU-RESET]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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

show_banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                🔄 TAKERMAN GPU RESET TOOL 🔄                 ║
║            Complete GPU Driver Reset & Reinstall            ║
║                     https://takerman.net                     ║
║                                                              ║
║  ⚠️  WARNING: This will remove ALL GPU drivers and          ║
║      configurations, then reinstall appropriate drivers.    ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

confirm_reset() {
    echo -e "${YELLOW}This script will:${NC}"
    echo "  • Remove ALL GPU drivers (NVIDIA, AMD, Intel)"
    echo "  • Clean all GPU-related configurations"
    echo "  • Reset Docker GPU settings"
    echo "  • Detect your GPU and install appropriate drivers"
    echo "  • Reconfigure Docker Compose for your GPU"
    echo
    echo -e "${RED}⚠️  This action cannot be undone!${NC}"
    echo
    read -p "Are you sure you want to continue? (type 'YES' to confirm): " confirm
    
    if [ "$confirm" != "YES" ]; then
        log "Operation cancelled by user"
        exit 0
    fi
}

stop_services() {
    log "Stopping GPU-related services..."
    
    # Stop Docker containers
    if command -v docker >/dev/null 2>&1; then
        log "Stopping Docker containers..."
        docker stop $(docker ps -q) 2>/dev/null || true
    fi
    
    # Stop Docker service
    systemctl stop docker 2>/dev/null || true
    
    # Stop GPU services
    systemctl stop gpu-performance.service 2>/dev/null || true
    systemctl disable gpu-performance.service 2>/dev/null || true
    
    log_success "Services stopped"
}

remove_nvidia_drivers() {
    log "Removing NVIDIA drivers and tools..."
    
    # Kill NVIDIA processes
    pkill -f nvidia 2>/dev/null || true
    
    # Remove NVIDIA packages
    apt-get remove --purge -y \
        nvidia-* \
        libnvidia-* \
        cuda-* \
        libcuda* \
        nvidia-container-* \
        2>/dev/null || true
    
    # Remove NVIDIA repositories
    rm -f /etc/apt/sources.list.d/nvidia-* 2>/dev/null || true
    rm -f /etc/apt/keyrings/nvidia-* 2>/dev/null || true
    
    # Remove NVIDIA configuration files
    rm -rf /etc/nvidia 2>/dev/null || true
    rm -f /etc/X11/xorg.conf 2>/dev/null || true
    
    # Remove NVIDIA kernel modules
    rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null || true
    
    log_success "NVIDIA drivers removed"
}

remove_amd_drivers() {
    log "Removing AMD drivers and tools..."
    
    # Remove AMD packages
    apt-get remove --purge -y \
        amdgpu-* \
        mesa-amdgpu-* \
        rocm-* \
        radeontop \
        2>/dev/null || true
    
    # Remove AMD repositories
    rm -f /etc/apt/sources.list.d/amdgpu* 2>/dev/null || true
    rm -f /etc/apt/sources.list.d/rocm* 2>/dev/null || true
    
    # Remove AMD configuration
    rm -rf /etc/amd 2>/dev/null || true
    
    log_success "AMD drivers removed"
}

remove_intel_drivers() {
    log "Removing Intel GPU tools..."
    
    # Remove Intel GPU packages
    apt-get remove --purge -y \
        intel-media-* \
        intel-gpu-tools \
        intel-opencl-* \
        2>/dev/null || true
    
    log_success "Intel GPU tools removed"
}

clean_docker_config() {
    log "Cleaning Docker GPU configuration..."
    
    # Backup Docker daemon config
    if [ -f "/etc/docker/daemon.json" ]; then
        cp /etc/docker/daemon.json /etc/docker/daemon.json.pre-reset
    fi
    
    # Create clean Docker daemon config (no GPU runtime)
    cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "live-restore": true,
    "userland-proxy": false,
    "experimental": false,
    "metrics-addr": "0.0.0.0:9323"
}
EOF
    
    log_success "Docker configuration cleaned"
}

clean_monitoring_tools() {
    log "Removing GPU monitoring tools..."
    
    # Remove Python GPU monitoring packages
    pip3 uninstall -y \
        gpustat \
        nvitop \
        nvidia-ml-py3 \
        radeontop-py \
        2>/dev/null || true
    
    # Remove GPU monitoring commands
    rm -f /usr/local/bin/takgpu* 2>/dev/null || true
    
    log_success "GPU monitoring tools removed"
}

clean_docker_compose() {
    log "Cleaning Docker Compose GPU configurations..."
    
    local compose_file="/root/docker-compose.yml"
    
    if [ -f "$compose_file" ]; then
        # Create backup
        cp "$compose_file" "${compose_file}.pre-reset"
        
        # Remove GPU-specific configurations
        python3 -c "
import yaml
import sys

try:
    with open('$compose_file', 'r') as f:
        compose = yaml.safe_load(f)
    
    # Clean GPU configurations from all services
    for service_name, service in compose.get('services', {}).items():
        # Remove GPU runtime
        service.pop('runtime', None)
        
        # Remove GPU devices
        service.pop('devices', None)
        
        # Clean GPU-related environment variables
        if 'environment' in service:
            if isinstance(service['environment'], list):
                service['environment'] = [
                    env for env in service['environment'] 
                    if not any(gpu_env in str(env).upper() for gpu_env in [
                        'NVIDIA_', 'CUDA_', 'HSA_', 'ROC_'
                    ])
                ]
            elif isinstance(service['environment'], dict):
                gpu_keys = [
                    key for key in service['environment'].keys()
                    if any(gpu_env in key.upper() for gpu_env in [
                        'NVIDIA_', 'CUDA_', 'HSA_', 'ROC_'
                    ])
                ]
                for key in gpu_keys:
                    del service['environment'][key]
    
    with open('$compose_file', 'w') as f:
        yaml.dump(compose, f, default_flow_style=False)
    
    print('GPU configurations removed from Docker Compose')
except Exception as e:
    print(f'Error cleaning Docker Compose: {e}')
"
    fi
    
    log_success "Docker Compose cleaned"
}

perform_cleanup() {
    log "Starting complete GPU cleanup..."
    
    # Stop services first
    stop_services
    
    # Remove all GPU drivers
    remove_nvidia_drivers
    remove_amd_drivers  
    remove_intel_drivers
    
    # Clean configurations
    clean_docker_config
    clean_monitoring_tools
    clean_docker_compose
    
    # Clean package cache
    apt-get autoremove -y
    apt-get autoclean
    
    log_success "Complete GPU cleanup finished"
}

reinstall_gpu_drivers() {
    log "Reinstalling appropriate GPU drivers..."
    
    # Run the universal GPU setup script
    local setup_script="/root/setup_universal_gpu.sh"
    
    if [ ! -f "$setup_script" ]; then
        log "Downloading universal GPU setup script..."
        wget -O "$setup_script" https://raw.githubusercontent.com/TakermanLTD/os-takerman/main/scripts/setup_universal_gpu.sh
        chmod +x "$setup_script"
    fi
    
    # Run the setup script
    log "Running universal GPU detection and setup..."
    "$setup_script"
}

main() {
    show_banner
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Install required tools
    apt-get update
    apt-get install -y python3-yaml wget
    
    # Get confirmation
    confirm_reset
    
    # Perform cleanup
    perform_cleanup
    
    # Reinstall drivers
    reinstall_gpu_drivers
    
    echo
    log_success "🎉 GPU reset and reconfiguration completed!"
    echo
    log "📋 What was done:"
    log "  • Removed all GPU drivers and configurations"
    log "  • Cleaned Docker and Docker Compose settings"  
    log "  • Detected current GPU hardware"
    log "  • Installed appropriate drivers"
    log "  • Configured Docker for GPU support"
    echo
    log "🔄 Please reboot the system for changes to take effect:"
    log "   sudo reboot"
    echo
    
    read -p "Would you like to reboot now? (y/N): " reboot_now
    if [[ $reboot_now =~ ^[Yy]$ ]]; then
        log "Rebooting system..."
        reboot
    fi
}

# Run main function
main "$@"