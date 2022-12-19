# Linux-like Shortcuts
function which($name)
{
    if (!$name)
    {
        Write-Output "Must pass a command name"
        return
    }

    if ([bool](Get-Command $name -ErrorAction SilentlyContinue))
    {
        Get-Command $name | Select-Object -ExpandProperty Definition
    }
    else {
        Write-Output "$name is not found!"
    }
}

function rm-history
{
	Clear-History
	Remove-Item (Get-PSReadlineOption).HistorySavePath
	[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
	Clear-Host
}

# Directory Listing: Use `ls.exe` if available
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
    Remove-Item alias:ls -ErrorAction SilentlyContinue
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
    ${function:la} = { Get-ChildItem -Force @args }
    # List only directories
    ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}

# curl: Use `curl.exe` if available
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
    Remove-Item alias:curl -ErrorAction SilentlyContinue
    # Set `ls` to call `ls.exe` and always use --color
    ${function:curl} = { curl.exe @args }
    # Gzip-enabled `curl`
    ${function:gurl} = { curl.exe --compressed @args }
} else {
    # Gzip-enabled `curl`
    ${function:gurl} = { Invoke-WebRequest -TransferEncoding GZip }
}

# rm: Use `rm.exe` if available
if (Get-Command rm.exe -ErrorAction SilentlyContinue | Test-Path) {
    Remove-Item alias:rm -ErrorAction SilentlyContinue
    # Set `rm` to call `rm.exe`
    ${function:rm} = { rm.exe @args }
}

${function:ex} = { explorer.exe @args }