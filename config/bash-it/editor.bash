# setting the EDITOR variable is rocket science :-)
# if modification are made here, please see `open-in-emacs.sh` script too

if test -x ~/.local/opt/emacs-latest/bin/emacs ; then
    PATH=~/.local/opt/emacs-latest/bin:$PATH
fi

ALTERNATE_EDITOR=$(which zile mcedit vim vi | head -1)
EDITOR=$(which emacs $ALTERNATE_EDITOR | head -1)
export EDITOR ALTERNATE_EDITOR

function emacs-start()
{
    # why using [ $? -eq 0 ] does not work?
    local tmp=$(pgrep -U $(id -u -n) emacs | wc -l)
    if test $tmp -gt 0 ; then
        echo "I: existing emacs daemon found"
    else
        echo "I: starting new emacs daemon"
	    emacs --daemon
    fi
}

function emacs-stop()
{
    # why using [ $? -eq 0 ] does not work?
    local tmp=$(pgrep -U $(id -u -n) emacs | wc -l)
    if test $tmp -gt 0 ; then
        echo "I: existing emacs daemon found"
        emacsclient -e '(let ((last-nonmenu-event nil))(save-buffers-kill-emacs t))'
    fi
}

function emacs-run()
{
    emacs_cmd="emacsclient --create-frame --alternate-editor=$ALTERNATE_EDITOR"
    if test -n "$MC_SID" ; then
        emacs_cmd="emacsclient --tty --alternate-editor=$ALTERNATE_EDITOR"
    fi
    $emacs_cmd "$@"
}

if [[ "$EDITOR" == *emacs ]] ; then
    alias ec="emacsclient --create-frame --frame-parameters='((fullscreen . maximized))' --alternate-editor=$ALTERNATE_EDITOR"
    EDITOR=~/bin/emacs.sh
    if test ! -x $EDITOR ; then
        cat > $EDITOR <<'EOF'
#!/bin/bash
# copied from bash-it `editor.bash` setup script
function emacs-run()
{
    emacs_cmd="emacsclient --create-frame --alternate-editor=$ALTERNATE_EDITOR"
    if test -n "$MC_SID" ; then
        emacs_cmd="emacsclient --tty --alternate-editor=$ALTERNATE_EDITOR"
    fi
    $emacs_cmd "$@"
}

emacs-run "$@"
EOF
        chmod +x $EDITOR
    fi
fi
