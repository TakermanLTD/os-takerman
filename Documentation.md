# 📚 TAKERMAN AI Server - User Documentation

Complete guide for using and managing your TAKERMAN AI Server.

---

## 🔐 Default Credentials

**CRITICAL: Change these immediately after first login!**

| Service | Username | Password | Port |
|---------|----------|----------|------|
| **Root SSH** | `root` | `(set during installation)` | 22 |
| **N8N Workflow** | `takerman` | `Hakerman91!` | 5103 |

### 🚨 First Login Steps

```bash
# 1. SSH into your server
ssh root@YOUR_SERVER_IP
# Enter the password you set during installation

# 2. View system dashboard
takstats

# 3. View system dashboard
takstats
```

---

## 🌐 Network Configuration

### Default Settings
- **Hostname**: `TAKERMAN`
- **Domain**: `takerman.net`
- **Network**: DHCP (automatic IP assignment)
- **Timezone**: UTC
- **Locale**: en_US.UTF-8

### Finding Your Server IP

```bash
# Method 1: Quick IP check
hostname -I

# Method 2: Detailed network info
ip addr show

# Method 3: Using TAKERMAN alias
taknet
```

### Changing Hostname

```bash
# Set new hostname
hostnamectl set-hostname your-new-hostname

# Edit hosts file
nano /etc/hosts
# Update: 127.0.1.1 your-new-hostname

# Reboot to apply
takreboot
```

### Setting Static IP

```bash
# Edit network configuration
nano /etc/network/interfaces

# Add static configuration:
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4

# Restart networking
systemctl restart networking
```

---

## 🎮 GPU Management

### Check GPU Status

```bash
# Quick GPU info
takgpu
# or
nvidia-smi

# Real-time GPU monitoring
takgpuwatch
# Updates every second

# Detailed GPU stats with color
takgpustats

# Interactive GPU monitor
taknvtop

# Check GPU temperature
takgputemp
```

### GPU Information

```bash
# List all GPUs
nvidia-smi -L

# Detailed GPU query
nvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.free,temperature.gpu,utilization.gpu --format=csv

# GPU memory usage
nvidia-smi --query-gpu=memory.used,memory.total --format=csv
```

### Test GPU with Docker

```bash
# Run CUDA test container
docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu20.04 nvidia-smi

# Test PyTorch with GPU
docker run --rm --gpus all pytorch/pytorch:latest python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'GPU Count: {torch.cuda.device_count()}')"
```

---

## 🐳 Docker Management

### Docker Services

The server comes with pre-configured Docker services:

| Service | Port | Description |
|---------|------|-------------|
| **Jupyter Lab** | 8888 | Python notebooks with GPU support |
| **ComfyUI** | 8188 | AI image generation interface |
| **TensorBoard** | 6006 | ML experiment tracking |
| **N8N** | 5103 | Workflow automation |
| **Grafana** | 3001 | Monitoring dashboards and metrics visualization |
| **Prometheus** | 9090 | Metrics collection and time-series database |
| **Portainer** | 9443 | Docker container management UI |
| **Dozzle** | 8050 | Real-time Docker log viewer |

### Starting Services

```bash
# Navigate to server directory
cd /root/server

# Start all services
takup
# or
docker compose up -d

# Start specific service
docker compose up -d jupyter

# View logs
taklogs
# or
docker compose logs -f jupyter
```

### Managing Containers

```bash
# List running containers
takps
# or
docker ps

# List all containers (including stopped)
takpsa

# Stop all containers
takstop

# Stop specific container
docker stop <container_name>

# Restart a container
docker restart <container_name>

# Remove stopped containers
docker container prune

# Full cleanup (containers, images, volumes)
takclean
```

### Docker Images

```bash
# List images
takimages
# or
docker images

# Pull latest image
docker pull ghcr.io/takermanltd/takerman.jupyter:latest

# Remove unused images
docker image prune -a

# Check Docker disk usage
docker system df
```

### Docker Compose Management

