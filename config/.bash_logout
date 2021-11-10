#!/usr/bin/env bash

# - - - - ssh / dbus

ssh-agent-stop

# - - - - last command

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
