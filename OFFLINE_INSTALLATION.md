# 🔌 TAKERMAN AI Server - Offline Installation Guide

## Problem: Current ISO Requires Internet

The current build uses **Debian mini.iso** (62MB) which:
- ❌ Downloads packages during installation (~500MB+)
- ❌ Requires internet connection throughout setup
- ❌ Cannot be used on air-gapped/offline systems

## Solution Options

### Option 1: Full Debian ISO (Recommended for Offline)

Use a **full Debian netinst ISO** (~4GB) or **DVD ISO** (~4.7GB) that includes all packages.

#### Steps to Build Offline-Capable ISO

**1. Modify `build_custom_iso.sh`:**

```bash
# Change line ~30 from:
DEBIAN_ISO_URL="https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/mini.iso"

# To full netinst (includes base packages):
DEBIAN_ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"

# Or to DVD1 (includes most packages):
DEBIAN_ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.7.0-amd64-DVD-1.iso"
```

**2. Pre-download Docker Images:**

Create a script to save Docker images as tar files and include them in the ISO.

```bash
# Run this on a machine with internet
cd /root/server
bash docker/save_images_offline.sh
```

**3. Rebuild ISO:**

```bash
bash ./build_custom_iso.sh
```

**Result:**
- ✅ Larger ISO (~4-5GB)
- ✅ Works offline
- ✅ All packages included
- ✅ Docker images pre-loaded

---

### Option 2: Pre-Load Docker Images into ISO

Keep mini.iso but include Docker images in the ISO itself.

**Pros:**
- Medium-sized ISO (~2-3GB)
- Faster installation
- Docker images ready immediately

**Cons:**
- Still needs internet for Debian packages during install
- More complex to maintain

---

## 🐳 Docker Images - Offline Solution

### Current Setup (Online Only)

```yaml
# docker-compose.yml pulls images from internet
services:
  tool_jupyter:
    image: ghcr.io/takermanltd/takerman.jupyter:latest  # Downloaded from GitHub
  ai_comfyui:
    image: ghcr.io/takermanltd/takerman.comfyui:latest  # Downloaded from GitHub
  ai_ollama:
    image: ollama/ollama:latest                          # Downloaded from Docker Hub
```

**Problem:** Requires internet to pull images (~10GB total)

### Offline Solution

#### Method A: Bundle Images in ISO

**1. Save Docker images to files:**

```bash
# On a machine with internet connection
docker pull ghcr.io/takermanltd/takerman.jupyter:latest
docker pull ghcr.io/takermanltd/takerman.comfyui:latest
docker pull ollama/ollama:latest
docker pull ghcr.io/open-webui/open-webui:latest
docker pull n8nio/n8n:latest
docker pull portainer/portainer-ce:latest
docker pull amir20/dozzle:latest

# Save to tar files
mkdir -p /tmp/docker-images
docker save ghcr.io/takermanltd/takerman.jupyter:latest -o /tmp/docker-images/jupyter.tar
docker save ghcr.io/takermanltd/takerman.comfyui:latest -o /tmp/docker-images/comfyui.tar
docker save ollama/ollama:latest -o /tmp/docker-images/ollama.tar
docker save ghcr.io/open-webui/open-webui:latest -o /tmp/docker-images/openwebui.tar
docker save n8nio/n8n:latest -o /tmp/docker-images/n8n.tar
docker save portainer/portainer-ce:latest -o /tmp/docker-images/portainer.tar
docker save amir20/dozzle:latest -o /tmp/docker-images/dozzle.tar

# Compress to save space
cd /tmp/docker-images
tar czf ../docker-images-offline.tar.gz *.tar
```

**2. Modify build script to include images:**

Add to `build_custom_iso.sh`:

```bash
# Copy Docker images to ISO
if [ -f "/tmp/docker-images-offline.tar.gz" ]; then
    log "Including offline Docker images..."
    mkdir -p "$EXTRACT_DIR/docker-images"
    cp /tmp/docker-images-offline.tar.gz "$EXTRACT_DIR/docker-images/"
fi
```

**3. Modify post-install script:**

Add to `scripts/post_install.sh`:

```bash
# Load pre-bundled Docker images if available
if [ -f /cdrom/docker-images/docker-images-offline.tar.gz ]; then
    log "Loading offline Docker images..."
    cd /tmp
    tar xzf /cdrom/docker-images/docker-images-offline.tar.gz
    for image in *.tar; do
        docker load -i "$image"
    done
    rm *.tar
fi
```

**Result:**
- ✅ Docker images included in ISO
- ✅ No internet needed for Docker images
- ⚠️ ISO size increases (~12GB total)

#### Method B: Separate Docker Images Archive

Keep ISO small, provide separate archive for Docker images.

**Structure:**
```
TAKERMAN-AI-SERVER-debian-12-amd64.iso        (~4GB - Full ISO)
TAKERMAN-AI-SERVER-docker-images.tar.gz       (~10GB - Docker images)
```

**Installation Process:**
1. Boot from ISO (offline)
2. Install base system (offline)
3. Copy docker-images archive via USB
4. Load images: `bash /root/server/scripts/load_docker_images.sh`

