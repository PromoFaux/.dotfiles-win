#Requires -RunAsAdministrator

. ".\utils.ps1" 

# Sanity Check

if (-not [environment]::Is64BitOperatingSystem) {
    Write-Error "Only 64 bit Windows is supported"
    exit
}

#Kill these two if they're running
taskkill /f /im:gpg-agent.exe
taskkill /f /im:wsl-ssh-pageant.exe

$script:account = "promofaux"
$script:repo    = ".dotfiles"

$script:dotfilesInstallDir = "$env:USERPROFILE\.dotfiles"

#Install Scoop and chocolatey
Write-Output "Installing Scoop..."
if (!(CommandExists("scoop"))) {    
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
else {    
    Write-Warn "Scoop Already installed"
}

if (!(CommandExists("choco")))
{
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else {    
    Write-Warn "Chocolatey Already installed"
}

#Install git so we can clone the repo to the local machine
choco install git -y --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
#using rm.exe from git install seems to be happy to delete a folder containing a .git folder. PS/Windows cannot, for some reason.
rm.exe -rf $script:dotfilesInstallDir

git clone "https://github.com/$script:account/$script:repo" $script:dotfilesInstallDir

Push-Location $script:dotfilesInstallDir
& .\bootstrap.ps1
Pop-Location