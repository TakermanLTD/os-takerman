# 🚀 TAKERMAN AI Server - Custom Debian ISO Builder

This project creates a **TAKERMAN** branded, minimal Debian ISO that automatically installs and configures a high-performance AI server environment optimized for NVIDIA GPU workloads.

## 🎯 Overview

The **TAKERMAN AI SERVER** ISO provides:
- **🔥 Minimal Installation**: Ultra-lean Debian 12 (Bookworm) base optimized for AI workloads
- **🎮 NVIDIA GPU Ready**: Latest drivers, CUDA toolkit, and Docker GPU support
- **🛡️ Root-Only System**: Secure single-user environment with 'password' default password
- **🎨 Custom Branding**: TAKERMAN branded boot screen and system
- **📊 Smart Dashboard**: System stats display on login with GPU/CPU/memory info
- **⚡ Performance Optimized**: Docker, OpenVPN, and AI tools pre-configured
- **💻 Tak Commands**: 30+ useful aliases starting with 'tak' prefix
- **🤖 Fully Automated**: Zero-touch installation with preseed automation

## Files Structure

```
iso-builder/
├── build_custom_iso.sh          # Main ISO building script
├── configs/
│   └── preseed.cfg              # Debian installer automation config
├── scripts/
│   ├── ai_setup_debian.sh       # Debian-compatible AI setup script
│   └── post_install.sh          # Post-installation service setup
├── build/                       # Build artifacts (created during build)
│   ├── .gitignore
│   └── [generated files]
└── README.md                    # This file
```

## Prerequisites

### System Requirements
- Linux system (Debian/Ubuntu recommended)
- At least 4GB RAM
- 10GB free disk space
- Internet connection for downloads

### Dependencies
The build script will automatically install these if missing:
- `wget` - For downloading the base Debian mini.iso
- `xorriso` - For ISO creation and manipulation
- `isolinux` - For BIOS boot support (isolinux.bin, ldlinux.c32)
- `cpio` - For initrd extraction and repacking
- `gzip` - For compressing/decompressing initrd

## Building the Custom ISO

### 1. Prepare Environment

```bash
# Navigate to the ISO builder directory
cd /path/to/server/iso-builder

# Make the build script executable
chmod +x build_custom_iso.sh
```

### 2. Customize Configuration (Optional)

Before building, you may want to customize:

**Default Passwords** (in `configs/preseed.cfg`):
```bash
# Edit the preseed configuration
nano configs/preseed.cfg

# Change the root password (currently set to 'password'):
d-i passwd/root-password password YOUR_ROOT_PASSWORD
d-i passwd/root-password-again password YOUR_ROOT_PASSWORD

# Note: This is a root-only system (no regular user created)
```

**Network Configuration**:
```bash
# Edit hostname and domain
d-i netcfg/get_hostname string your-hostname
d-i netcfg/get_domain string your-domain.com
```

**GitHub Token** (in `scripts/ai_setup_debian.sh`):
```bash
# For private repository access, set the GITHUB_TOKEN environment variable
# or modify the script to include your token
```

### 3. Build the ISO

```bash
# Run the build script
./build_custom_iso.sh
```

The script will:
1. Check and install dependencies
2. Download the Debian 12 (Bookworm) mini.iso (~62MB)
3. Extract and customize the ISO contents
4. **Dynamically detect kernel and initrd paths** (handles different ISO structures)
5. **Inject preseed.cfg into initrd** (required for mini.iso automated installation)
6. Add the AI setup scripts and custom configurations
7. Configure bootloader for both BIOS (ISOLINUX) and UEFI (GRUB)
8. Rebuild the ISO with custom bootloader configuration
9. Generate MD5 and SHA256 checksums for verification

### 4. Build Output

After successful completion, you'll find in the `build/` directory:
- `TAKERMAN-AI-SERVER-debian-12-amd64.iso` - The custom ISO (~62MB)
- `TAKERMAN-AI-SERVER-debian-12-amd64.iso.md5` - MD5 checksum
- `TAKERMAN-AI-SERVER-debian-12-amd64.iso.sha256` - SHA256 checksum

## Using the Custom ISO

### 1. Create Bootable Media

**USB Drive (Linux)**:
```bash
# Replace /dev/sdX with your USB drive device
sudo dd if=build/TAKERMAN-AI-SERVER-debian-12-amd64.iso of=/dev/sdX bs=4M status=progress
sync
```

**USB Drive (Windows)**:
- Use tools like Rufus, balenaEtcher, or similar
- Select the custom ISO file
- Write to USB drive in DD mode

### 2. Installation Process

1. **Boot from USB/CD**: Boot the target machine from the created media
2. **Automatic Installation**: The installer will start automatically after 5 seconds
3. **Hands-free Setup**: The installation proceeds without user intervention
4. **First Boot**: After installation, the system will reboot and automatically run the AI setup

### 3. Post-Installation

After the installation completes:

**🔐 Root Access Credentials**:
- Username: `root`
- Password: `password` (⚠️ **CHANGE THIS IMMEDIATELY AFTER FIRST LOGIN**)

**🌐 Default Services**:
- SSH: Port 22 (password authentication enabled)
- Jupyter Lab: Port 8888 (auto-configured)
- TensorBoard: Port 6006 (ready for AI workloads)
- OpenVPN: Port 1194 (server template included)

**🔗 Access Your TAKERMAN Server**:
```bash
# SSH to your server
ssh root@your-server-ip
# Password: password (change this immediately!)

# You'll immediately see the TAKERMAN dashboard with system stats!
```

**✅ Verify Installation**:
```bash
# Check GPU status
takgpu                    # or nvidia-smi

# View system dashboard  
takstats                  # Beautiful system overview

# Check Docker with GPU
docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu20.04 nvidia-smi

# See all TAKERMAN commands
takhelp

# Quick system overview
takquick

# View setup log
tail -f /var/log/takerman/ai-server.log
```

**🎮 TAKERMAN Commands (30+ aliases)**:
```bash
# GPU Management
takgpu, takgpuwatch, takgpustats, taknvtop, takgputemp

# Docker Management  
takdocker, takps, takimages, takup, takdown, taklogs, takclean

# System Monitoring
takstats, taktop, takiot, taknet, taktemp, takdisk, takmem

# Security & Network
takports, takfw, takfail, takssh

# System Control
takreboot, takshutdown, takservices, takupdate
```

## Customization Options

### Modifying the AI Setup Script

Edit `scripts/ai_setup_debian.sh` to customize:
- Package installations
- Service configurations
- Directory structures
- Docker configurations
- Security settings

### Adding Additional Files

1. Place files in the `configs/` directory
2. Modify `build_custom_iso.sh` to copy them to the ISO
3. Update `scripts/post_install.sh` or `ai_setup_debian.sh` to use them

### Changing Installation Behavior

Edit `configs/preseed.cfg` to modify:
- Partitioning scheme
- Package selection
- Network configuration
- User accounts
- Regional settings

## Troubleshooting

### Build Issues

**Missing Dependencies**:
```bash
# Manually install build dependencies
sudo apt-get update
sudo apt-get install wget genisoimage syslinux-utils xorriso isolinux
```

**Permission Errors**:
```bash
# Ensure proper permissions
chmod +x build_custom_iso.sh
# Don't run as root unless necessary
```

**Download Failures**:
- Check internet connection
- Verify Debian mirror availability
- Try building again (script supports resuming downloads)

### Installation Issues

**Boot Problems**:
- Verify USB/CD creation process
- Check BIOS/UEFI boot order
- Try different USB creation tools
- **For VirtualBox**: Use "Expert Mode" during VM creation, NOT "Unattended Install"
  - Unattended install conflicts with preseed automation
  - Let the ISO handle the automated installation

**Common Boot Errors (Already Fixed in Build Script)**:
- ❌ "no such file or directory /install.amd/vmlinuz" - Fixed via dynamic kernel path detection
- ❌ "failed to retrieve preconfiguration file" - Fixed via preseed injection into initrd
- ❌ "cannot mount /mnt/fb0" - Fixed by removing VGA framebuffer parameter

**Network Issues During Installation**:
- Ensure network cable is connected
- Check DHCP availability
- Modify preseed.cfg for static IP if needed

**AI Setup Failures**:
```bash
# Check the setup log
sudo journalctl -u custom-ai-setup.service -f

# Manual setup if needed
sudo /tmp/custom-install/ai_setup_debian.sh
```

### Post-Installation Issues

**Docker GPU Access**:
```bash
# Verify NVIDIA Container Toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Test GPU access
docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu20.04 nvidia-smi
```

**SSH Access**:
```bash
# Check SSH service and configuration
sudo systemctl status sshd
sudo nano /etc/ssh/sshd_config

# Verify firewall settings
sudo ufw status
```

## Security Considerations

### Default Settings
- ⚠️ **Default password is 'password' - EXTREMELY WEAK**
- SSH password authentication is enabled by default
- Firewall (UFW) is enabled with limited ports
- Root login is allowed initially but should be disabled after setup
- **CRITICAL**: Change the default password immediately after first login

### Hardening Steps
1. **🚨 IMMEDIATELY Change Default Password**:
```bash
# Change root password from 'password' to something secure
passwd root

# Note: No regular user exists (root-only system)
```

2. **Disable Root SSH** (after setting up key authentication):
```bash
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

3. **Configure SSH Keys**:
```bash
# Generate new SSH key pair
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key to server
ssh-copy-id -p 1991 takerman@your-server-ip
```

4. **Update System**:
```bash
sudo apt update && sudo apt upgrade -y
```

## Advanced Configuration

### Custom Docker Configuration

Edit `/etc/docker/daemon.json` after installation to customize Docker settings:
```json
{
    "default-runtime": "nvidia",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
```

### Adding More AI Tools

Extend `scripts/ai_setup_debian.sh` with additional installations:
```bash
# Example: Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Example: Install ComfyUI dependencies
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

### Monitoring Setup

The AI setup includes basic monitoring tools. Extend with:
- Prometheus + Grafana
- NVIDIA DCGM for GPU monitoring  
- Log aggregation with Loki

## Contributing

To contribute improvements:
1. Test your changes thoroughly
2. Update documentation
3. Ensure compatibility with different hardware configurations
4. Consider security implications

## License

This project is part of TakermanLTD server infrastructure. Use in accordance with your organization's policies.

---

**Note**: This documentation assumes familiarity with Linux system administration and Docker. For production deployments, additional security hardening and testing are recommended.