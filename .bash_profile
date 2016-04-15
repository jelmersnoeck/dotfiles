# Set paths.
export PATH="$HOME/.bin:$PATH"
export PATH=$PATH:/usr/local/sbin
export PATH=/usr/local/share/npm/bin:$PATH
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="./.bundle/bin:$PATH"
export EDITOR=vim
export GOPATH="/Users/jelmersnoeck/Projects/goprojects"
export PATH=$PATH:$GOPATH/bin
export GO15VENDOREXPERIMENT=1

# Set the OS
OS=`uname -s`

# load the dotfile files.
for file in ~/.bash/{development,aliases,shell,commands,prompt,.git-completion.bash}; do
    [ -r "$file" ] && source "$file";
done;
unset file;

# Aliasing
__git_complete gco _git_checkout

if [ ! -f ~/.bash_extra ]; then
    touch ~/.bash_extra
fi
source ~/.bash_extra

# Postgress host
export PGHOST=localhost

# Direnv
eval "$(direnv hook bash)"
eval "$(rbenv init -)"

export NVM_DIR="/Users/jelmersnoeck/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Don't ask for GPG passphrase every time.
# https://github.com/pstadler/keybase-gpg-github
if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
    source ~/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
else
    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi
