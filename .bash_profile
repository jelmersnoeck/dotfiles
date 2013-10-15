# Set paths.
export PATH="$HOME/.bin:$PATH"
export PATH=$PATH:/usr/local/sbin
export PATH=/usr/local/share/npm/bin:$PATH
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="./.bundle/bin:$PATH"
eval "$(rbenv init -)"
export PATH="./.bundle/bin:$PATH"

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
