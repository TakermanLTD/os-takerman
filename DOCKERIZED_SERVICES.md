# 🐳 TAKERMAN AI Server - Dockerized Services Overview

## ✅ All Tools Are Fully Dockerized!

Every service in TAKERMAN AI Server runs in Docker containers with GPU support where needed.

---

## 📦 Complete Service List

### 🤖 AI & Machine Learning Services

| Service | Image | GPU Support | Port | Description |
|---------|-------|-------------|------|-------------|
| **Jupyter Lab** | `ghcr.io/takermanltd/takerman.jupyter:latest` | ✅ NVIDIA | 5104 (8888) | Python notebooks with PyTorch, TensorFlow, CUDA |
| **ComfyUI** | `ghcr.io/takermanltd/takerman.comfyui:latest` | ✅ NVIDIA | 5100 (8188) | AI image generation and Stable Diffusion |
| **Ollama** | `ollama/ollama:latest` | ✅ NVIDIA | 5101 (11434) | Local LLM server (Llama, Mistral, etc.) |
| **Open WebUI** | `ghcr.io/open-webui/open-webui:latest` | ✅ NVIDIA | 5102 (8080) | Chat interface for Ollama |

### 🔧 Workflow & Automation

| Service | Image | GPU Support | Port | Description |
|---------|-------|-------------|------|-------------|
| **N8N** | `n8nio/n8n:latest` | ✅ NVIDIA | 5103 (5678) | Workflow automation and API integration |

### 📊 Monitoring & Management

| Service | Image | GPU Support | Port | Description |
|---------|-------|-------------|------|-------------|
| **Grafana** | `grafana/grafana:latest` | ❌ | 3001 (3000) | Metrics visualization and dashboards |
| **Prometheus** | `prom/prometheus:latest` | ❌ | 9090 | Time-series database and metrics collection |
| **Node Exporter** | `prom/node-exporter:latest` | ❌ | 9100 | System metrics (CPU, RAM, disk, network) |
| **cAdvisor** | `gcr.io/cadvisor/cadvisor:latest` | ❌ | 8080 | Container metrics and resource usage |
| **Portainer** | `portainer/portainer-ce:latest` | ❌ | 9443 | Docker management web UI |
| **Dozzle** | `amir20/dozzle:latest` | ❌ | 8050 | Real-time Docker log viewer |

### 🎮 Optional GPU Monitoring

| Service | Image | GPU Support | Port | Description |
|---------|-------|-------------|------|-------------|
| **DCGM Exporter** | `nvcr.io/nvidia/k8s/dcgm-exporter:latest` | ✅ NVIDIA | 9400 | NVIDIA GPU metrics for Prometheus |

---

## 🔋 GPU Support Details

### NVIDIA Runtime Configuration

All GPU-enabled containers use:
- **Runtime**: `nvidia`
- **Environment Variables**:
  - `NVIDIA_VISIBLE_DEVICES=all`
  - `NVIDIA_DRIVER_CAPABILITIES=all` or `compute,utility`
  - `CUDA_VISIBLE_DEVICES=0` (or specific GPU)

### Docker Compose GPU Configuration

```yaml
services:
  tool_jupyter:
    runtime: nvidia
    environment:
      NVIDIA_VISIBLE_DEVICES: all
      NVIDIA_DRIVER_CAPABILITIES: all
      CUDA_VISIBLE_DEVICES: 0
    deploy:
      resources:
        reservations:
          generic_resources:
            - discrete_resource_spec:
                kind: "NVIDIA_GPU_5"
                value: 1
```

---

## 📊 Custom Built Images

### 1. Jupyter Lab (`takerman.jupyter`)

**Based on**: `jupyter/tensorflow-notebook:latest`

**Includes**:
- ✅ PyTorch with CUDA 12.1 support
- ✅ TensorFlow with GPU support
- ✅ Transformers, Diffusers, Accelerate
- ✅ OpenCV, Pillow, Matplotlib, Seaborn, Plotly
- ✅ Pandas, NumPy, SciPy, Scikit-learn
- ✅ JupyterLab extensions (Git, LSP, Code Formatter)
- ✅ Weights & Biases, TensorBoard, Gradio, Streamlit
- ✅ FastAPI, Uvicorn for API development

**Dockerfile**: `docker/Dockerfile.jupyter`

**Build Command**:
```bash
docker build -f docker/Dockerfile.jupyter -t ghcr.io/takermanltd/takerman.jupyter:latest .
```

### 2. ComfyUI (`takerman.comfyui`)

**Based on**: Custom CUDA-enabled Ubuntu

**Includes**:
- ✅ ComfyUI web interface
- ✅ Stable Diffusion models support
- ✅ Custom nodes and extensions
- ✅ CUDA 12.1 optimized
- ✅ Automatic model downloading
- ✅ Ollama integration for LLM-based workflows

**Dockerfile**: `docker/Dockerfile.comfyui`

**Build Command**:
```bash
docker build -f docker/Dockerfile.comfyui -t ghcr.io/takermanltd/takerman.comfyui:latest .
```

---

## 🚀 Starting Services

### All Services

```bash
cd /root/server
docker compose up -d
```

### AI Services Only

