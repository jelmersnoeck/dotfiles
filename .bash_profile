for file in ~/.bash/{aliases,shell,commands,prompt,extra}; do
	[ -r "$file" ] && source "$file";
done;
unset file;
