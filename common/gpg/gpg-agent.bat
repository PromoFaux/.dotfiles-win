echo off
gpg-connect-agent "KILLAGENT" /bye
gpg-connect-agent /bye

taskkill /f /im:wsl-ssh-pageant.exe
start "" c:\bin\wsl-ssh-pageant\wsl-ssh-pageant.exe --winssh ssh-pageant