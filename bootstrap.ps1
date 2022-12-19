#Requires -RunAsAdministrator

. ".\utils.ps1"


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
    Install 7zip
    Install powershell-core "--install-arguments=""ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"""
    Install nano
    Install awk #Not included with gnuWin32-coreutils.Install

    Install gnuwin32-coreutils.install #Doesn't add to path automatically, do so below
    if (-not ($env:PATH -like "*GNUWin32*")) {
        Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value "$ENV:PATH;C:\Program Files (x86)\GnuWin32\bin"
    }

    Install vscode "/NoDesktopIcon"
    Install sublimemerge
    Install everything "/client-service /folder-context-menu"
    Install screentogif

    Install microsoft-windows-terminal

    Install nerdfont-hack

    #Scoop
    scoop bucket add extras

    scoop install posh-git
    scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json #this is from https://ohmyposh.dev/docs/windows/#installation

    scoop install sudo

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}


#Misc File Links
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Link Configs?", $choices, 0)
if ($script:answer -eq 0) {
    Write-Output ""
    Write-Output "Linking Misc Config files"

    #Powershell profile(s)
    $local:profileDir = [Environment]::GetFolderPath("MyDocuments")
    lns "$local:profileDir\WindowsPowershell" ".\powershell"
    lns "$local:profileDir\Powershell" ".\powershell"

    # reload profile??
    & $profile

    if ($script:winBuild -ge 18362) { # Windows Terminal wont install on older versions of windows (Such as works LTSC)
        #Windows Terminal Configs and shims
        lns "$env:UserProfile\AppData\Local\Microsoft\Windows Terminal\settings.json" ".\windows-terminal\settings.json"
    }
    else {
        # Fine. We'll work without the sexy Windows terminal by using intergrated term in vscode/vs
        # However, in  LTSC the console doesn't display ANSI colors correctly
        # https://superuser.com/a/1300251
        Set-ItemProperty -Path HKCU:\Console -Name VirtualTerminalLevel -Value 1
        # BUT (and this is different from latest win10) it can use Hack NF font face. So that's OK-ish
        Set-ItemProperty -Path HKCU:\Console -Name FaceName -Value "Hack NF"
        set-ItemProperty -Path HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name FaceName -Value "Hack NF"
        set-ItemProperty -Path HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe -Name FaceName -Value "Hack NF"

        # (Cant be bothered to go back to conemu. Maybe one day... Or maybe I'll just install it
        #   seperately outside of dotfiles on machines that don't let me use Windows Terminal)
    }


}

#Configure GPG
########################################################################################################################################################
########################################################################################################################################################
# $script:answer = $host.ui.PromptForChoice("", "Configure GPG?", $choices, 0)
# if ($script:answer -eq 0) {

#     Install gnupg

#     Push-Location -Path $script:binPath  # Or, wherever you want the win-gpg-agent directory located
# 	$uriLatestWinGpgAgentZip = Invoke-RestMethod -Uri "https://api.github.com/repos/rupor-github/win-gpg-agent/releases/latest"  | Select-Object -Property assets -ExpandProperty assets |  Where-Object -FilterScript {$_.name -eq "win-gpg-agent.zip" } | Select-Object -Property browser_download_url -ExpandProperty browser_download_url
# 	Invoke-WebRequest  -OutFile "win-gpg-agent.zip" -Uri $uriLatestWinGpgAgentZip
# 	Expand-Archive .\win-gpg-agent.zip
# 	Remove-Item .\win-gpg-agent.zip
# 	Pop-Location

#     #Import GPG key
#     Write-Output ""
#     Write-Output "Importing GPG key"
#     gpg --import .\gpg\pubkey.asc

# }

#.gitconfig stuff
########################################################################################################################################################
########################################################################################################################################################
$script:answer = $host.ui.PromptForChoice("", "Conigure git?", $choices, 0)
if ($script:answer -eq 0) {
    Write-Output ""
    Write-Output "Copying .gitconfig and .gitignore"
    lns "$env:UserProfile\.gitconfig" ".\git\.gitconfig"
    # lns "$env:UserProfile\.gitignore" ".\git\.gitignore"

    #Set gpg.program in .gitconfig-gpgprog (which will be in the INCLUDE part of the main .gitconfig)
    # $local:gpgpath = ((Get-Command gpg).path).Replace("\","\\")

    # "[gpg]`n`tprogram = $local:gpgpath" | Out-File -FilePath "$env:UserProfile\.gitconfig-gpgprog" -Encoding ascii

    # Set environment variable to tell git to use win32 SSH:
    # $local:sshPath = (Get-Command ssh).path
    # SetEnvVariable "User" "GIT_SSH" $local:sshPath
}

#Dotfiles repo
########################################################################################################################################################
########################################################################################################################################################
#If this dotfiles repo has been installed via install.ps1, it wont be a repo, so need to init the folder and add remote.

$script:dotPath = "$env:UserProfile\.dotfiles"
Push-Location $script:dotPath

$local:tmpGitRemoteUrl = git remote get-url origin --push
$local:GitRemoteUrl = "git@github.com:PromoFaux/.dotfiles-win.git"

if (!($local:tmpGitRemoteUrl -eq $local:GitRemoteUrl)) {
    Write-Output ""
    Write-Output "Configuring dotfiles repo to use SSH remote rather than https"
    git remote remove origin
    git remote add origin $local:GitRemoteUrl
    #git fetch
}

Pop-Location

# #Check the Yubikey batch file works works
# ########################################################################################################################################################
# ########################################################################################################################################################
# $script:answer = $host.ui.PromptForChoice("Test Yubikey?","Might require a reboot to work" , $choices, 0)
# if ($script:answer -eq 0) {
#     Write-Output ""
#     Write-Output "Insert your YubiKey now!"
#     WaitForProcessToStart "wsl-ssh-pageant"

#     [string[]]$local:validSSHKeys = Get-Content -Path '.\ssh\authorized_keys'

#     $local:wait = $true

#     while ($local:wait -eq $true) {
#         $local:sshKeyOnCard = ssh-add -L
#         # //if (!($local:test -eq $script:expectedSSHKey)) {
#         if (!($local:validSSHKeys -contains $local:sshKeyOnCard)) {
#             Write-Output "wsl-ssh-pageant is running but cannot get SSH key"
#             Start-Sleep -s 3
#         }
#         else {
#             Write-Output "SSH Key is as expected, so everything should be working!"
#             $local:wait = $false
#         }
#     }
# }
