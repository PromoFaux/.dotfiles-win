#Restart the gpg-agent (it locks up sometimes)
gpg-connect-agent "KILLAGENT" /bye
gpg-connect-agent /bye

# If gpg-bridge is not running, start it in the background
$script:gpgBridge = Get-Process gpg-bridge -ErrorAction SilentlyContinue
if (! $script:gpgBridge) {
    Start-Process -FilePath "c:\bin\gpg-bridge\gpg-bridge.exe" -ArgumentList "--detach --extra 127.0.0.1:4321 --ssh \\.\pipe\ssh-pageant" -WindowStyle Hidden
}

#GPG goes all fucky when you switch between two yubikeys with the same GPG key (even with different subkeys)
#Clear out stubs relating to my key from the private keys dir.
#see https://github.com/drduh/YubiKey-Guide/issues/19#issuecomment-434844635 for explanation
#Relies on  gnuwin32-coreutils (fine for these dotfiles...) Todo: Use powershell only commands. One day. This works
$script:gnupgPath = gpgconf --list-dirs homedir
$script:gnupgPath += "\private-keys-v1.d"
$script:keyId = "me@adamwarner.co.uk"
#Start-Sleep 5
[string[]]$script:keyGrips = gpg -K --with-keygrip --with-colons $script:keyId | awk -F: '/^grp/ { print $10\".key\" }'
Push-Location $script:gnupgPath
foreach ($key in $script:keyGrips){
    if (Test-Path $key){
        Remove-Item $key
    }
}
gpg --card-status

Pop-Location


