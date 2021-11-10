#!/usr/bin/env bash
# Time-stamp: <2021-11-10 20:10:50 martin>

#!/usr/bin/env bash

files=".bash_profile .bashrc .bash_logout .tmux.conf bin"

for i in $files ; do
    source=$(realpath $i)
	target="$HOME/$(basename $i)"
	if test -L "$target" ; then
		echo "$target already exists"
	else
		ln -s $source $target
		echo "$target -> $i link created"
	fi
done
