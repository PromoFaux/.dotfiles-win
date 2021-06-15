Write-Output "Loading personal profile..."

Import-Module posh-git

Push-Location (Split-Path -parent $profile)
"aliases","extra" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

oh-my-posh --init --shell pwsh --config "$(scoop prefix oh-my-posh)\themes\powerline.omp.json" | Invoke-Expression

# Set-Theme Paradox
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
