#!/bin/bash
# Time-stamp: <2021-11-10 20:07:55 martin>

tmux new-session -d -s main

tmux new-window -n shell -t main
tmux new-window -n ROOT -t main 'su -'
which multitail && \
    tmux new-window -n syslogs -t main 'sudo multitail --mergeall /var/log/messages /var/log/syslog /var/log/postgresql/postgresql-*-main.log /var/log/mail.info'
which htop && \
    tmux new-window -n htop -t main 'htop'
which s-tui && \
    tmux new-window -n cpu -t main 'sudo s-tui'

tmux select-window -t main:2
tmux attach-session -t main
