# aliases

export LS_OPTIONS='--color=auto'
eval "`dircolors --bourne-shell`"
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -lh"

alias j="jobs -l"

if pgrep -a system > /dev/null 2>&1 ; then
    alias pgrep="pgrep -fla"
else
    alias pgrep="pgrep -fl"
fi

if grep --color=auto > /dev/null 2>&1 ; then
    export GREP_COLORS="ms=01;32"
    for i in grep egrep fgrep rgrep ; do
        if which $i > /dev/null 2>&1; then
            alias $i="$i --color=auto"
        fi
    done
fi

alias cal="ncal -3 -M -b"

alias dict-en="dict --database fd-eng-ces"
alias dict-cs="dict --database fd-ces-eng"

if which rlwrap > /dev/null 2>&1; then
    alias sqlite3="rlwrap sqlite3"
    alias sqlplus="rlwrap sqlplus"
    alias groovysh="rlwrap groovysh"
fi

if which syncthing > /dev/null 2>&1; then
    alias syncui="syncthing -browser-only"
fi

alias update-desktop-database-local="update-desktop-database ~/.local/share/applications/"

alias android-mount="jmtpfs ~/Android && ls -la ~/Android"
alias android-umount="fusermount -u ~/Android && ls -la ~/Android"

alias urlencode='python2 -c "import sys, urllib as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python2 -c "import sys, urllib as ul; print(ul.unquote_plus(sys.argv[1]))"'

alias pyvenv-create='python3 -m venv .venv && . .venv/bin/activate && pip install wheel'
