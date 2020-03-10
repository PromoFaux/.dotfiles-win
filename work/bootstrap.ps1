#Requires -RunAsAdministrator

. "..\utils.ps1"

net use U: \\srv2-croydon\Usersdata 2>&1>null
net use F: \\srv2-croydon\Sys 2>&1>null
net use G: \\srv2-croydon\OTTO 2>&1>null

#Config Linking
$local:confDir = "U:\AdamW\config"
lns "$env:APPDATA\mRemoteNG\confCons.xml" "$local:confDir\mRemoteNG\confCons.xml" #config stored on U drive
# lns "$env:APPDATA\Microsoft\Microsoft SQL Server\140\Tools\Shell\RegSrvr.xml" "$local:confDir\SSMS\RegSrvr.xml"
lns "C:\ProgramData\Devart\dbForge SQL Complete\Snippets\Custom" "$local:confDir\dbForgeSnippets"
#lns "C:\ProgramData\Symantec\pcAnywhere\Remotes" "$local:confDir\pcAnywhere\Remotes"

lns "C:\repos" "U:\AdamW\Repos"