# append to the history file, don't overwrite it
shopt -s histappend

HISTCONTROL=ignoreboth
HISTSIZE=20000
HISTFILESIZE=200000

export HISTCONTROL HISTSIZE HISTFILESIZE
