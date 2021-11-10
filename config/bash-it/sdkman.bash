# HACK -- force SDKMAN to initialize for non-login shells in tmux
if test $SHLVL -gt "1" -a -n "$TMUX" ; then
    if test "$SDKMAN_INIT" = "true" ; then
        if ! ( echo $PATH | fgrep -e "sdk" > /dev/null ); then
            #echo "W: forcing SDKMAN init from .bashrc"
            unset SDKMAN_INIT
        fi
    fi
fi
