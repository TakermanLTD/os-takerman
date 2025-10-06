# 🚀 TAKERMAN AI Server

**Automated Debian installer for AI workloads with NVIDIA GPU support**

Build a custom Debian ISO that automatically installs and configures a complete AI server environment with Docker, NVIDIA drivers, and popular AI services.

## ✨ Features

- 🔧 **Fully Automated**: Unattended installation with preseed
- 🐋 **Docker Ready**: Pre-configured Docker and Docker Compose  
- 🎮 **NVIDIA Support**: Automatic GPU driver detection and installation
- 🤖 **AI Services**: Ollama (LLM), Jupyter Lab, ComfyUI included
- 🛡️ **Secure**: UFW firewall pre-configured
- 📊 **Management Tools**: Portainer and Dozzle for easy monitoring
- ⚡ **Simple Commands**: Easy `tak*` aliases for common tasks

## 🚀 Quick Start

### 1. Build the ISO

```bash
bash build.sh
```

This downloads Debian, customizes it, and creates `build/TAKERMAN-AI-SERVER.iso`

**Requirements**: Linux system with `wget`, `xorriso`, `genisoimage`

### 2. Install the OS

Write ISO to USB drive:
```bash
sudo dd if=build/TAKERMAN-AI-SERVER.iso of=/dev/sdX bs=4M status=progress
```

Or use tools like [Etcher](https://etcher.balena.io/), [Rufus](https://rufus.ie/), or [Ventoy](https://www.ventoy.net/)

Boot from USB and installation runs automatically (~5 minutes)

**Default credentials**: `root` / `takerman`

### 3. Setup AI Environment

After first boot, SSH into the server and run:

```bash
bash /root/setup.sh
```

This installs:
- Docker & Docker Compose
- NVIDIA drivers (if GPU detected)
- Firewall configuration
- TAKERMAN command aliases

### 4. Start AI Services

```bash
cd /root/server
docker compose up -d
```

## 📦 Included Services

Access services via `http://YOUR-SERVER-IP:PORT`

| Service | Port | Description | GPU |
|---------|------|-------------|-----|
| **Portainer** | 9443 | Docker management UI | ❌ |
| **Dozzle** | 8050 | Real-time log viewer | ❌ |
| **Jupyter Lab** | 8888 | Python notebooks with PyTorch | ✅ |
| **ComfyUI** | 8188 | Stable Diffusion workflow UI | ✅ |
| **Ollama** | 11434 | Local LLM server | ✅ |

**Note**: GPU services require NVIDIA GPU and drivers installed by `setup.sh`

## 🎯 TAKERMAN Commands

After running `setup.sh`, use these convenient aliases:

```bash
takstats    # Show system status (Docker containers, GPU)
takhelp     # List all TAKERMAN commands
takup       # Start all services (docker compose up -d)
takdown     # Stop all services (docker compose down)
taklogs     # View service logs (docker compose logs -f)
takps       # List running containers (docker ps)
takgpu      # Show GPU status (nvidia-smi)
```

## 📁 Repository Structure

```
os-takerman/
├── build.sh              # ISO builder script
├── setup.sh              # Post-install setup script
├── docker-compose.yml    # AI services configuration
├── configs/
│   └── preseed.cfg       # Automated installation config
├── build/                # Build output directory
│   └── TAKERMAN-AI-SERVER.iso
└── old_backup/           # Previous version files (backup)
```

## ⚙️ Customization

### Change Default Password

Edit `configs/preseed.cfg`:
```
d-i passwd/root-password password YOUR_PASSWORD
d-i passwd/root-password-again password YOUR_PASSWORD
```

### Add/Remove Services

Edit `docker-compose.yml` to add or remove containers.

### Change Hostname

Edit `configs/preseed.cfg`:
```
d-i netcfg/get_hostname string YOUR_HOSTNAME
```

### Modify Packages

Edit `configs/preseed.cfg` to change installed packages:
```
d-i pkgsel/include string curl wget git vim YOUR_PACKAGES
```

## 🔧 System Requirements

### Build System (to create ISO)
- Linux OS (Debian/Ubuntu recommended)
- 10GB free disk space
- Internet connection
- Root/sudo access

### Target System (to install on)
- x86_64 (AMD64) architecture
- 8GB+ RAM (16GB+ recommended for AI)
- 50GB+ disk space
- Optional: NVIDIA GPU (for GPU-accelerated AI)

## 🐛 Troubleshooting

### Build Issues

**Dependencies missing:**
```bash
sudo apt update
sudo apt install -y wget xorriso genisoimage isolinux syslinux-utils
```

**ISO download fails:**
- Check internet connection
- Manually download from [Debian.org](https://www.debian.org/distrib/netinst)
- Place as `build/debian-netinst-amd64.iso`

### Installation Issues

**Installation stuck:**
- Ensure network connection (required for packages)
- Try again with different network/mirror

**Can't login:**
- Default password is `takerman`
- Reset by booting into recovery mode

### Post-Install Issues

**Docker not starting:**
```bash
systemctl status docker
systemctl start docker
```

**GPU not detected:**
```bash
lspci | grep -i nvidia    # Check if GPU is visible
nvidia-smi                # Check driver installation
```

**Services won't start:**
```bash
cd /root/server
docker compose logs       # Check error messages
docker compose down
docker compose up -d
```

## 🔒 Security Notes

⚠️ **Change the default password immediately after installation!**

```bash
passwd root
```

The firewall is pre-configured with these allowed ports:
- 22 (SSH)
- 8888 (Jupyter)
- 8188 (ComfyUI)
- 9443 (Portainer)
- 8050 (Dozzle)
- 11434 (Ollama)

Modify firewall rules:
```bash
ufw status
ufw allow PORT/tcp
ufw deny PORT/tcp
```

## 📚 Additional Documentation

- `QUICKSTART.md` - Quick reference guide
- `SIMPLIFICATION.md` - Details about the simplified architecture
- `SUMMARY.md` - Complete changelog from previous version

## 🤝 Contributing

Issues and pull requests welcome at [GitHub](https://github.com/TakermanLTD/os-takerman)

## 📄 License

MIT License - Feel free to use and modify

## 🙏 Credits

Built on:
- [Debian GNU/Linux](https://www.debian.org/)
- [Docker](https://www.docker.com/)
- [Ollama](https://ollama.ai/)
- [Jupyter](https://jupyter.org/)
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [Portainer](https://www.portainer.io/)
- [Dozzle](https://dozzle.dev/)

---

**Made with ❤️ by TAKERMAN**

*Simplified architecture for maximum reliability and ease of use*
