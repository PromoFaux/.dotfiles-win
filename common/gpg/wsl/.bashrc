kill -9 $(ps x | grep npiperelay | grep -v grep | awk '{ print $1 }')
setsid nohup socat EXEC:"/mnt/c/bin/npiperelay/npiperelay.exe /\/\./\pipe/\ssh-pageant" UNIX-LISTEN:/tmp/wsl2-ssh-agent.sock,unlink-close,unlink-early,fork >/dev/null 2>&1 &
export SSH_AUTH_SOCK=/tmp/wsl2-ssh-agent.sock

winGpgPath="/mnt/c/Program Files (x86)/GnuPG/bin/gpg.exe"
linuxGpgPath_user="/usr/local/bin/gpg"
if [[ -f "$winGpgPath" ]]; then
  ln -s "$winGpgPath" "$linuxGpgPath_user"
fi