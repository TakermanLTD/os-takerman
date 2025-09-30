#!/bin/bash

# TAKERMAN AI Server - Docker Management Helper
# Easy commands to manage AI services

set -e

COMPOSE_FILE="/root/server/docker-compose.yml"

show_help() {
    echo "TAKERMAN AI Docker Manager"
    echo ""
    echo "Usage: takerman-docker [command]"
    echo ""
    echo "Commands:"
    echo "  start       Start all services"
    echo "  stop        Stop all services" 
    echo "  restart     Restart all services"
    echo "  status      Show service status"
    echo "  logs        Show logs for all services"
    echo "  logs <svc>  Show logs for specific service"
    echo "  update      Pull latest images and restart"
    echo "  urls        Show service URLs"
    echo "  help        Show this help"
    echo ""
    echo "Services:"
    echo "  devops_portainer   - Container management UI"
    echo "  devops_proxy       - Nginx reverse proxy"
    echo "  monitoring_dozzle  - Docker logs viewer"
    echo "  ai_ollama         - Ollama LLM server"
    echo "  ai_comfyui        - ComfyUI image generation"
    echo "  ai_openwebui      - OpenWebUI for LLMs"
    echo "  ai_n8n            - N8N workflow automation"
    echo "  tool_jupyter      - Jupyter Lab with AI libraries"
    echo "  service_publish   - TAKERMAN publish service"
}

check_compose_file() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo "Error: Docker Compose file not found at $COMPOSE_FILE"
        echo "Please ensure the TAKERMAN server repository is cloned to /root/server"
        exit 1
    fi
}

start_services() {
    echo "Starting TAKERMAN AI services..."
    cd "$(dirname "$COMPOSE_FILE")"
    docker compose up -d
    echo "Services started successfully!"
}

stop_services() {
    echo "Stopping TAKERMAN AI services..."
    cd "$(dirname "$COMPOSE_FILE")"
    docker compose down
    echo "Services stopped successfully!"
}

restart_services() {
    echo "Restarting TAKERMAN AI services..."
    cd "$(dirname "$COMPOSE_FILE")"
    docker compose restart
    echo "Services restarted successfully!"
}

show_status() {
    echo "TAKERMAN AI Service Status:"
    cd "$(dirname "$COMPOSE_FILE")"
    docker compose ps
}

show_logs() {
    cd "$(dirname "$COMPOSE_FILE")"
    if [ -n "$2" ]; then
        echo "Logs for service: $2"
        docker compose logs -f "$2"
    else
        echo "Logs for all services:"
        docker compose logs -f
    fi
}

update_services() {
    echo "Updating TAKERMAN AI services..."
    cd "$(dirname "$COMPOSE_FILE")"
    docker compose pull
    docker compose up -d
    echo "Services updated successfully!"
}

show_urls() {
    echo "TAKERMAN AI Service URLs:"
    echo ""
    echo "Management & DevOps:"
    echo "  Portainer:     https://localhost:9443"
    echo "  Nginx Proxy:   http://localhost:81"  
    echo "  Dozzle Logs:   http://localhost:8050"
    echo ""
    echo "AI & ML Services:"
    echo "  Jupyter Lab:   http://localhost:5104 (Token: Hakerman91!)"
    echo "  Ollama API:    http://localhost:5101"
    echo "  ComfyUI:       http://localhost:5100"
    echo "  Open WebUI:    http://localhost:5102"
    echo "  N8N Workflow:  http://localhost:5103 (User: takerman, Pass: Hakerman91!)"
    echo ""
    echo "Applications:"
    echo "  Service API:   http://localhost:8088"
}

# Main command handling
case "${1:-help}" in
    start)
        check_compose_file
        start_services
        ;;
    stop)
        check_compose_file
        stop_services
        ;;
    restart)
        check_compose_file
        restart_services
        ;;
    status)
        check_compose_file
        show_status
        ;;
    logs)
        check_compose_file
        show_logs "$@"
        ;;
    update)
        check_compose_file
        update_services
        ;;
    urls)
        show_urls
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use 'takerman-docker help' for usage information"
        exit 1
        ;;
esac