#### Stuff to make GPG/Yubi/SSH work from windows
EXISTING_RELAY_PIDS=$(ps x | grep npiperelay | grep -v grep | awk '{ print $1 }')

if [[ -z "${EXISTING_RELAY_PIDS}" ]]; then
  socat \
    EXEC:"/mnt/c/bin/npiperelay/npiperelay.exe /\/\./\pipe/\ssh-pageant" \
    UNIX-LISTEN:/tmp/wsl2-ssh-agent.sock,unlink-close,unlink-early,fork >/dev/null 2>&1 &
fi

export SSH_AUTH_SOCK=/tmp/wsl2-ssh-agent.sock

winGpgPath="/mnt/c/Program Files (x86)/GnuPG/bin/gpg.exe"
linuxGpgPath_user="/usr/local/bin/gpg-win"
if [[ -f "$winGpgPath" ]]; then
  if [[ ! -f "$linuxGpgPath_user" ]]; then
    ln -s "$winGpgPath" "$linuxGpgPath_user"
  fi
fi

if [[ -f "/bin/systemctl" ]]; then
  #Systemctl doesn't work in WSL2 anyway - moving the binary allows pi-hole installation script to start
  mv /bin/systemctl /bin/systemctl.old
fi

if [[ -f $(which pihole-FTL) ]]; then
  # Pi-hole is "installed" on this instance for development, sometimes the services don't start
  if [[ ! $(pidof lighttpd) ]];then
      echo "lighttpd not running - starting..."
      service lighttpd start
  fi

  if [[ ! $(pidof pihole-FTL) ]];then
      echo "pihole-FTL not running - starting..."
      service pihole-FTL start
  fi
fi