```bash
# View docker-compose.yml
cat /root/server/docker-compose.yml

# Rebuild services
docker compose build

# Update and restart services
docker compose pull
docker compose up -d

# Stop and remove everything
takdown
# or
docker compose down
```

---

## 📊 System Monitoring

### TAKERMAN Dashboard

```bash
# Show system stats dashboard
takstats

# Dashboard shows:
# - Hostname and uptime
# - CPU model, cores, and usage
# - Memory usage
# - GPU info and temperature
# - Disk usage
# - Network IP
# - Docker containers
```

### Resource Monitoring

```bash
# CPU monitoring
taktop        # Interactive process viewer (htop)
top           # Standard process viewer

# I/O monitoring
takiot        # Disk I/O monitor (iotop)
iotop         # Standard version

# Network monitoring
taknet        # Network bandwidth monitor
netstat -tulpn  # Active connections

# Temperature monitoring
taktemp       # All sensors (CPU, GPU, etc.)
sensors       # Standard sensors output

# Memory usage
takmem        # Human-readable memory info
free -h       # Standard memory info

# Disk usage
takdisk       # Disk usage summary
df -h         # Standard disk usage
du -sh /path  # Directory size
```

### System Information

```bash
# CPU info
takcpu
lscpu

# Kernel version
uname -a

# Debian version
cat /etc/debian_version
lsb_release -a

# Installed packages
dpkg -l
apt list --installed
```

---

## 🛡️ Security & Firewall

### Firewall (UFW)

```bash
# Check firewall status
takfw
# or
ufw status verbose

# Enable firewall
ufw enable

# Common rules
ufw allow 22/tcp        # SSH
ufw allow 8888/tcp      # Jupyter Lab
ufw allow 8188/tcp      # ComfyUI
ufw allow 1194/udp      # OpenVPN

# Delete rule
ufw delete allow 8888/tcp

# Reset firewall
ufw reset
```

### Fail2Ban (Brute Force Protection)

```bash
# Check Fail2Ban status
takfail
# or
fail2ban-client status

# Check SSH jail
fail2ban-client status sshd

# Unban an IP
fail2ban-client set sshd unbanip <IP_ADDRESS>

# View banned IPs
fail2ban-client get sshd banned
```

### SSH Configuration

```bash
# Check SSH service
takssh
# or
systemctl status sshd

# Edit SSH config
nano /etc/ssh/sshd_config

# Recommended changes:
# PermitRootLogin no              # Disable after creating admin user
# PasswordAuthentication no       # Use SSH keys only
# Port 2222                        # Change default port

# Restart SSH after changes
systemctl restart sshd
```

### Active Connections

```bash
# View open ports
takports
# or
netstat -tulpn
ss -tulpn

# View active SSH sessions
who
w
last
```

---

## 🔧 System Administration

### System Control

```bash
# Reboot server
takreboot
# or
systemctl reboot

# Shutdown server
takshutdown
# or
systemctl poweroff

# View running services
takservices
# or
systemctl list-units --type=service --state=running

# Check specific service
systemctl status docker
systemctl status sshd
```

### Package Management

```bash
# Update package list
apt update

# Upgrade packages
apt upgrade -y

# Full system update
takupdate
# or
apt update && apt upgrade -y

# Install package
apt install <package_name>

# Remove package
apt remove <package_name>

# Search for package
apt search <keyword>

# Show package info
apt show <package_name>
```

### Log Viewing

```bash
# TAKERMAN AI setup log
taklog
# or
tail -f /var/log/takerman/ai-server.log

# System errors
takerror
# or
journalctl -f -p err

# Docker logs
docker logs <container_name>
docker logs -f <container_name>  # Follow mode

# SSH login attempts
tail -f /var/log/auth.log

# System log
journalctl -f
journalctl -u docker    # Specific service
```

### Disk Management

```bash
# Check disk space
takdisk
df -h

# Find large files
du -h /var | sort -rh | head -20

# Check inode usage
df -i

# Clean APT cache
apt clean
apt autoclean

# Remove old kernels
apt autoremove
```

---

## 🤖 AI Development

### Jupyter Lab

