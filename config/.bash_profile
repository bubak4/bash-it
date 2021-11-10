#!/usr/bin/env bash
# Time-stamp: <2021-11-10 16:50:34 martin>

# use maximum compatibility with sh,
# this script may be processed by different interpreters than bash
# (from .xprofile for example)

LANG=cs_CZ.UTF-8
LC_ALL=cs_CZ.UTF-8
export LANG LC_ALL

for i in $HOME/bin $HOME/.emacs.d/bin $HOME/.local/opt/emacs-latest/bin ; do
    if test -d $i ; then
        export PATH=$i:$PATH
    fi
done

# allow access to .config files to anyone from my group
chmod g+x ~/.config

# if not running interactively, don't do anything else
case $- in
  *i*) ;;
    *) return;;
esac

if test -f ~/.bashrc ; then
    . ~/.bashrc
    ssh-agent-start
    dune-fortune
fi

tmp=$(hostname)
if test "$tmp" = "rypous" -o "$tmp" = "x390" ; then
    calendar -A 14
fi
unset tmp
