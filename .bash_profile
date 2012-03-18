# Set paths.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.knife:$PATH"

# load custom configuration
for file in ~/{.git-completion.bash,.bash_aliases,.bash_commands}; do
	[ -r "$file" ] && source "$file";
done;
unset file;

# load the dotfile files.
for file in ~/.bash/{development,aliases,shell,commands,prompt,extra}; do
	[ -r "$file" ] && source "$file";
done;
unset file;
