#!/bin/bash
# Time-stamp: <2021-07-22 00:44:23 martin>

sticky_note_file=$(mktemp $TMPDIR/sticky-note.XXXX.xwd)

echo "$@" > $sticky_note_file

zenity \
    --text-info \
    --editable \
    --font "Andika 18" \
    --title $sticky_note_file \
    --filename $sticky_note_file

rm $sticky_note_file
