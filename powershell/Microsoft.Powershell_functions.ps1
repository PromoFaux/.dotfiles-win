# Linux-like Shortcuts

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function rm-history
{
	Clear-History
	Remove-Item (Get-PSReadlineOption).HistorySavePath
	[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
	Clear-Host
}

# Fuzzy Find History

function fzf-hist {
	Invoke-Expression (cat (Get-PSReadlineOption | select -ExpandProperty historysavepath) | Invoke-Fzf)
}

# Git Shortcuts

function ggs { git status }
function gga($file) { git add $file }
function ggai { git add --interactive }
function ggaa { git add --all }
function ggc($msg) { if($msg) { git commit -m $msg } else { git commit } }
function ggca { git commit --amend }
function ggcaa { git commit --amend --no-edit }
function ggp { git push }
function ggu { git pull --ff-only }
function ggd { git diff }
function ggds { git diff --staged }
function ggl { git log --graph --color --all --decorate --format="%C(auto)%d %s" }
function ggll { git log --graph --color --all --decorate --format="%C(auto)%h %d %s %Cblue %ar %an" }
function ggx { git show -s --format='%Cgreen%h %Cblue%an %Cred%cr%Creset%n%s' }
function ggroot { pushd (git rev-parse --show-toplevel) }

# Directory Listing: Use `ls.exe` if available
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
    rm alias:ls -ErrorAction SilentlyContinue
    # Set `ls` to call `ls.exe` and always use --color
    ${function:ls} = { ls.exe --color @args }
    # List all files in long format
    ${function:l} = { ls -lF @args }
    # List all files in long format, including hidden files
    ${function:la} = { ls -laF @args }
    # List only directories
    ${function:lsd} = { Get-ChildItem -Directory -Force @args }
} else {
    # List all files, including hidden files
    ${function:la} = { ls -Force @args }
    # List only directories
    ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}

# curl: Use `curl.exe` if available
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
    rm alias:curl -ErrorAction SilentlyContinue
    # Set `ls` to call `ls.exe` and always use --color
    ${function:curl} = { curl.exe @args }
    # Gzip-enabled `curl`
    ${function:gurl} = { curl --compressed @args }
} else {
    # Gzip-enabled `curl`
    ${function:gurl} = { curl -TransferEncoding GZip }
}