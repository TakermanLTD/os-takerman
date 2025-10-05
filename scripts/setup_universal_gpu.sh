#!/bin/bash

# TAKERMAN Universal GPU Detection and Configuration Script
# Automatically detects and configures GPU drivers for NVIDIA, AMD, or Intel GPUs

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
    echo -e "${CYAN}[GPU-SETUP]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                🎮 TAKERMAN GPU AUTO-SETUP 🎮                 ║
║              Universal GPU Driver Configuration              ║
║                     https://takerman.net                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Detect GPU vendor and model
detect_gpu() {
    log "Detecting GPU hardware..."
    
    # Check for NVIDIA GPUs
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        GPU_VENDOR="nvidia"
        GPU_MODEL=$(lspci | grep -i nvidia | head -1 | cut -d: -f3 | sed 's/^ *//')
        log_success "NVIDIA GPU detected: $GPU_MODEL"
        return 0
    fi
    
    # Check for AMD GPUs
    if lspci | grep -iE "(amd|ati|radeon)" >/dev/null 2>&1; then
        GPU_VENDOR="amd"
        GPU_MODEL=$(lspci | grep -iE "(amd|ati|radeon)" | head -1 | cut -d: -f3 | sed 's/^ *//')
        log_success "AMD GPU detected: $GPU_MODEL"
        return 0
    fi
    
    # Check for Intel GPUs
    if lspci | grep -i "intel.*graphics\|intel.*display" >/dev/null 2>&1; then
        GPU_VENDOR="intel"
        GPU_MODEL=$(lspci | grep -i "intel.*graphics\|intel.*display" | head -1 | cut -d: -f3 | sed 's/^ *//')
        log_success "Intel GPU detected: $GPU_MODEL"
        return 0
    fi
    
    # No dedicated GPU found
    GPU_VENDOR="none"
    GPU_MODEL="Integrated/Unknown"
    log_warning "No dedicated GPU detected, using integrated graphics"
    return 0
}

# Clean existing GPU configurations
clean_gpu_setup() {
    log "Cleaning existing GPU configurations..."
    
    # Remove NVIDIA packages
    if dpkg -l | grep -q nvidia; then
        log "Removing NVIDIA packages..."
        apt-get remove --purge -y nvidia-* libnvidia-* 2>/dev/null || true
        apt-get autoremove -y 2>/dev/null || true
    fi
    
    # Remove AMD packages
    if dpkg -l | grep -q amdgpu; then
        log "Removing AMD packages..."
        apt-get remove --purge -y amdgpu-* mesa-amdgpu-* 2>/dev/null || true
        apt-get autoremove -y 2>/dev/null || true
    fi
    
    # Remove Intel packages
    if dpkg -l | grep -q intel-media; then
        log "Removing Intel packages..."
        apt-get remove --purge -y intel-media-* 2>/dev/null || true
        apt-get autoremove -y 2>/dev/null || true
    fi
    
    # Clean Docker GPU configurations
    if [ -f "/etc/docker/daemon.json" ]; then
        log "Cleaning Docker GPU configuration..."
        # Create backup
        cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
        # Remove GPU-specific configurations but keep other settings
        python3 -c "
import json
try:
    with open('/etc/docker/daemon.json', 'r') as f:
        config = json.load(f)
    # Remove GPU-specific keys
    keys_to_remove = ['default-runtime', 'runtimes', 'node-generic-resources']
    for key in keys_to_remove:
        config.pop(key, None)
    with open('/etc/docker/daemon.json', 'w') as f:
        json.dump(config, f, indent=4)
except:
    pass
" 2>/dev/null || true
    fi
    
    # Remove GPU monitoring tools
    pip3 uninstall -y gpustat nvitop nvidia-ml-py3 2>/dev/null || true
    
    log_success "GPU cleanup completed"
}

