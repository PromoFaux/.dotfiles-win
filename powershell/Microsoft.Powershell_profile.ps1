Set-PsReadlineOption -EditMode Vi -ViModeIndicator Cursor -HistoryNoDuplicate
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Insert
Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ViMode Command

Push-Location (Split-Path -parent $profile)
"aliases","extra" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

Set-Theme Paradox