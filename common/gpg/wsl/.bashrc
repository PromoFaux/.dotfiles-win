# detect what we have
if [  $(uname -a | grep -c "Microsoft") -eq 1 ]; then
    export ISWSL=1 # WSL 1
elif [ $(uname -a | grep -c "microsoft") -eq 1 ]; then
    export ISWSL=2 # WSL 2
else
    export ISWSL=0
fi
if [ ${ISWSL} -eq 1 ]; then
    # WSL 1 could use AF_UNIX sockets from Windows side directly
    if [ -n ${WSL_AGENT_HOME} ]; then
        export GNUPGHOME=${WSL_AGENT_HOME}
        export SSH_AUTH_SOCK=${WSL_AGENT_HOME}/S.gpg-agent.ssh
    fi
elif [ ${ISWSL} -eq 2 ]; then
    ${HOME}/.local/bin/win-gpg-agent-relay start
    export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh
#else
    # Do whatever -- this is real Linux
fi