**Access**: `http://YOUR_SERVER_IP:8888`

```bash
# Start Jupyter
cd /root/server
docker compose up -d jupyter

# View Jupyter logs
docker logs -f jupyter

# Get Jupyter token (if needed)
docker exec jupyter jupyter server list

# Install Python packages in Jupyter
docker exec jupyter pip install <package_name>
```

### ComfyUI

**Access**: `http://YOUR_SERVER_IP:8188`

```bash
# Start ComfyUI
docker compose up -d comfyui

# View ComfyUI logs
docker logs -f comfyui

# Access ComfyUI shell
docker exec -it comfyui bash
```

### Python Environment

```bash
# Python version
python3 --version

# Install packages system-wide
pip3 install --break-system-packages <package>

# Create virtual environment
python3 -m venv /root/myenv
source /root/myenv/bin/activate

# Install in virtual environment
pip install torch torchvision torchaudio
```

### CUDA and PyTorch

```bash
# Check CUDA version
nvcc --version

# Test PyTorch GPU
python3 << EOF
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")
print(f"GPU count: {torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"GPU name: {torch.cuda.get_device_name(0)}")
EOF
```

---

## 📊 Grafana Monitoring

### Access Grafana

**URL**: `http://YOUR_SERVER_IP:3001`

**Default Credentials**:
- Username: `takerman`
- Password: `Hakerman91!`

### Initial Setup

```bash
# Setup Grafana configuration
bash /root/server/scripts/setup_grafana.sh

# Start monitoring stack
cd /root/server
docker compose up -d monitoring_grafana monitoring_prometheus monitoring_node_exporter monitoring_cadvisor
```

### Pre-configured Datasources

Grafana comes with Prometheus pre-configured as the default datasource:
- **Name**: Prometheus
- **URL**: http://monitoring_prometheus:9090
- **Type**: Prometheus

### Importing Dashboards

```bash
# Access Grafana web interface
# Go to: Dashboards → Import

# Recommended Dashboard IDs:
```

**System Monitoring**:
1. **1860** - Node Exporter Full (CPU, RAM, Disk, Network)
2. **11074** - Node Exporter for Prometheus Dashboard
3. **12486** - Node Exporter Full (Alternative)

**Docker Monitoring**:
1. **11600** - Docker Container & Host Metrics
2. **193** - Docker Monitoring
3. **395** - Docker Dashboard

**GPU Monitoring** (requires NVIDIA DCGM Exporter):
1. **14574** - NVIDIA GPU Metrics
2. **12239** - NVIDIA DCGM Exporter Dashboard

### Installing NVIDIA DCGM Exporter for GPU Metrics

```bash
# Add DCGM exporter to monitor GPU metrics in Grafana
docker run -d --gpus all \
  --name=dcgm-exporter \
  --restart=unless-stopped \
  -p 9400:9400 \
  nvcr.io/nvidia/k8s/dcgm-exporter:3.1.3-3.1.4-ubuntu20.04

# Add to Prometheus config
cat >> /root/volumes/monitoring/prometheus/config/prometheus.yml << 'EOF'

  - job_name: 'nvidia-dcgm'
    static_configs:
      - targets: ['172.17.0.1:9400']
        labels:
          instance: 'takerman-gpu'
          service: 'gpu'
EOF

# Restart Prometheus
docker restart monitoring_prometheus

# Wait 30 seconds, then import dashboard 14574 in Grafana
```

### Creating Custom Dashboards

**Example: AI Workload Dashboard**

1. **CPU Usage Panel**:
```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

2. **Memory Usage Panel**:
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

3. **GPU Temperature**:
```promql
DCGM_FI_DEV_GPU_TEMP
```

4. **GPU Utilization**:
```promql
DCGM_FI_DEV_GPU_UTIL
```

5. **Docker Container Count**:
```promql
count(container_last_seen)
```

### Prometheus Queries

Access Prometheus directly at: `http://YOUR_SERVER_IP:9090`

**Useful Queries**:

