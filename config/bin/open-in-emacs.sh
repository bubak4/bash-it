#!/bin/bash
# Time-stamp: <2024-09-20 21:38:27 martin>
# Customized script for opening file/directory in GNU Emacs from IntelliJ IDEA
# but can be used from any other IDE or terminal.
#
# When opening directory in case it is a git repo, it will launch to magit.

filename=$1
line_number=$2
column_number=$3

if test -x ~/.local/opt/emacs-latest/bin/emacs ; then
    PATH=~/.local/opt/emacs-latest/bin:$PATH
fi

emacs=$(which emacsclient emacs | head -1)

if [ -z "$emacs" ]; then
    echo "No emacs found"
    exit 1
fi

echo "Working directory: $(pwd)"
echo "Arguments        : filename = $filename, line_number = $$line_number column_number = $column_number"

if [ -z "$filename" ]; then
    echo "Usage: $0 filename [line_number [column_number]]"
    exit 1
fi

if [ -z "$line_number" ]; then
    line_number=1
fi

if [ -z "$column_number" ]; then
    column_number=1
fi

filename=$(realpath $filename)
echo "Opening '$filename' in emacs at line $$line_number column $column_number"
# HACK martin.slouf -- JetBrains Idea passes directory name as filename if opening directory
parent_filename=$(dirname $filename)
if [ ! -d $filename ] && [ ! -f $filename ] && [ -d $parent_filename ]; then
    echo "Overriding filename from '$filename' to '$parent_filename'"
    filename=$parent_filename
fi

if [ -d "$filename" ]; then
    cd $filename
    if git tag > /dev/null 2>&1; then
        echo "Visiting git repo '$filename' in emacs"
        $emacs --create-frame --eval "(magit-status \"$filename\")"
    else
        echo "Visiting directory '$filename' in emacs"
        $emacs --create-frame --eval "(dired \"$filename\")"
    fi
fi

if [ -f "$filename" ]; then
    echo "Visiting file '$filename' in emacs"
    $emacs \
        --create-frame \
        --frame-parameters="((fullscreen . maximized))" \
        +${line_number}:${column_number} \
        $filename
fi