# Install NVIDIA drivers and tools
install_nvidia_gpu() {
    log "Installing NVIDIA GPU drivers and tools..."
    
    # Add NVIDIA repositories
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/$(dpkg --print-architecture) /" | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    # Enable non-free repositories for drivers
    sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
    
    apt-get update
    
    # Install NVIDIA drivers and container tools
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nvidia-driver nvidia-settings nvidia-smi \
        nvidia-container-toolkit nvidia-docker2 \
        libnvidia-encode1 libnvidia-decode1
    
    # Configure Docker for NVIDIA
    nvidia-ctk runtime configure --runtime=docker
    
    # Create optimized Docker daemon configuration
    cat > /etc/docker/daemon.json << 'EOF'
{
    "default-runtime": "nvidia",
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
    "live-restore": true,
    "userland-proxy": false,
    "experimental": false,
    "metrics-addr": "0.0.0.0:9323"
}
EOF
    
    # Install GPU monitoring tools
    pip3 install --break-system-packages gpustat nvitop nvidia-ml-py3
    
    # Create GPU performance service
    cat > /etc/systemd/system/gpu-performance.service << 'EOF'
[Unit]
Description=NVIDIA GPU Performance Optimization
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
    
    log_success "NVIDIA GPU setup completed"
}

# Install AMD drivers and tools
install_amd_gpu() {
    log "Installing AMD GPU drivers and tools..."
    
    # Add AMD repository
    wget -qO - https://repo.radeon.com/amdgpu-install/5.7/ubuntu/jammy/amdgpu-install_5.7.50700-1_all.deb -O /tmp/amdgpu-install.deb 2>/dev/null || \
    wget -qO /tmp/amdgpu-install.deb https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_latest_all.deb
    
    dpkg -i /tmp/amdgpu-install.deb || apt-get install -f -y
    
    # Install AMD drivers
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        amdgpu-dkms amdgpu-pro \
        mesa-amdgpu-va-drivers mesa-amdgpu-vdpau-drivers \
        libdrm-amdgpu1 libdrm2-amdgpu \
        radeontop
    
    # Configure Docker for AMD (ROCm support)
    apt-get install -y rocm-dkms rocm-libs rocm-utils || true
    
    # Create Docker daemon configuration for AMD
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
    
    # Install GPU monitoring tools for AMD
    pip3 install --break-system-packages radeontop-py || true
    
    log_success "AMD GPU setup completed"
}

# Install Intel drivers and tools
install_intel_gpu() {
    log "Installing Intel GPU drivers and tools..."
    
    # Install Intel GPU drivers and tools
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        intel-media-va-driver-non-free \
        intel-gpu-tools \
        mesa-va-drivers \
        vainfo \
        intel-opencl-icd
    
    # Configure Docker for Intel GPU
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
    
    log_success "Intel GPU setup completed"
}

# Create universal GPU monitoring aliases
create_gpu_aliases() {
    log "Creating universal GPU monitoring commands..."
    
    # Create universal GPU monitoring script
    cat > /usr/local/bin/takgpu << 'EOF'
#!/bin/bash

# Universal GPU monitoring script
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi "$@"
elif command -v radeontop >/dev/null 2>&1; then
    echo "AMD GPU Status:"
    radeontop -d - -l 1 | head -10
elif command -v intel_gpu_top >/dev/null 2>&1; then
    echo "Intel GPU Status:"
    intel_gpu_top -s 1000 -o - | head -10
else
    echo "No GPU monitoring tool available"
    lspci | grep -i "vga\|3d\|display"
fi
EOF
    chmod +x /usr/local/bin/takgpu
    
    # Create GPU temperature monitoring
    cat > /usr/local/bin/takgputemp << 'EOF'
#!/bin/bash

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits
elif command -v sensors >/dev/null 2>&1; then
    sensors | grep -i "gpu\|graphics" || echo "Temperature monitoring not available"
else
    echo "Temperature monitoring not available"
fi
EOF
    chmod +x /usr/local/bin/takgputemp
    
    log_success "Universal GPU commands created"
}

