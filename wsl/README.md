bashrc:

```bash
${HOME}/.local/bin/wsl-ssh-agent-relay start
export SSH_AUTH_SOCK=${HOME}/.ssh/wsl-ssh-agent.sock
```

# Other optional things

- (powershell) `[distro] config --default-user root`

- (wsl) oh my bash https://github.com/ohmybash/oh-my-bash

- (wsl) `apt install git ssh tox`

- After installing docker for windows, it does a grumble when trying to run tox:
https://forums.docker.com/t/docker-credential-desktop-exe-executable-file-not-found-in-path-using-wsl2/100225/2

  - In `~/.docker/config.json` change `credsStore` to `credStore`
