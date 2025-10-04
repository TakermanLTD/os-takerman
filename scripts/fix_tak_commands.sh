#!/bin/bash

# Manual TAKERMAN Commands Setup Script
# Run this on your installed TAKERMAN AI Server if tak commands are missing

echo "Creating TAKERMAN commands..."

# Create the commands in /usr/local/bin
mkdir -p /usr/local/bin

# Create takgpu command
cat > /usr/local/bin/takgpu << 'EOF'
#!/bin/bash
nvidia-smi "$@"
EOF

# Create takstats command  
cat > /usr/local/bin/takstats << 'EOF'
#!/bin/bash
/usr/local/bin/takerman-stats "$@"
EOF

# Create takdocker command
cat > /usr/local/bin/takdocker << 'EOF'
#!/bin/bash
docker "$@"
EOF

# Create takps command
cat > /usr/local/bin/takps << 'EOF'
#!/bin/bash
docker ps "$@"
EOF

# Create takhelp command
cat > /usr/local/bin/takhelp << 'EOF'
#!/bin/bash
echo -e "\033[1;35m=== TAKERMAN AI SERVER COMMANDS ===\033[0m"
echo -e "\033[1;32mGPU Management:\033[0m"
echo "  takgpu, takgpuwatch, takgpustats, taknvtop"
echo -e "\033[1;32mDocker Management:\033[0m"  
echo "  takdocker, takps, takimages, takup, takdown, taklogs"
echo -e "\033[1;32mSystem Monitoring:\033[0m"
echo "  takstats, taktop, takiot, taknet, taktemp, takdisk"
echo -e "\033[1;32mSecurity & Network:\033[0m"
echo "  takports, takfw, takfail, takssh"
echo -e "\033[1;32mSystem Control:\033[0m"
echo "  takreboot, takshutdown, takservices, takupdate"
EOF

# Make all commands executable
chmod +x /usr/local/bin/tak*

# Create aliases file
cat > /root/.takerman_aliases << 'EOF'
# TAKERMAN AI Server Aliases
# GPU and AI Management
alias takgpu='nvidia-smi'
alias takgpuwatch='watch -n 1 nvidia-smi'
alias takgpustats='gpustat -i 1'
alias taknvtop='nvtop'
alias takgputemp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits'

# Docker Management
alias takdocker='docker'
alias takps='docker ps'
alias takpsa='docker ps -a'
alias takimages='docker images'
alias takstop='docker stop $(docker ps -q)'
alias takclean='docker system prune -f'
alias takcompose='docker-compose'
alias takup='docker-compose up -d'
alias takdown='docker-compose down'
alias taklogs='docker-compose logs -f'

# System Monitoring
alias takstats='takerman-stats'
alias taktop='htop'
alias takiot='iotop'
alias taknet='iftop'
alias taktemp='sensors'
alias takdisk='df -h'
alias takmem='free -h'
alias takcpu='lscpu'

# Network and Security  
alias takports='netstat -tulpn'
alias takfw='ufw status'
alias takfail='fail2ban-client status'
alias takssh='systemctl status sshd'

# System Control
alias takreboot='systemctl reboot'
alias takshutdown='systemctl poweroff'
alias takservices='systemctl list-units --type=service --state=running'
alias takupdate='apt update && apt upgrade -y'

# Useful shortcuts
alias taklog='tail -f /var/log/takerman/ai-server.log'
alias takerror='journalctl -f -p err'
alias takconfig='cd /root/.takerman'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

# Add aliases to bashrc if not already there
if ! grep -q "takerman_aliases" /root/.bashrc; then
    echo "" >> /root/.bashrc
    echo "# TAKERMAN AI Server aliases" >> /root/.bashrc
    echo "if [ -f /root/.takerman_aliases ]; then" >> /root/.bashrc
    echo "    source /root/.takerman_aliases" >> /root/.bashrc
    echo "fi" >> /root/.bashrc
fi

# Add to global bashrc
if ! grep -q "takerman_aliases" /etc/bash.bashrc; then
    echo "" >> /etc/bash.bashrc
    echo "# TAKERMAN AI Server aliases" >> /etc/bash.bashrc
    echo "if [ -f /root/.takerman_aliases ]; then" >> /etc/bash.bashrc
    echo "    source /root/.takerman_aliases" >> /etc/bash.bashrc
    echo "fi" >> /etc/bash.bashrc
fi

echo "✅ TAKERMAN commands created successfully!"
echo "🔄 Please run: source /root/.bashrc"
echo "📝 Test with: takgpu"