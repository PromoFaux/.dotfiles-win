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

#Game stuff
Install steam
Install uplay
Install discord.install

#Tools
Install geforce-experience
Install razer-synapse-2
Install hwmonitor

