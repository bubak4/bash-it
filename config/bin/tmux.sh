#!/bin/bash
# Time-stamp: <2021-12-06 08:45:53 martin>

tmux new-session -d -s main

tmux new-window -n shell -t main
tmux new-window -n ROOT -t main 'su -'
logs=""
for i in messages syslog mail.info ; do
    log=/var/log/$i
    if test -f $log ; then
        logs="$logs $log"
    fi
done
which multitail && \
    tmux new-window -n syslogs -t main "sudo multitail --mergeall $logs"
which htop && \
    tmux new-window -n htop -t main 'htop'

tmux select-window -t main:2
tmux attach-session -t main
