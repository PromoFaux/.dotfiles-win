#Requires -RunAsAdministrator

. "..\utils.ps1"

# Set Computer Name

$local:newName = "Adam-PC"
$local:currName = (Get-WmiObject Win32_ComputerSystem).Name
if (!($local:currName -eq $local:newName)){
    Write-Output "Changing computername from $local:currName to $local:newName (will be changed after reboot)"
    (Get-WmiObject Win32_ComputerSystem).Rename($local:newName) | Out-Null
}

Write-Output ""
Write-Output "Running Home-specific commands"
Install steam
Install geforce-experience
Install razer-synapse-2
#Install cue
Install discord.install
Install msiafterburner
Install uplay

lns "${env:ProgramFiles(x86)}\MSI Afterburner\Profiles" ".\MSIAfterburner\Profiles"