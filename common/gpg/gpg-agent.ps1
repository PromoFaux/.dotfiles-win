#Restart the gpg-agent (it locks up sometimes)
gpg-connect-agent "KILLAGENT" /bye
gpg-connect-agent /bye

#If wsl-ssh-pageant is not running, start it in the background
$script:wslPageant = Get-Process wsl-ssh-pageant -ErrorAction SilentlyContinue
if (! $script:wslPageant) {
    Start-Process -FilePath "c:\bin\wsl-ssh-pageant\wsl-ssh-pageant.exe" -ArgumentList "--winssh ssh-pageant" -WindowStyle Hidden
}

#GPG goes all fucky when you switch between two yubikeys with the same GPG key (even with different subkeys)
#Clear out stubs relating to my key from the private keys dir.
#see https://github.com/drduh/YubiKey-Guide/issues/19#issuecomment-434844635 for explanation
#Relies on  gnuwin32-coreutils (fine for these dotfiles...) Todo: Use powershell only commands. One day. This works
$script:gnupgPath = gpgconf --list-dirs homedir
$script:gnupgPath += "\private-keys-v1.d"
$script:keyId = "me@adamwarner.co.uk"

[string[]]$script:keyGrips = gpg -K --with-keygrip --with-colons $script:keyId | awk -F: '/^grp/ { print $10\".key\" }'

Push-Location $script:gnupgPath
foreach ($key in $script:keyGrips){
    if (Test-Path $key){
        Remove-Item $key
    }    
}
gpg --card-status
Pop-Location