```promql
# System CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# System memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
(node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_avail_bytes{mountpoint="/"}) / node_filesystem_size_bytes{mountpoint="/"} * 100

# Network traffic (received)
rate(node_network_receive_bytes_total[5m])

# Network traffic (transmitted)
rate(node_network_transmit_bytes_total[5m])

# Docker container CPU usage
rate(container_cpu_usage_seconds_total[5m]) * 100

# Docker container memory usage
container_memory_usage_bytes

# GPU memory used (with DCGM)
DCGM_FI_DEV_FB_USED

# GPU power usage (with DCGM)
DCGM_FI_DEV_POWER_USAGE
```

### Setting Up Alerts

```bash
# Create alerts directory
mkdir -p /root/volumes/monitoring/prometheus/alerts

# Create alert rules
cat > /root/volumes/monitoring/prometheus/alerts/system.yml << 'EOF'
groups:
  - name: system_alerts
    interval: 30s
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for 5 minutes"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 90%"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Disk space is below 10%"
EOF

# Update prometheus.yml to include alerts
# Add this line under rule_files:
#   - "alerts/*.yml"

# Restart Prometheus
docker restart monitoring_prometheus
```

### Grafana Tips

**Change Admin Password**:
```bash
docker exec -it monitoring_grafana grafana-cli admin reset-admin-password NEW_PASSWORD
```

**Backup Grafana Data**:
```bash
tar czf grafana-backup-$(date +%Y%m%d).tar.gz /root/volumes/monitoring/grafana/
```

**Install Additional Plugins**:
```bash
docker exec -it monitoring_grafana grafana-cli plugins install grafana-worldmap-panel
docker restart monitoring_grafana
```

---

## 🔌 OpenVPN Server Setup

OpenVPN is pre-installed but needs configuration.

### Quick Setup

```bash
# Navigate to Easy-RSA
cd /usr/share/easy-rsa

# Initialize PKI
./easyrsa init-pki

# Build CA
./easyrsa build-ca

# Generate server certificate
./easyrsa build-server-full server nopass

# Generate Diffie-Hellman parameters
./easyrsa gen-dh

# Generate client certificate
./easyrsa build-client-full client1 nopass

# Copy certificates
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

# Create server config
nano /etc/openvpn/server.conf
```

### Basic OpenVPN Server Config

```conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 3
```

### Start OpenVPN

```bash
# Start OpenVPN server
systemctl start openvpn@server

# Enable on boot
systemctl enable openvpn@server

# Check status
systemctl status openvpn@server

# View logs
journalctl -u openvpn@server -f
```

---

## 📝 Useful TAKERMAN Commands

### Complete Command Reference

#### GPU Management
```bash
takgpu          # Show GPU status (nvidia-smi)
takgpuwatch     # Real-time GPU monitoring
takgpustats     # GPU stats with gpustat
taknvtop        # Interactive GPU monitor
takgputemp      # Show GPU temperature
```

#### Docker Management
```bash
takdocker       # Docker command shortcut
takps           # List running containers
takpsa          # List all containers
takimages       # List Docker images
takstop         # Stop all containers
takclean        # Clean Docker system
takcompose      # Docker Compose shortcut
takup           # Start services (docker compose up -d)
takdown         # Stop services (docker compose down)
taklogs         # View service logs
```

#### System Monitoring
```bash
takstats        # Show TAKERMAN dashboard
taktop          # Process monitor (htop)
takiot          # I/O monitor (iotop)
taknet          # Network monitor (iftop)
taktemp         # Temperature sensors
takdisk         # Disk usage
takmem          # Memory usage
takcpu          # CPU information
```

#### Security & Network
```bash
takports        # Show open ports
takfw           # Firewall status
takfail         # Fail2Ban status
takssh          # SSH service status
```

#### System Control
```bash
takreboot       # Reboot server
takshutdown     # Shutdown server
takservices     # List running services
takupdate       # Update system packages
```

#### Logs & Troubleshooting
```bash
taklog          # View TAKERMAN setup log
takerror        # View system errors
takconfig       # Go to config directory
```

