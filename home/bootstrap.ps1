#Requires -RunAsAdministrator

. "..\utils.ps1"

# Set Computer Name

Write-Output ""
Write-Output "Running Home-specific commands"


#Powershell profile (Gdrive at work does not like symlinks)
$local:profileDir = Split-Path -parent $profile
lns "$local:profileDir" "..\common\powershell"

