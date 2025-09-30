# TAKERMAN AI Server - Docker-Based Setup

## Overview
This updated setup configures the TAKERMAN AI Server to run all AI/ML services (Jupyter, Transformers, Accelerate, etc.) in Docker containers instead of installing them directly on the host system. This provides better isolation, easier management, and more consistent deployments.

## Key Changes Made

### 1. Container-Based Architecture
- **Jupyter Lab**: Runs in container with TensorFlow, PyTorch, Transformers, Accelerate, and all ML libraries
- **AI Services**: ComfyUI, Ollama, OpenWebUI, N8N all containerized
- **Management**: Portainer, Nginx Proxy Manager, Dozzle for monitoring

### 2. Volume Management
- All volumes moved from `/mnt/raid` and `/mnt/media` to `/root/volumes/`
- Organized structure: `/root/volumes/{devops,monitoring,ai}/`
- Proper permissions and ownership configured automatically

### 3. Automatic Service Startup
- Docker services start automatically after OS installation
- New script: `scripts/start_docker_services.sh`
- Management helper: `scripts/takerman-docker.sh`

### 4. Updated Credentials
- Username: `takerman`
- Password: `Hakerman91!`
- Email: `tivanov@takerman.net`
- Jupyter Token: `Hakerman91!`

## Service Access Points

### Management & DevOps
- **Portainer**: https://localhost:9443 (Container management UI)
- **Nginx Proxy Manager**: http://localhost:81 (Reverse proxy config)
- **Dozzle**: http://localhost:8050 (Docker logs viewer)

### AI & ML Services  
- **Jupyter Lab**: http://localhost:5104 (Token: `Hakerman91!`)
  - Includes: TensorFlow, PyTorch, Transformers, Accelerate, Datasets, Diffusers
  - Pre-configured with all AI/ML libraries and extensions
- **Ollama API**: http://localhost:5101 (Local LLM server)
- **ComfyUI**: http://localhost:5100 (AI image generation)
- **OpenWebUI**: http://localhost:5102 (Chat interface for LLMs)
- **N8N**: http://localhost:5103 (User: `takerman`, Pass: `Hakerman91!`)

### Applications
- **Service Publish API**: http://localhost:8088 (TAKERMAN services)

## File Structure

```
/root/
├── volumes/                          # All container volumes
│   ├── devops/
│   │   ├── portainer/               # Portainer data
│   │   └── nginx-proxy-manager/     # Nginx config & SSL
│   ├── monitoring/
│   │   └── dozzle/                  # Log monitoring data
│   └── ai/
│       ├── jupyter/                 # Jupyter notebooks & config
│       ├── comfyui/                 # ComfyUI models & output
│       ├── ollama/                  # Ollama models
│       ├── openwebui/               # OpenWebUI data
│       └── n8n/                     # N8N workflows & data
├── server/                          # Repository clone
│   ├── docker-compose.yml          # Main service definitions
│   └── scripts/
│       ├── start_docker_services.sh # Auto-start script
│       └── takerman-docker.sh       # Management helper
```

## Management Commands

```bash
# Start all services
takerman-docker start

# Stop all services  
takerman-docker stop

# Restart services
takerman-docker restart

# Check service status
takerman-docker status

# View logs
takerman-docker logs
takerman-docker logs tool_jupyter

# Update all images
takerman-docker update

# Show service URLs
takerman-docker urls
```

## AI Libraries Available

All AI/ML libraries are available in the Jupyter container:
- **Core ML**: TensorFlow, PyTorch, scikit-learn
- **Transformers**: Hugging Face Transformers, Accelerate, Datasets
- **Computer Vision**: OpenCV, Pillow, Torchvision
- **Generative AI**: Diffusers for Stable Diffusion
- **Visualization**: Matplotlib, Seaborn, Plotly, Bokeh
- **Data Science**: Pandas, NumPy, SciPy
- **Development**: JupyterLab, Git integration, Code formatting
- **Deployment**: Gradio, Streamlit, FastAPI

## Security Features

- UFW firewall configured with specific port access
- SSH on port 1991 (non-standard)
- Container isolation
- Proper user permissions
- SSL/TLS support via Nginx Proxy Manager

## Installation Process

1. OS installation completes
2. `post_install.sh` sets up systemd service
3. `ai_setup_debian.sh` configures system and Docker
4. `start_docker_services.sh` initializes all containers
5. Services become available at specified ports

This setup provides a professional, scalable AI development environment with all modern ML libraries available through containerized services.