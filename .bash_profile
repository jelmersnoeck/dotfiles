# Set paths.
export PATH=/usr/local/bin:/usr/local/mysql/bin::/opt/local/sbin:$PATH
export PATH="$HOME/.bin:$PATH"
export PATH=$PATH:/usr/local/sbin
export PATH="$HOME/.knife:$PATH"
export PATH=/usr/local/share/npm/bin:$PATH
export PATH="/usr/local/heroku/bin:$PATH"
export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Set the OS
OS=`uname -s`

# load the dotfile files.
for file in ~/.bash/{development,aliases,shell,commands,prompt,.git-completion.bash}; do
    [ -r "$file" ] && source "$file";
done;
unset file;

if [ ! -f ~/.bash_extra ]; then
    touch ~/.bash_extra
fi
source ~/.bash_extra

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
