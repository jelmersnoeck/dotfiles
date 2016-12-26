# load the dotfile files.
for file in ~/.bash/{exports,development,aliases,shell,commands,prompt,.git-completion.bash}; do
    [ -r "$file" ] && source "$file";
done;
unset file;

# Aliasing
__git_complete gco _git_checkout

# Load machine specific functionality
if [ ! -f ~/.bash_extra ]; then
    touch ~/.bash_extra
fi
source ~/.bash_extra

# Don't ask for GPG passphrase every time.
# https://github.com/pstadler/keybase-gpg-github
if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
    source ~/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
else
    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi
