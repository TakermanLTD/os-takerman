alias server='cd /root/server && git pull && cd ./dev'
alias update='apt update && apt upgrade && apt full-upgrade && apt autoremove && apt autoclean'
alias dupdate='update && dpull'
alias dpull='server && cd ./scripts && bash dpull.sh'
alias bvolumes='server && cd ./scripts && bash backup_volumes.sh'
alias bvps='server && cd ./scripts && bash backup_vps.sh'

export ASPNETCORE_ENVIRONMENT=Test
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

if [ -z \"\$SSH_AUTH_SOCK\" ]; then
    eval \"\$(ssh-agent -s)\" > /dev/null
    ssh-add /root/.ssh/id_rsa 2>/dev/null
fi