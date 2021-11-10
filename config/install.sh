#!/usr/bin/env bash
# Time-stamp: <2021-11-10 20:10:50 martin>

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH || exit 1

files=".bash_profile .bashrc .bash_logout .tmux.conf bin"

X_files="X/.xinitrc X/.xprofile  X/.Xresources  X/.xserverrc  X/.xsession"

for i in $files $X_files; do
    source=$(realpath $i)
	target="$HOME/$(basename $i)"
	if test -L "$target" ; then
		echo "$target already exists"
	else
		ln -s $source $target
		echo "$target -> $i link created"
	fi
done
