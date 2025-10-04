#!/bin/bash

# 1. prepare
apt remove --purge snapd -y
rm -rf /var/snap /var/lib/snapd /var/cache/snapd ~/snap
mkdir -p /etc/apt/keyrings
mkdir -p /root/.config/rclone
mkdir -p /mnt/raid
mkdir -p /mnt/media
git clone git@github.com:TakermanLTD/server.git

# 2. install
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
curl -fsSL https://get.docker.com -o get-docker.sh
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey -o /etc/apt/keyrings/nvidia-container-toolkit.asc
curl -fsSL https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh -o /home/takerman/openvpn-install.sh
echo "deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.asc] https://nvidia.github.io/libnvidia-container/stable/deb/amd64 /" | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
add-apt-repository ppa:graphics-drivers/ppa

apt-get update

apt install -y git curl wget alsa-utils openssh-server clamav clamav-daemon apt-transport-https rclone \
    software-properties-common timeshift htop nvtop nvidia-docker2 nvidia-container-toolkit \
    docker-compose-plugin lm-sensors python3 python3-pip python3-venv pyenv ufw

apt install nvidia-driver-580-server-open
ubuntu-drivers autoinstall

pyenv venv /root/venv
pip3 install nvitop

# 3. configure
# 3.1 bashrc
cat /root/server/configs/.bashrc >> ~/.bashrc
source ~/.bashrc

# 3.2 nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
nvidia-smi -a | grep "GPU UUID"
nano /etc/docker/daemon.json
{
    "default-runtime": "nvidia",
    "node-generic-resources": [
        "NVIDIA_GPU_1=GPU-b421583a-f3d7-0ef9-7a71-5ac775e76883",
        "NVIDIA_GPU_2=GPU-b421583a-f3d7-0ef9-7a71-5ac775e76883",
        "NVIDIA_GPU_3=GPU-b421583a-f3d7-0ef9-7a71-5ac775e76883",
        "NVIDIA_GPU_4=GPU-b421583a-f3d7-0ef9-7a71-5ac775e76883",
        "NVIDIA_GPU_5=GPU-b421583a-f3d7-0ef9-7a71-5ac775e76883"
    ],
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
systemctl restart docker

# 3.3 clamav
systemctl start clamav-freshclam
systemctl enable clamav-freshclam

# 3.4 git
git config --global user.email "tivanov@takerman.net"
git config --global user.name "takerman"

# Login to GitHub Container Registry (if token provided)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u takerman --password-stdin
    echo "✅ Logged into GitHub Container Registry"
else
    echo "⚠️  GITHUB_TOKEN not provided - skipping private registry login"
fi

# 3.5 ssh
git clone https://github.com/TakermanLTD/server.git /root/server
cat /root/server/dev/ssh/id_rsa >> /root/.ssh/id_rsa
cat /root/server/dev/ssh/id_rsa.pub >> /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
cat /root/server/dev/ssh/.bashrc >> /root/.bashrc
nano /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "AllowUsers root" >> /etc/ssh/sshd_config
systemctl restart sshd
ssh-keygen -p -f /root/.ssh/id_rsa -m PEM
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_rsa

# 3.6 rclone
cp /root/server/dev/configs/rclone.conf /root/.config/rclone/

# 3. 7 openvpn 
bash /home/takerman/openvpn-install.sh

# 3.8 ufw
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 1194/udp
ufw enable
ufw status verbose

# 3.9 prepare directories (base structure, containers will handle detailed setup)
mkdir -p /root/volumes
chmod -R 755 /root/volumes
