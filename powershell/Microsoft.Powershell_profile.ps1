Set-PsReadlineOption -EditMode Vi -ViModeIndicator Cursor -HistoryNoDuplicate
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Insert
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Command

$ProfileInfo = Get-Item $PROFILE
if(($ProfileInfo).LinkType -eq "SymbolicLink") {
	$ProfileScriptsPath = Split-Path $ProfileInfo.Target
} else {
	$ProfileScriptsPath = Split-Path $ProfileInfo.FullName
}

if (Test-Path("$ProfileScriptsPath\Microsoft.PowerShell_functions.ps1")) {
	. "$ProfileScriptsPath\Microsoft.PowerShell_functions.ps1"
}

Set-Theme Paradox