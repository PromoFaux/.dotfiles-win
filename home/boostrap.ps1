#Requires -RunAsAdministrator

. "..\utils.ps1"

Write-Output ""
Write-Output "Running Home-specific commands"
Install steam
Install geforce-experience
Install razer-synapse-2
Install cue
Install discord.install
Install msiafterburner

lns "$env:APPDATA\corsair\CUE\profiles" ".\iCue"
lns "${env:ProgramFiles(x86)}\MSI Afterburner\MSIAfterburner.cfg" ".\MSIAfterburner\MSIAfterburner.cfg"