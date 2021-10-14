Write-Output "Loading personal profile..."

Import-Module posh-git

Push-Location (Split-Path -parent $profile)
"aliases","extra" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

$omp = scoop prefix oh-my-posh

& $omp\bin\oh-my-posh.exe --init --shell pwsh --config "$omp\themes\powerline.omp.json" | Invoke-Expression

# Set-Theme Paradox
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
