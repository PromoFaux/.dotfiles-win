
For gpg forwarding to work:

Choice bits from: https://wiki.gnupg.org/AgentForwarding

### GnuPG on the remote system
It is important to note that to work properly GnuPG on the remote system still needs your public keys. So you have to make sure they are available on the remote system even if your secret keys are not.

### SSH Configuration

Add the following to the (local) ssh config for the remote machine:

```
RemoteForward [socket on remote] 127.0.0.1:4321
```

Get `[socket on remote]` by running `gpgconf --list-dir agent-socket` on the remote.

REMEMBER TO IMPORT GPG PUBKEY ON REMOTE

If you can modify the servers settings you should put:
```
StreamLocalBindUnlink yes
```
Into /etc/ssh/sshd_config to enable automatic removal of stale sockets when connecting to the remote machine. Otherwise you will first have to remove the socket on the remote machine before forwarding works.