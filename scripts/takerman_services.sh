#!/bin/bash

# TAKERMAN Docker Services Management Script
# Simple script to manage TAKERMAN AI Server containers

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
    echo -e "${CYAN}[TAKERMAN]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}              ${WHITE}TAKERMAN Docker Services Manager${NC}              ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start    - Start all TAKERMAN services"
    echo "  stop     - Stop all TAKERMAN services" 
    echo "  restart  - Restart all TAKERMAN services"
    echo "  status   - Show status of all services"
    echo "  logs     - Show logs of all services"
    echo "  pull     - Pull latest images"
    echo "  clean    - Clean up stopped containers and unused images"
    echo
    echo "Individual service commands:"
    echo "  ai       - Start AI services (Jupyter, ComfyUI, OpenWebUI, N8N, Ollama)"
    echo "  devops   - Start DevOps services (Portainer, Nginx Proxy)"
    echo "  monitor  - Start monitoring services (Dozzle)"
    echo
    echo "Examples:"
    echo "  $0 start     # Start all services"
    echo "  $0 ai        # Start only AI services"
    echo "  $0 status    # Check status"
}

find_compose_file() {
    if [ -f "/root/docker-compose.yml" ]; then
        echo "/root"
    elif [ -f "/root/server/docker-compose.yml" ]; then
        echo "/root/server"
    else
        log_error "docker-compose.yml not found!"
        echo "Please ensure TAKERMAN is properly installed."
        exit 1
    fi
}

wait_for_docker() {
    log "Waiting for Docker daemon to be ready..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if docker info >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        timeout=$((timeout - 1))
    done
    log_error "Docker daemon not ready after 30 seconds"
    return 1
}

start_all() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    wait_for_docker || exit 1
    
    log "Starting all TAKERMAN services..."
    docker compose up -d
    
    log_success "All services started!"
    show_status
}

stop_all() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    log "Stopping all TAKERMAN services..."
    docker compose down
    
    log_success "All services stopped!"
}

restart_all() {
    log "Restarting all TAKERMAN services..."
    stop_all
    sleep 3
    start_all
}

show_status() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                    ${WHITE}Service Status${NC}                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    docker compose ps
    
    echo
    echo -e "${YELLOW}Service URLs (if running):${NC}"
    echo "  🚀 Portainer:     https://localhost:9443"
    echo "  📊 Jupyter Lab:   http://localhost:5104"
    echo "  🎨 ComfyUI:       http://localhost:5100"
    echo "  🤖 Open WebUI:    http://localhost:5102"
    echo "  🔄 N8N:           http://localhost:5103"
    echo "  📋 Dozzle Logs:   http://localhost:8050"
}

show_logs() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    log "Showing logs for all services..."
    docker compose logs -f --tail=50
}

pull_images() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    log "Pulling latest images..."
    docker compose pull
    log_success "Images updated!"
}

clean_docker() {
    log "Cleaning up Docker resources..."
    docker system prune -f
    docker volume prune -f
    log_success "Cleanup completed!"
}

start_ai_services() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    wait_for_docker || exit 1
    
    log "Starting AI services..."
    docker compose up -d ai_ollama ai_comfyui ai_openwebui ai_n8n tool_jupyter
    log_success "AI services started!"
}

start_devops_services() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    wait_for_docker || exit 1
    
    log "Starting DevOps services..."
    docker compose up -d devops_portainer devops_proxy
    log_success "DevOps services started!"
}

start_monitoring_services() {
    local compose_dir=$(find_compose_file)
    cd "$compose_dir"
    
    wait_for_docker || exit 1
    
    log "Starting monitoring services..."
    docker compose up -d monitoring_dozzle
    log_success "Monitoring services started!"
}

# Main script logic
case "${1:-}" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "pull")
        pull_images
        ;;
    "clean")
        clean_docker
        ;;
    "ai")
        start_ai_services
        ;;
    "devops")
        start_devops_services
        ;;
    "monitor")
        start_monitoring_services
        ;;
    *)
        show_usage
        exit 1
        ;;
esac