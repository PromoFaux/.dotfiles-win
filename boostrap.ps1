#Requires -RunAsAdministrator

. ".\utils.ps1" 

# Sanity Check

if (-not [environment]::Is64BitOperatingSystem) {
    Write-Error "Only 64 bit Windows is supported"
    exit
}

$script:binPath = "C:\bin"
$script:tempPath = "C:\temp"
$script:gnupgPath = ""
$script:pubKeyUrl = "https://keybase.io/promofaux/pgp_keys.asc"
$script:expectedSSHKey = "2048 SHA256:BVZ+g2vOhiCmEDjN2FNR/mazm+se0+tkGTBFg24mk4g cardno:000604884497 (RSA)"

#We need bin and temp
CreateDirIfNotExist($script:binPath)
CreateDirIfNotExist($script:tempPath)


#Install Scoop
########################################################################################################################################################
########################################################################################################################################################
Write-Output "Installing Scoop..."
if (!(CommandExists("scoop"))) {    
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
else {    
    Write-Warn "Scoop Already installed"
}    


#Install some programs!
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Installing applications from Scoop..."
scoop install git gpg nano coreutils
scoop bucket add extras
scoop install conemu oh-my-posh posh-git yubioath


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
$gpgOutput = & gpg --version | Select-String -Pattern "Home"
$gpgOutput = $gpgOutput -replace "Home: ", ""
$script:gnupgPath = $gpgOutput -replace "/", "\"
    
lns "$script:gnupgPath\gpg-agent.conf" ".\gpg\gpg-agent.conf"


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

#link gpg-agent.bat
lns "$script:binPath\gpg-agent.bat" ".\gpg\gpg-agent.bat"

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

$local:wait = $true

while ($local:wait -eq $true) {
    $local:test = ssh-add -l
    if (!($local:test -eq $script:expectedSSHKey)) {
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
$local:gpgpath = (Get-Command gpg).path
git config --global gpg.program $local:gpgpath

# Set environment variable to tell git to use win32 SSH:
$local:sshPath = (Get-Command ssh).path
SetEnvVariable "User" "GIT_SSH" $local:sshPath


#Dotfiles repo
########################################################################################################################################################
########################################################################################################################################################
#If local copy of dotfiles repo does not exist, we should be able to clone it with the above set up!
$script:dotPath = "$env:UserProfile\.dotfiles"
if(!(Test-Path $script:dotPath))
{
    git clone git@github.com:PromoFaux/.dotfiles.git $script:dotPath    
}

#Misc File Links
########################################################################################################################################################
########################################################################################################################################################
Write-Output ""
Write-Output "Linking Misc Config files"
lns "$env:UserProfile\scoop\apps\conemu\current\ConEmu\ConEmu.xml" ".\conemu\ConEmu.xml"

#Powershell stuff
$local:profileDir = Split-Path -parent $profile
lns "$local:profileDir\Microsoft.Powershell_profile.ps1" ".\powershell\Microsoft.Powershell_profile.ps1"
lns "$local:profileDir\Microsoft.Powershell_functions.ps1" ".\powershell\Microsoft.Powershell_functions.ps1"
