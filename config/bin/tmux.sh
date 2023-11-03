#!/bin/bash
# Time-stamp: <2023-11-02 23:12:23 martin>

tmux new-session -d -s main

# main shell
tmux new-window -n "shell" -t main

# ROOT shell
tmux new-window -n "ROOT" -t main 'su -'

# logging
which multitail && [[ -f /var/log/syslog ]] && \
    tmux new-window -n "syslog" -t main "sudo multitail --mergeall /var/log/syslog"

# htop
which htop && \
    tmux new-window -n "htop" -t main 'htop'

# x11vnc
which x11vnc && \
    tmux new-window -n "x11vnc" -t main 'while true ; do x11vnc -rfbport 5900 ; done'

# bookworm chroot (i386)
which schroot && [[ -f /etc/schroot/chroot.d/bookworm.conf ]] && \
    tmux new-window -n "i386 chroot" -t main 'schroot -c bookworm'

# attach main session with ROOT shell preselected
tmux select-window -t main:2
tmux attach-session -t main
