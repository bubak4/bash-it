#!/bin/bash
# Time-stamp: <2026-02-24 21:16:08 martin>

tmux new-session -d -s main

# main shell
tmux new-window -n "shell" -t main

# ROOT shell
tmux new-window -n "ROOT" -t main 'su -'

# logging
which multitail && [[ -f /var/log/syslog ]] && \
    tmux new-window -n "syslog" -t main "sudo multitail --follow-all --mergeall /var/log/syslog"

# htop
#which htop && \
#    tmux new-window -n "htop" -t main 'htop'

# x11vnc -- disabled 2026-10-03: it shared the real desktop without a
# password on 0.0.0.0:5900, i.e. to every network the laptop is on. VNC goes
# to the planned msn-vnc-server package (password + TLS, firewall-limited).
#( [[ -n "$DISPLAY" ]] && which x11vnc ) && \
#    tmux new-window -n "x11vnc" -t main 'while true ; do x11vnc -rfbport 5900 ; done'

# bookworm chroot (i386)
#which schroot && [[ -f /etc/schroot/chroot.d/bookworm.conf ]] && \
#    tmux new-window -n "i386 chroot" -t main 'schroot -c bookworm'

# attach main session with ROOT shell preselected
tmux select-window -t main:2
tmux attach-session -t main
