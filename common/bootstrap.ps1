#Requires -RunAsAdministrator

. "..\utils.ps1"


$script:binPath = "C:\bin"
$script:tempPath = "C:\temp"
$script:gnupgPath = ""
# $script:expectedSSHKey = "2048 SHA256:BVZ+g2vOhiCmEDjN2FNR/mazm+se0+tkGTBFg24mk4g cardno:000604884497 (RSA)"

#We need bin and temp
CreateDirIfNotExist($script:binPath)
CreateDirIfNotExist($script:tempPath)

#Install Applications
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Installing applications from package manager(s)..."

#Chocolatey

Install Gpg4win
Install GoogleChrome
Install vscode
#Install conemu # Not playing nicely with windows built in SSH. May come back to it
Install microsoft-windows-terminal
Install yubico-authenticator
Install nano
Install screentogif
Install Everything
Install 7zip
Install vlc
Install foxitreader
Install etcher
Install awk #Not included with gnuWin32-coreutils.Install


Install gnuwin32-coreutils.install #Doesn't add to path automatically
if (-not ($env:PATH -like "*GNUWin32*")) {
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value "$ENV:PATH;C:\Program Files (x86)\GnuWin32\bin"
}


#Scoop
scoop bucket add extras

scoop install oh-my-posh
scoop install posh-git
scoop install sublime-merge

scoop bucket add nerd-fonts
scoop install Hack-NF

RefreshEnv.cmd

#Import GPG key
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Importing GPG key"
gpg --import .\gpg\pubkey.asc

#gpg-agent conf
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Linking gpg-agent.conf"
$script:gnupgPath = gpgconf --list-dirs homedir
lns "$script:gnupgPath\gpg-agent.conf" ".\gpg\gpg-agent.conf"
lns "$script:gnupgPath\scdaemon.conf" ".\gpg\scdaemon.conf"

#YubiKey Batch File scheduled task thing
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Setting Up scheduled task to run script on yubi-key insert..."

$local:taskName = "gpg-agent"
#Check for, and remove task if it already exists. The one in the repo might be newer
if (ScheduledTaskExists($local:taskName)) {
    Unregister-ScheduledTask $local:taskName -Confirm:$false
}

#Link wsl-ssh-pageant directory
lns "$script:binPath\wsl-ssh-pageant" ".\gpg\wsl-ssh-pageant"

#link gpg-agent.ps1
lns "$script:binPath\gpg-agent.ps1" ".\gpg\gpg-agent.ps1"

# Set environment variable required for wsl-ssh-pageant:
SetEnvVariable "User" "SSH_AUTH_SOCK" "\\.\pipe\ssh-pageant"

#Get the currently logged in Users Sid to replace the token in gpg-agent.xml
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$script:currUserSid = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current.Sid.Value

#Replace "[CURRENTUSERSSID] in gpg-agent.xml with the above variable"
Copy-Item -Path .\gpg\gpg-agent.xml -Destination $script:tempPath\gpg-agent.xml
(Get-Content .\gpg\gpg-agent.xml) | Foreach-Object {$_ -replace '\[CURRENTUSERSID\]', ${script:currUserSid}} | Out-File $script:tempPath\gpg-agent.xml

#Register the scheduled task in the system
Register-ScheduledTask -Xml (Get-Content "${script:tempPath}\gpg-agent.xml" | Out-String) -TaskName 'gpg-agent' | Out-Null

Remove-Item -Path $script:tempPath\gpg-agent.xml

#Check the Yubikey batch file works works
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Insert your YubiKey now!"
WaitForProcessToStart "wsl-ssh-pageant"

[string[]]$local:validSSHKeys = Get-Content -Path '.\ssh\authorized_keys'

$local:wait = $true

while ($local:wait -eq $true) {
    $local:sshKeyOnCard = ssh-add -L
    # //if (!($local:test -eq $script:expectedSSHKey)) {
    if (!($local:validSSHKeys -contains $local:sshKeyOnCard)){
        Write-Output "wsl-ssh-pageant is running but cannot get SSH key"
        Start-Sleep -s 3
    }
    else {
        Write-Output "SSH Key is as expected, so everything should be working!"
        $local:wait = $false
    }
}

#.gitconfig stuff
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Linking .gitconfig and setting gpg.program"
lns "$env:UserProfile\.gitconfig" ".\git\.gitconfig"
lns "$env:UserProfile\.gitignore" ".\git\.gitignore"

#Set gpg.program in git config (could be different on another machine?)
$local:gitcfgGpgProgram = git config gpg.program
$local:gpgpath = (Get-Command gpg).path

if (!($local:gitcfgGpgProgram -eq $local:gpgpath)) {
    git config --global gpg.program $local:gpgpath
}

# Set environment variable to tell git to use win32 SSH:
$local:sshPath = (Get-Command ssh).path
SetEnvVariable "User" "GIT_SSH" $local:sshPath

#Dotfiles repo
########################################################################################################################################################
########################################################################################################################################################
#If this dotfiles repo has been installed via install.ps1, it wont be a repo, so need to init the folder and add remote.
Write-Output ""
Write-Output "Configuring dotfiles repo to use SSH remote rather than https"
$script:dotPath = "$env:UserProfile\.dotfiles"
Push-Location $script:dotPath

$local:tmpGitRemoteUrl = git remote get-url origin --push
$local:GitRemoteUrl = "git@github.com:PromoFaux/.dotfiles-win.git"

if (!($local:tmpGitRemoteUrl -eq $local:GitRemoteUrl)){
    git remote remove origin
    git remote add origin $local:GitRemoteUrl
    git fetch
}

Pop-Location

#Misc File Links
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Linking Misc Config files"

#Windows Terminal Configs and shims (FANCY GIF BACKGROUNDS, WHAT?)
lns "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\windows-terminal-quake.exe" ".\windows-terminal\windows-terminal-quake.exe"
lns "$env:UserProfile\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json" ".\windows-terminal\profiles.json"
lns "$script:binPath\terminal-background.gif" ".\windows-terminal\terminal-background.gif"

#Powershell stuff
$local:profileDir = Split-Path -parent $profile
lns "$local:profileDir" ".\powershell"

# & .\windows.ps1