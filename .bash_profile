# load custom configuration
source ~/.bash_aliases;
source ~/.bash_commands;

# load the dotfile files.
for file in ~/.bash/{aliases,shell,commands,prompt,extra}; do
	[ -r "$file" ] && source "$file";
done;
unset file;
