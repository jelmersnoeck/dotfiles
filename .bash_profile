# Load Homebrew if we're on a Mac
if [[ `uname` == 'Darwin' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export BASH_SILENCE_DEPRECATION_WARNING=1
# load the dotfile files.
for file in ~/.bash/{exports,aliases,shell,commands,.git-completion.bash}; do
    [ -r "$file" ] && source "$file";
done;
unset file;

# Aliasing
__git_complete gco _git_checkout

# Load machine specific functionality
if [ -f ~/.bash_extra ]; then
    source ~/.bash_extra
fi

# Ensure GPG agent is running
gpgconf --launch gpg-agent
export PATH="$PATH:./node_modules/"

# Load prompt after all others have been loaded
source ~/.bash/prompt

# Set up direnv
eval "$(direnv hook bash)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :
