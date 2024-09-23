#!/bin/bash
# copied from `editor.bash` setup script
function emacs-run()
{
    emacs_cmd="emacsclient --create-frame --alternate-editor=$ALTERNATE_EDITOR"
    if test -n "$MC_SID" ; then
        emacs_cmd="emacsclient --tty --alternate-editor=$ALTERNATE_EDITOR"
    fi
    $emacs_cmd "$@"
}

emacs-run "$@"