#### Help
```bash
takhelp         # Show all TAKERMAN commands
```

---

## 🔄 Common Tasks

### Updating NVIDIA Drivers

```bash
# Check current driver
nvidia-smi

# Update drivers
apt update
apt upgrade nvidia-driver

# Reboot after update
takreboot
```

### Adding New User (Recommended)

```bash
# Create new admin user
adduser admin

# Add to sudo group
usermod -aG sudo admin

# Add to docker group
usermod -aG docker admin

# Test new user
su - admin

# Then disable root SSH login
nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
systemctl restart sshd
```

### Backup Important Data

```bash
# Backup Docker volumes
docker run --rm -v /var/lib/docker/volumes:/backup -v $(pwd):/output ubuntu tar czf /output/docker-volumes-backup.tar.gz /backup

# Backup configuration
tar czf takerman-config-backup.tar.gz /root/.takerman /etc/docker /etc/openvpn

# Backup user data
rsync -avz /root/ backup-user@backup-server:/backups/takerman/
```

### Troubleshooting GPU Issues

```bash
# Reload NVIDIA driver
rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia
modprobe nvidia
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm

# Verify NVIDIA kernel modules
lsmod | grep nvidia

# Check NVIDIA driver logs
dmesg | grep -i nvidia

# Reinstall NVIDIA Container Toolkit
apt-get install --reinstall nvidia-container-toolkit
systemctl restart docker
```

### Performance Tuning

```bash
# Set GPU persistence mode
nvidia-smi -pm 1

# Set GPU power limit (example: 250W)
nvidia-smi -pl 250

# Set GPU application clocks
nvidia-smi -ac 5001,1590

# Disable swap for better performance
swapoff -a
nano /etc/fstab  # Comment out swap line
```

---

## 📞 Support & Resources

### Important Files & Locations

| Path | Description |
|------|-------------|
| `/root/.takerman/` | TAKERMAN configuration directory |
| `/root/server/` | Server repository with docker-compose.yml |
| `/var/log/takerman/` | TAKERMAN logs |
| `/etc/docker/` | Docker configuration |
| `/etc/openvpn/` | OpenVPN configuration |
| `/root/.bashrc` | Shell configuration with aliases |
| `/root/.takerman_aliases` | TAKERMAN command aliases |

### Service URLs (Local Access)

After starting services with `takup`:

- **Jupyter Lab**: http://YOUR_SERVER_IP:8888
- **ComfyUI**: http://YOUR_SERVER_IP:8188
- **TensorBoard**: http://YOUR_SERVER_IP:6006
- **N8N Workflow**: http://YOUR_SERVER_IP:5103
- **Grafana**: http://YOUR_SERVER_IP:3001 (User: takerman, Pass: Hakerman91!)
- **Prometheus**: http://YOUR_SERVER_IP:9090
- **Portainer**: https://YOUR_SERVER_IP:9443
- **Dozzle**: http://YOUR_SERVER_IP:8050

### Quick Diagnostics

```bash
# System health check
echo "=== System Info ==="
uname -a
echo "=== GPU Status ==="
nvidia-smi
echo "=== Docker Status ==="
docker ps
echo "=== Disk Space ==="
df -h
echo "=== Memory ==="
free -h
echo "=== Network ==="
ip addr
```

---

## ⚠️ Important Notes

1. **🔐 Security First**: Change default passwords immediately!
2. **🔄 Regular Updates**: Run `takupdate` weekly
3. **💾 Backup Data**: Important data should be backed up regularly
4. **🌡️ Monitor Temperatures**: Keep an eye on GPU temps with `takgputemp`
5. **🧹 Clean Docker**: Run `takclean` monthly to free space
6. **📊 Check Logs**: Review `taklog` if services fail
7. **🔥 Firewall**: Keep UFW enabled with only necessary ports open
8. **🎮 GPU Care**: Use persistence mode for stability: `nvidia-smi -pm 1`

---

**TAKERMAN AI Server** - Built for High-Performance AI Workloads  
🌐 https://takerman.net/projects/os

Last Updated: October 2025
