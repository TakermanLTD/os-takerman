#!/bin/bash

# TAKERMAN AI Server - Docker Container Startup Script
# Starts all AI services after OS installati    # Try multiple locations for docker-compose.yml
    local compose_dir=""
    if [ -f "/root/docker-compose.yml" ]; then
        compose_dir="/root"
    elif [ -f "/root/server/docker-compose.yml" ]; then
        compose_dir="/root/server"
    else
        log_error "docker-compose.yml not found in /root or /root/server"
        return 1
    fi
    
    cd "$compose_dir" || {
        log_error "Could not change to directory: $compose_dir"
        return 1
    }
    
    log "Using docker-compose.yml from: $compose_dir"tion

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# TAKERMAN branded logging
log() {
    echo -e "${CYAN}[TAKERMAN DOCKER]${NC} ${WHITE}$(date '+%H:%M:%S')${NC} $1"
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

# Function to create directory structure
create_volume_directories() {
    log "Creating volume directory structure in /root/volumes..."
    
    # Create base directories
    mkdir -p /root/volumes/{devops,monitoring,ai}
    
    # DevOps directories
    mkdir -p /root/volumes/devops/{portainer,nginx-proxy-manager/{data,letsencrypt}}
    
    # Monitoring directories
    mkdir -p /root/volumes/monitoring/dozzle
    
    # AI directories
    mkdir -p /root/volumes/ai/{generated/{videos/generated,pictures/artificialpics},ollama,comfyui/{models,output,input,custom_nodes,config},openwebui,n8n/{data,local_files,backups/{daily,weekly,monthly,emergency}},jupyter/{notebooks,models,config}}
    
    # ComfyUI model subdirectories
    mkdir -p /root/volumes/ai/comfyui/models/{checkpoints,vae,text_encoders,loras,diffusion_models,style_models,clip_vision}
    
    # Set proper permissions
    chown -R root:root /root/volumes
    chmod -R 755 /root/volumes
    
    # Special permissions for n8n (needs user 1000)
    chown -R 1000:1000 /root/volumes/ai/n8n/
    
    log_success "Volume directories created successfully"
}

# Function to wait for Docker daemon
wait_for_docker() {
    log "Waiting for Docker daemon to be ready..."
    local max_attempts=30
    local attempt=0
    
    while ! docker info > /dev/null 2>&1; do
        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            log_error "Docker daemon failed to start after $max_attempts attempts"
            return 1
        fi
        log "Docker not ready, waiting... (attempt $attempt/$max_attempts)"
        sleep 2
    done
    
    log_success "Docker daemon is ready"
}

# Function to pull Docker images
pull_images() {
    log "Pulling Docker images..."
    
    local images=(
        "portainer/portainer-ce:latest"
        "jc21/nginx-proxy-manager:latest"
        "amir20/dozzle:latest"
        "ghcr.io/takermanltd/service-publish:latest"
        "ollama/ollama:latest"
        "ghcr.io/takermanltd/takerman.comfyui:latest"
        "ghcr.io/open-webui/open-webui:latest"
        "n8nio/n8n:latest"
        "ghcr.io/takermanltd/takerman.jupyter:latest"
    )
    
    for image in "${images[@]}"; do
        log "Pulling $image..."
        if docker pull "$image"; then
            log_success "Successfully pulled $image"
        else
            log_warning "Failed to pull $image, will retry during container start"
        fi
    done
}

# Function to start Docker services
start_services() {
    log "Starting TAKERMAN AI services..."
    
    cd /root/server || {
        log_error "Could not find /root/server directory"
        return 1
    }
    
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml not found in /root/server"
        return 1
    fi
    
    # Start services in order (some have dependencies)
    log "Starting infrastructure services..."
    docker compose up -d devops_portainer devops_proxy monitoring_dozzle
    
    log "Waiting for infrastructure to initialize..."
    sleep 10
    
    log "Starting AI services..."
    docker compose up -d ai_ollama
    
    log "Waiting for Ollama to initialize..."
    sleep 15
    
    docker compose up -d ai_comfyui ai_openwebui ai_n8n tool_jupyter
    
    log "Waiting for AI services to initialize..."
    sleep 10
    
    log "Starting application services..."
    docker compose up -d service_publish
    
    log_success "All services started successfully"
}

# Function to verify services are running
verify_services() {
    log "Verifying services are running..."
    
    local services=(
        "devops_portainer:9443"
        "devops_proxy:81"
        "monitoring_dozzle:8050"
        "ai_ollama:5101"
        "ai_comfyui:5100"
        "ai_openwebui:5102"
        "ai_n8n:5103"
        "tool_jupyter:5104"
        "service_publish:8088"
    )
    
    log "Checking container status..."
    docker compose ps
    
    log "Waiting for services to be fully available..."
    sleep 30
    
    for service in "${services[@]}"; do
        local container_name="${service%:*}"
        local port="${service#*:}"
        
        if docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
            log_success "✓ $container_name is running"
        else
            log_warning "✗ $container_name is not running"
        fi
    done
}

# Function to display service URLs
show_service_urls() {
    log_success "TAKERMAN AI Server is ready! Access your services:"
    echo ""
    echo -e "${WHITE}Management & DevOps:${NC}"
    echo -e "  ${CYAN}Portainer:${NC}     https://localhost:9443"
    echo -e "  ${CYAN}Nginx Proxy:${NC}   http://localhost:81"
    echo -e "  ${CYAN}Dozzle Logs:${NC}   http://localhost:8050"
    echo ""
    echo -e "${WHITE}AI & ML Services:${NC}"
    echo -e "  ${CYAN}Jupyter Lab:${NC}   http://localhost:5104 (Token: Hakerman91!)"
    echo -e "  ${CYAN}Ollama API:${NC}    http://localhost:5101"
    echo -e "  ${CYAN}ComfyUI:${NC}       http://localhost:5100"
    echo -e "  ${CYAN}Open WebUI:${NC}    http://localhost:5102"
    echo -e "  ${CYAN}N8N Workflow:${NC}  http://localhost:5103 (User: takerman, Pass: Hakerman91!)"
    echo ""
    echo -e "${WHITE}Applications:${NC}"
    echo -e "  ${CYAN}Service API:${NC}   http://localhost:8088"
    echo ""
    echo -e "${YELLOW}Note:${NC} All services include Transformers, Accelerate, and other AI/ML libraries"
    echo -e "${YELLOW}      Jupyter includes: TensorFlow, PyTorch, Transformers, Accelerate, Datasets, Diffusers${NC}"
}

# Main execution
main() {
    log "Starting TAKERMAN AI Docker services initialization..."
    
    # Create directory structure
    create_volume_directories
    
    # Wait for Docker to be ready
    wait_for_docker || exit 1
    
    # Pull images
    pull_images
    
    # Start services
    start_services || exit 1
    
    # Verify services
    verify_services
    
    # Show URLs
    show_service_urls
    
    log_success "TAKERMAN AI Server Docker initialization completed successfully!"
}

# Run main function
main "$@"