---

## 📦 Complete Offline Installation Workflow

### Preparation (On Internet-Connected Machine)

```bash
# 1. Build full ISO with netinst
cd /path/to/os-takerman
# Edit build_custom_iso.sh - change to netinst URL
bash ./build_custom_iso.sh

# 2. Save Docker images
bash docker/save_images_offline.sh

# 3. Create offline package
mkdir -p TAKERMAN-OFFLINE-PACKAGE
cp build/TAKERMAN-AI-SERVER-debian-12-amd64.iso TAKERMAN-OFFLINE-PACKAGE/
cp build/docker-images-offline.tar.gz TAKERMAN-OFFLINE-PACKAGE/
cp OFFLINE_INSTALLATION.md TAKERMAN-OFFLINE-PACKAGE/

# 4. Create checksums
cd TAKERMAN-OFFLINE-PACKAGE
sha256sum * > SHA256SUMS.txt
```

### Installation (On Offline Machine)

```bash
# 1. Boot from ISO
# - Install proceeds offline using packages from ISO

# 2. After first boot, load Docker images
cd /media/usb/TAKERMAN-OFFLINE-PACKAGE
tar xzf docker-images-offline.tar.gz -C /tmp
cd /tmp
for image in *.tar; do
    docker load -i "$image"
    rm "$image"
done

# 3. Start services
cd /root/server
docker compose up -d

# 4. Verify all services running
docker ps
takstats
```

---

## 🎯 Recommended Solution

### For Production/Air-Gapped Systems:

**Use Full Debian DVD ISO + Separate Docker Archive**

**Advantages:**
✅ Complete offline installation
✅ No internet dependency
✅ Professional deployment ready
✅ Easier to update (replace archive)
✅ Smaller individual files (easier to transfer)

**Package Contents:**
```
TAKERMAN-AI-SERVER-OFFLINE/
├── TAKERMAN-AI-SERVER-debian-12-amd64.iso        # 4.7GB - Full system
├── TAKERMAN-docker-images.tar.gz                  # 10GB - All containers
├── OFFLINE_INSTALLATION.md                        # This guide
├── install_offline.sh                             # Automated loader script
└── SHA256SUMS.txt                                 # Verification checksums
```

**Total Package Size:** ~15GB (fits on 32GB USB drive)

---

## 🔄 Updating Offline Systems

### Docker Images Update

```bash
# On internet-connected machine
bash docker/save_images_offline.sh

# Transfer to offline machine via USB
# On offline machine
bash docker/load_images_offline.sh
docker compose pull  # Uses local images
docker compose up -d
```

### System Packages Update

```bash
# Create offline APT repository
# On internet-connected Debian machine
mkdir -p /tmp/debian-packages
cd /tmp/debian-packages

# Download packages
apt-get update
apt-get install --download-only --reinstall \
    docker-ce docker-compose-plugin nvidia-driver

# Create repository
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz

# Transfer to offline machine and add as local repository
```

---

## 📊 Size Comparison

| ISO Type | Size | Packages | Docker Images | Internet Required |
|----------|------|----------|---------------|-------------------|
| **Mini.iso** (current) | 62MB | Downloaded | Downloaded | ✅ Yes (Full) |
| **Netinst ISO** | 700MB | Most included | Downloaded | ⚠️ Yes (Partial) |
| **DVD ISO** | 4.7GB | All included | Downloaded | ⚠️ Yes (Docker only) |
| **Full Offline Package** | 15GB | All included | All included | ❌ No |

---

## 🛠️ Scripts for Offline Operation

I'll create these scripts for you:

1. **`docker/save_images_offline.sh`** - Save all Docker images
2. **`docker/load_images_offline.sh`** - Load Docker images from files
3. **`scripts/install_offline.sh`** - Complete offline installation
4. **Modified `build_custom_iso.sh`** - Build with full ISO

Would you like me to create these scripts now?

---

## ⚠️ Current Limitations

**Mini.iso cannot be made fully offline** because:
- It's a network boot installer by design
- Downloads core packages during installation
- No local package repository

**Solution:** Must switch to full netinst or DVD ISO for offline capability.

---

## 🎬 Quick Start for Offline Build

```bash
# 1. Switch to full ISO
sed -i 's|mini.iso|netinst.iso|g' build_custom_iso.sh

# 2. Build ISO
bash ./build_custom_iso.sh

# 3. Save Docker images (requires internet)
bash docker/save_images_offline.sh

# 4. Package everything
tar czf TAKERMAN-OFFLINE-COMPLETE.tar.gz \
    build/TAKERMAN-AI-SERVER-debian-12-amd64.iso \
    build/docker-images-offline.tar.gz \
    OFFLINE_INSTALLATION.md

# Result: Single file for offline deployment
```

---

**Ready for next steps?** Let me know if you want me to:
1. ✅ Create the offline Docker image scripts
2. ✅ Modify build_custom_iso.sh for full ISO
3. ✅ Add Grafana to docker-compose.yml
4. ✅ Create automated offline installation script
