# Load Homebrew if we're on a Mac
if [[ `uname` == 'Darwin' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export BASH_SILENCE_DEPRECATION_WARNING=1
# load the dotfile files.
for file in ~/.bash/{exports,development,aliases,shell,commands,.git-completion.bash}; do
    [ -r "$file" ] && source "$file";
done;
unset file;

# Aliasing
__git_complete gco _git_checkout

# Load machine specific functionality
if [ -f ~/.bash_extra ]; then
    source ~/.bash_extra
fi

# Don't ask for GPG passphrase every time.
# https://github.com/pstadler/keybase-gpg-github
# This will check if there is a daemon running with the correct configuration
# options. If not, it will check if the daemon is running and kill it if so
# whilst also reloading the default gpg-agent config.
if [[ ! $(ps aux | grep gpg-agent | grep daemon | grep options) ]]; then
    # Kill the agent if one exists
    if [[ $(ps aux | grep gpg-agent | grep daemon) ]]; then
        kill $(ps aux | grep gpg-agent | grep daemon | tr -s " " | awk '{print $2}')
    fi
    gpg-agent --daemon --options ~/.gnupg/gpg-agent.conf
fi
export PATH="$PATH:./node_modules/"

# Load prompt after all others have been loaded
source ~/.bash/prompt
source ~/.profile

# Set up direnv
eval "$(direnv hook bash)"
