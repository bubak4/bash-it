#!/usr/bin/env bash
# Time-stamp: <2021-11-17 21:27:07 martin>

# use maximum compatibility with sh,
# this script may be processed by different interpreters than bash
# (from .xprofile for example)

SHELL=/bin/bash
export SHELL

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