# Update Docker Compose for detected GPU
update_docker_compose() {
    log "Updating Docker Compose for $GPU_VENDOR GPU..."
    
    local compose_file="/root/docker-compose.yml"
    local source_template=""
    
    # Determine which template to use based on GPU
    case "$GPU_VENDOR" in
        "nvidia")
            source_template="/root/docker/docker-compose.nvidia.yml"
            log "Using NVIDIA GPU-optimized Docker Compose template"
            ;;
        "amd")
            source_template="/root/docker/docker-compose.amd.yml"
            log "Using AMD GPU-optimized Docker Compose template"
            ;;
        "intel")
            source_template="/root/docker/docker-compose.intel.yml"
            log "Using Intel GPU-optimized Docker Compose template"
            ;;
        *)
            source_template="/root/docker/docker-compose.cpu.yml"
            log "Using CPU-only Docker Compose template"
            ;;
    esac
    
    # Check if template exists
    if [ ! -f "$source_template" ]; then
        log_warning "Template file not found: $source_template"
        log "Attempting to copy from build directory..."
        if [ -f "/root/takerman/docker/$(basename $source_template)" ]; then
            cp "/root/takerman/docker/$(basename $source_template)" "$source_template"
        else
            log_error "Template file not found in build directory either"
            return 1
        fi
    fi
    
    # Create backup if compose file exists
    if [ -f "$compose_file" ]; then
        cp "$compose_file" "${compose_file}.backup"
    fi
    
    # Copy the appropriate template
    cp "$source_template" "$compose_file"
    
    log_success "Docker Compose updated for $GPU_VENDOR GPU support"

# Test GPU functionality
test_gpu() {
    log "Testing GPU functionality..."
    
    case "$GPU_VENDOR" in
        "nvidia")
            if nvidia-smi >/dev/null 2>&1; then
                log_success "NVIDIA GPU test passed"
                nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv
            else
                log_error "NVIDIA GPU test failed"
                return 1
            fi
            ;;
        "amd")
            if command -v radeontop >/dev/null 2>&1; then
                log_success "AMD GPU monitoring available"
            else
                log_warning "AMD GPU monitoring limited"
            fi
            ;;
        "intel")
            if command -v intel_gpu_top >/dev/null 2>&1; then
                log_success "Intel GPU monitoring available"
            else
                log_warning "Intel GPU monitoring limited"
            fi
            ;;
        *)
            log_warning "No dedicated GPU detected for testing"
            ;;
    esac
}

# Main installation function
main() {
    show_banner
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Install required tools
    apt-get update
    apt-get install -y lshw pciutils python3-yaml
    
    # Clean existing setup if requested
    if [ "${1:-}" = "--clean" ]; then
        clean_gpu_setup
    fi
    
    # Detect GPU
    detect_gpu
    
    # Install appropriate drivers
    case "$GPU_VENDOR" in
        "nvidia")
            install_nvidia_gpu
            ;;
        "amd")  
            install_amd_gpu
            ;;
        "intel")
            install_intel_gpu
            ;;
        "none")
            log_warning "No dedicated GPU detected, skipping driver installation"
            ;;
    esac
    
    # Create universal monitoring commands
    create_gpu_aliases
    
    # Update Docker Compose
    update_docker_compose
    
    # Restart Docker service
    systemctl restart docker
    
    # Test GPU functionality
    test_gpu
    
    echo
    log_success "🎉 Universal GPU setup completed!"
    log "GPU Vendor: $GPU_VENDOR"
    log "GPU Model: $GPU_MODEL"
    echo
    log "💡 Available commands:"
    log "   takgpu      - Show GPU status"
    log "   takgputemp  - Show GPU temperature"
    echo
    log "🔄 Please reboot the system to ensure all drivers are loaded properly"
}

# Run main function
main "$@"