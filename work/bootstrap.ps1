#Requires -RunAsAdministrator

. "..\utils.ps1"

net use U: \\srv2-croydon\Usersdata 2>&1>null
net use F: \\srv2-croydon\Sys 2>&1>null
net use G: \\srv2-croydon\OTTO 2>&1>null

#Visual Studio
Install visualstudio2019professional
Install vswhere
Install resharper-ultimate-all

# #SSMS
Install sql-server-management-studio
# #Install dbforge-sql-cmpl-std #Not working, manually for now

# #Tools
Install mremoteng

#Config Linking
$local:confDir = "U:\AdamW\Config"
lns "$env:APPDATA\mRemoteNG\confCons.xml" "$local:confDir\mRemoteNG\confCons.xml" #config stored on U drive
# lns "$env:APPDATA\Microsoft\Microsoft SQL Server\140\Tools\Shell\RegSrvr.xml" "$local:confDir\SSMS\RegSrvr.xml"
lns "C:\ProgramData\Devart\dbForge SQL Complete\Snippets\Custom" "$local:confDir\dbForgeSnippets"

lns "C:\repos" "U:\AdamW\Repos"