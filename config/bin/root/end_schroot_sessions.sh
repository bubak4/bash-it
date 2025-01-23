#!/bin/sh
# Time-stamp: < end_schroot_sessions.sh (2015-10-14 22:35) >

files=`ls -1 /var/lib/schroot/session`
for i in $files ; do
    session=`basename $i`
    if schroot -e -c $session ; then
        echo "I: session $session ended"
    else
        echo "E: session $session _not_ ended"
    fi
done
