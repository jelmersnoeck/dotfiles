# Set paths.
export PATH=/usr/local/bin:/usr/local/mysql/bin::/opt/local/sbin:$PATH
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.knife:$PATH"

# Set the OS
OS=`uname -s`

# load custom configuration
for file in ~/{.git-completion.bash,.bash_aliases,.bash_commands}; do
	[ -r "$file" ] && source "$file";
done;
unset file;

# load the dotfile files.
for file in ~/.bash/{development,aliases,shell,commands,prompt,extra.git-completion.bash,symfony2-autocomplete.bash}; do
	[ -r "$file" ] && source "$file";
done;
unset file;

source ~/.bash/.git-completion.bash
