#!/usr/bin/env bash

# executed by xinit (ie. when X is started manually -- like startx)

# make sure .xsession file is processed
if test -f ~/.xsession ; then
    . ~/.xsession
fi
