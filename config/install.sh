#!/usr/bin/env bash
# Time-stamp: <2021-11-18 03:35:43 martin>

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH || exit 1

# $1 .. source
function safe_link() {
	local source=$(realpath $1)
	local target_dir=$(realpath $HOME/$(dirname $1))
	local target=$target_dir/$(basename $1)
	if test -L "$target" ; then
		if test -e "$target" ; then
			echo "$target link already exists"
		else
			rm -f $target
			ln -s $source $target
			echo "$target link has been fixed"
		fi
	elif test -f "$target" ; then
		mv $target $target.orig
		ln -s $source $target
		echo "$target file replaced with link"
	else
		if ! test -d $target_dir ; then
			mkdir -p $target_dir
		fi
		ln -s $source $target
		echo "$target -> $source link created"
	fi
}

#####################
# ~/.install-secret #
#####################

echo -n "Password: "
read secret
if test -n "$secret" ; then
	rm -f $SCRIPTPATH/.install-secret $HOME/.install-secret
	echo $secret > $SCRIPTPATH/.install-secret
	chmod 0400 $SCRIPTPATH/.install-secret
	safe_link ".install-secret"
else
	cat ~/.install-secret
fi

#########
# ~/bin #
#########

safe_link "bin"

#######
# etc #
#######

cd $SCRIPTPATH/etc
files=$(find -type f)
for i in $files ; do
	safe_link $i
done
cd $SCRIPTPATH

#########
# etc-x #
#########

cd $SCRIPTPATH/etc-x
files=$(find -type f | fgrep -v wallpaper)
for i in $files ; do
	safe_link $i
done
cd $SCRIPTPATH
