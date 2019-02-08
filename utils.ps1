function CreateDirIfNotExist([string]$dirName)
{
    if (!(Test-Path $dirName -PathType Container))
    {
        New-Item -ItemType Directory -Force -Path $dirName | Out-Null 
    }
}

function CommandExists([string]$cmdName)
{
    $local:return = Get-Command $cmdName -ErrorAction SilentlyContinue
    return $local:return
}

function ScheduledTaskExists([string]$taskName)
{
    $local:taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
    return $local:taskExists
}

function WaitForProcessToStart([string]$procName)
{
    $running = $false;
    while( $running -eq $false ) {

        $running = ( ( Get-Process | Where-Object ProcessName -eq $procName).Length -gt 0);        
        Start-Sleep -s 1
    }
}

function lns([String]$link, [String]$target) {
	$file = Get-Item $link -ErrorAction SilentlyContinue
    $toFile = Get-Item $target -ErrorAction SilentlyContinue
    $target = $toFile.FullName

	if($file) {
		if ($file.LinkType -ne "SymbolicLink") {
            Write-Warn "$($file.FullName) already exists and is not a symbolic link creating a backup"
            $newName = $file.Name #my powershellfu is not strong at this point...             
            Rename-Item -Path $file.FullName -NewName "$newName.bck"            
		} elseif ($file.Target -ne $target) {
			Write-Error "$($file.FullName) already exists and points to '$($file.Target)', it should point to '$target'"
			return
		} else {
			Write-Warn "$($file.FullName) already linked"
			return
		}
	} else {
	$folder = Split-Path $link
		if(-not (Test-Path $folder)) {
			Write-Output "Creating folder $folder"
			New-Item -Type Directory -Path $folder
		}
	}
	
	Write-Output "Creating link $link to $target"
	(New-Item -Path $link -ItemType SymbolicLink -Value $target -ErrorAction Continue) | Out-Null
}

function SetEnvVariable([string]$target, [string]$name, [string]$value) {
	$existing = [Environment]::GetEnvironmentVariable($name,$target)
	if($existing) {
		Write-Warn "Environment variable $name already set to '$existing'"
	} else {
		Write-Output "Adding the $name environment variable to '$value'"
		[Environment]::SetEnvironmentVariable($name, $value, $target)
	}
}

function Write-Error([string]$message) {
    [Console]::ForegroundColor = 'red'
    [Console]::Error.WriteLine($message)
    [Console]::ResetColor()
}

function Write-Warn([string]$message) {
    [Console]::ForegroundColor = 'yellow'
    [Console]::Error.WriteLine($message)
    [Console]::ResetColor()
}