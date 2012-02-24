# load custom configuration
for file in ~/{.bash_aliases,.bash_commands}; do
	[ -r "$file" ] && source "$file";
done;
unset file;

# load git autocomplete
source ~/.git-completion.bash;

# configuration to enable shortcuts and autocompletion for git

# load the dotfile files.
for file in ~/.bash/{aliases,shell,commands,prompt,extra}; do
	[ -r "$file" ] && source "$file";
done;
unset file;
