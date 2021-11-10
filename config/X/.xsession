#!/usr/bin/env bash

# executed by display managers (like lightdm) when starting default session
# may or may not be executed by display manager, if user explicitly chooses
# a window manager to run

# make sure .xprofile is executed
if test -f ~/.xprofile ; then
    . ~/.xprofile
fi

# do not change -- use the same file as other X utilities
log_file=~/.xsession-errors

# start window manager or desktop environment
if which i3 >/dev/null ; then
    exec i3 2>> $log_file
else
    echo "no window manager found" >> $log_file
    x-terminal-emulator &
fi
