# setting the EDITOR variable is rocket science :-)

if which run_emacs > /dev/null 2>&1 ; then
    EDITOR=$(which run_emacs)
elif which zile > /dev/null 2>&1 ; then
    EDITOR=$(which zile)
elif which mcedit > /dev/null 2>&1 ; then
    EDITOR=$(which mcedit)
elif which vim > /dev/null 2>&1 ; then
    EDITOR=$(which vim)
else
    EDITOR=$(which vi)
fi

if which zile > /dev/null 2>&1 ; then
    ALTERNATE_EDITOR=$(which zile)
elif which vim > /dev/null 2>&1 ; then
    ALTERNATE_EDITOR=$(which vim)
else
    ALTERNATE_EDITOR=$(which vi)
fi

if test -x ~/.local/opt/emacs-latest/bin/emacs ; then
    export EMACS_CMD=~/.local/opt/emacs-latest/bin/emacs
else
    export EMACS_CMD=emacs
fi

# fix if .bashrc is used by another user (ie. using symlink for example)
if test ! -x "$EMACS_CMD" -a ! -x "$EDITOR" ; then
    EDITOR=$ALTERNATE_EDITOR
fi

export EDITOR ALTERNATE_EDITOR

alias ec="${EMACS_CMD}client --create-frame --frame-parameters='((fullscreen . maximized))' --alternate-editor=$ALTERNATE_EDITOR"

function emacs-start()
{
    # why using [ $? -eq 0 ] does not work?
    local tmp=$(pgrep -U $(id -u -n) $EMACS_CMD | wc -l)
    if test $tmp -gt 0 ; then
        echo "I: existing emacs daemon found"
    else
        echo "I: starting new emacs daemon"
	    $EMACS_CMD --daemon
    fi
}

function emacs-stop()
{
    # why using [ $? -eq 0 ] does not work?
    local tmp=$(pgrep -U $(id -u -n) $EMACS_CMD | wc -l)
    if test $tmp -gt 0 ; then
        echo "I: existing emacs daemon found"
        ${EMACS_CMD}client -e '(let ((last-nonmenu-event nil))(save-buffers-kill-emacs t))'
    fi
}