```bash
docker compose up -d ai_ollama ai_comfyui ai_openwebui tool_jupyter
```

### Monitoring Stack Only

```bash
docker compose up -d monitoring_grafana monitoring_prometheus monitoring_node_exporter monitoring_cadvisor
```

### Management Tools Only

```bash
docker compose up -d devops_portainer monitoring_dozzle
```

---

## 🔌 Offline Installation

### ✅ YES - Everything Can Be Pre-Downloaded!

**Problem**: Current mini.iso requires internet during installation

**Solution**: Use full ISO + pre-downloaded Docker images

### Step 1: Download Docker Images (On Internet-Connected Machine)

```bash
cd /root/server
bash docker/save_images_offline.sh
```

**This creates**: `build/docker-images-offline.tar.gz` (~15GB)

**Includes all images**:
- Jupyter Lab (~8GB)
- ComfyUI (~3GB)
- Ollama (~1GB)
- Open WebUI, N8N, Portainer, Dozzle, Grafana, Prometheus, etc. (~3GB)

### Step 2: Load Images (On Offline Machine)

```bash
# Copy docker-images-offline.tar.gz to offline machine via USB
bash docker/load_images_offline.sh
```

### Step 3: Start Services (No Internet Needed)

```bash
cd /root/server
docker compose up -d
```

---

## 📦 Image Sizes

| Image | Size | Download Time (100 Mbps) |
|-------|------|--------------------------|
| **takerman.jupyter** | ~8.5 GB | ~12 minutes |
| **takerman.comfyui** | ~3.2 GB | ~5 minutes |
| **ollama/ollama** | ~1.1 GB | ~2 minutes |
| **open-webui** | ~800 MB | ~1 minute |
| **n8n** | ~450 MB | ~45 seconds |
| **grafana** | ~350 MB | ~35 seconds |
| **prometheus** | ~250 MB | ~25 seconds |
| **portainer** | ~200 MB | ~20 seconds |
| **Other services** | ~1.5 GB | ~2 minutes |
| **TOTAL** | **~16 GB** | **~24 minutes** |

---

## 🔧 Building Custom Images

### Jupyter Lab

```bash
cd /root/server
docker build -f docker/Dockerfile.jupyter -t ghcr.io/takermanltd/takerman.jupyter:latest .
docker push ghcr.io/takermanltd/takerman.jupyter:latest
```

### ComfyUI

```bash
cd /root/server
docker build -f docker/Dockerfile.comfyui -t ghcr.io/takermanltd/takerman.comfyui:latest .
docker push ghcr.io/takermanltd/takerman.comfyui:latest
```

### PyTorch Test Image

```bash
cd /root/server
docker build -f docker/Dockerfile.pytorch -t ghcr.io/takermanltd/takerman.pytorch:latest .
docker push ghcr.io/takermanltd/takerman.pytorch:latest
```

---

## 🎯 Advantages of Dockerized Setup

### ✅ Benefits

1. **Isolation**: Each service runs independently
2. **Portability**: Move containers between servers easily
3. **Version Control**: Pin specific versions
4. **Easy Updates**: `docker compose pull && docker compose up -d`
5. **Resource Limits**: Control CPU/GPU/memory per container
6. **No Conflicts**: No dependency hell between services
7. **Reproducibility**: Same environment everywhere
8. **Backup/Restore**: Simple volume management
9. **Offline Capable**: Pre-download everything
10. **GPU Sharing**: Multiple containers can use same GPU

### 📊 Resource Management

```yaml
# Example: Limit CPU and memory
services:
  ai_ollama:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 16G
        reservations:
          memory: 8G
```

---

## 🔄 Common Operations

### Update All Services

```bash
cd /root/server
docker compose pull
docker compose up -d
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f tool_jupyter

# Using Dozzle (Web UI)
# Visit: http://YOUR_IP:8050
```

### Restart Services

```bash
# All services
docker compose restart

# Specific service
docker compose restart tool_jupyter
```

### Stop All Services

```bash
docker compose down
```

### Clean Up

```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Complete cleanup
docker system prune -a -f --volumes
```

---

## 📝 Configuration Files

All services store data in: `/root/volumes/`

```
/root/volumes/
├── ai/
│   ├── ollama/          # Ollama models
│   ├── comfyui/         # ComfyUI models and outputs
│   ├── jupyter/         # Jupyter notebooks and data
│   ├── openwebui/       # Open WebUI data
│   └── n8n/             # N8N workflows and data
├── monitoring/
│   ├── grafana/         # Grafana dashboards and config
│   ├── prometheus/      # Prometheus data and config
│   └── dozzle/          # Dozzle settings
└── devops/
    └── portainer/       # Portainer data
```

---

## 🎓 Summary

**Answer to "Are tools dockerized?"**: 

# ✅ YES - 100% DOCKERIZED!

Every single tool, service, and application runs in Docker containers with:
- GPU support where needed (Jupyter, ComfyUI, Ollama)
- Persistent storage in `/root/volumes/`
- Easy management via `docker compose`
- Offline installation capability
- Professional monitoring with Grafana + Prometheus

**No system-wide package conflicts, no dependency issues, complete isolation!**

---

**Need help?** See `Documentation.md` for detailed usage instructions.
