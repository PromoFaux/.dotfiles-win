#Requires -RunAsAdministrator

. "..\utils.ps1"


$script:binPath = "C:\bin"
$script:tempPath = "C:\temp"
$script:gnupgPath = ""
$script:winBuild = [System.Environment]::OSVersion.Version.Build

#We need bin and temp
CreateDirIfNotExist($script:binPath)
CreateDirIfNotExist($script:tempPath)

$script:y = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes";
$script:n = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "No";

$script:choices = [System.Management.Automation.Host.ChoiceDescription[]]($script:y, $script:n);

#Applications
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Install Applications?", $choices, 0)
if ($script:answer -eq 0) {

    Write-Output ""
    Write-Output "Installing applications from package manager(s)..."

    #Chocolatey
    Install powershell-core
    Install nano
    Install awk #Not included with gnuWin32-coreutils.Install

    Install gnuwin32-coreutils.install #Doesn't add to path automatically, do so below
    if (-not ($env:PATH -like "*GNUWin32*")) {
        Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value "$ENV:PATH;C:\Program Files (x86)\GnuWin32\bin"
    }

    Install vscode

    #Scoop
    scoop bucket add extras

    scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json #this is from https://ohmyposh.dev/docs/windows/#installation
    scoop install posh-git

    scoop bucket add nerd-fonts
    scoop install Hack-NF

    scoop install 7zip

    if ($script:winBuild -ge 18362) { # Windows Terminal wont install on older versions of windows (Such as works LTSC)
        scoop install windows-terminal
    }

    scoop install gpg4win-portable
    scoop install screentogif
    scoop install everything
    # scoop install foxit-reader
    scoop install sublime-merge

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}


#Misc File Links
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Link Configs?", $choices, 0)
if ($script:answer -eq 0) {
    Write-Output ""
    Write-Output "Linking Misc Config files"

    if ($script:winBuild -ge 18362) { # Windows Terminal wont install on older versions of windows (Such as works LTSC)
        #Windows Terminal Configs and shims
        lns "$env:UserProfile\AppData\Local\Microsoft\Windows Terminal\settings.json" ".\windows-terminal\settings.json"
    }

    #Powershell profile(s)
    $local:profileDir = [Environment]::GetFolderPath("MyDocuments")
    lns "$local:profileDir\WindowsPowershell" "..\common\powershell"
    lns "$local:profileDir\Powershell" "..\common\powershell"
}

#Configure GPG
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Configure GPG?", $choices, 0)
if ($script:answer -eq 0) {
    #Import GPG key
    Write-Output ""
    Write-Output "Importing GPG key"
    gpg --import .\gpg\pubkey.asc

    #gpg-agent conf
    Write-Output ""
    Write-Output "Linking gpg-agent.conf"
    $script:gnupgPath = gpgconf --list-dirs homedir
    lns "$script:gnupgPath\gpg-agent.conf" ".\gpg\gpg-agent.conf"
    lns "$script:gnupgPath\scdaemon.conf" ".\gpg\scdaemon.conf"

    #YubiKey Batch File scheduled task thing
    Write-Output ""
    Write-Output "Setting Up scheduled task to run script on yubi-key insert..."

    $local:taskName = "gpg-agent"
    #Check for, and remove task if it already exists. The one in the repo might be newer
    if (ScheduledTaskExists($local:taskName)) {
        Unregister-ScheduledTask $local:taskName -Confirm:$false
    }

    #Link npiperelay directory
    lns "$script:binPath\npiperelay" ".\gpg\npiperelay"

    #Link wsl-ssh-pageant directory
    lns "$script:binPath\wsl-ssh-pageant" ".\gpg\wsl-ssh-pageant"

    #link gpg-agent.ps1
    lns "$script:binPath\gpg-agent.ps1" ".\gpg\gpg-agent.ps1"

    # Set environment variable required for wsl-ssh-pageant:
    SetEnvVariable "User" "SSH_AUTH_SOCK" "\\.\pipe\ssh-pageant"

    #Get the currently logged in Users Sid to replace the token in gpg-agent.xml
    $script:currUserSid = (New-Object -ComObject Microsoft.DiskQuota).TranslateLogonNameToSID((Get-WmiObject -Class Win32_ComputerSystem).Username)

    #Replace "[CURRENTUSERSSID] in gpg-agent.xml with the above variable"
    Copy-Item -Path .\gpg\gpg-agent.xml -Destination $script:tempPath\gpg-agent.xml
    (Get-Content .\gpg\gpg-agent.xml) | Foreach-Object { $_ -replace '\[CURRENTUSERSID\]', ${script:currUserSid} } | Out-File $script:tempPath\gpg-agent.xml

    #Register the scheduled task in the system
    Register-ScheduledTask -Xml (Get-Content "${script:tempPath}\gpg-agent.xml" | Out-String) -TaskName 'gpg-agent' | Out-Null

    Remove-Item -Path $script:tempPath\gpg-agent.xml

}

#Check the Yubikey batch file works works
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Test Yubikey?", $choices, 0)
if ($script:answer -eq 0) {
    Write-Output ""
    Write-Output "Insert your YubiKey now!"
    WaitForProcessToStart "wsl-ssh-pageant"

    [string[]]$local:validSSHKeys = Get-Content -Path '.\ssh\authorized_keys'

    $local:wait = $true

    while ($local:wait -eq $true) {
        $local:sshKeyOnCard = ssh-add -L
        # //if (!($local:test -eq $script:expectedSSHKey)) {
        if (!($local:validSSHKeys -contains $local:sshKeyOnCard)) {
            Write-Output "wsl-ssh-pageant is running but cannot get SSH key"
            Start-Sleep -s 3
        }
        else {
            Write-Output "SSH Key is as expected, so everything should be working!"
            $local:wait = $false
        }
    }
}

#.gitconfig stuff
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Conigure git?", $choices, 0)
if ($script:answer -eq 0) {
    Write-Output ""
    Write-Output "Copying .gitconfig and setting gpg.program"
    Copy-Item -Path .\git\.gitconfig -Destination $env:UserProfile\.gitconfig
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
}

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

if (!($local:tmpGitRemoteUrl -eq $local:GitRemoteUrl)) {
    git remote remove origin
    git remote add origin $local:GitRemoteUrl
    git fetch
}
else {
    Write-Output "No need, it's already done"
}

Pop-Location


