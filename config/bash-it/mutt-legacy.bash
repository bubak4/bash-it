# legacy mutt settings

muttrc="$HOME/.mutt"
mailboxes=
if test -d "$muttrc"; then
    mailboxes=`grep -E "^mailboxes" $muttrc/* | tr "#" "=" | cut -d = -f 2 | tr -d " " | sort`
fi

if test -n "$mailboxes" ; then
    MAILPATH=
    for i in $mailboxes ; do
        # using $HOME in sed bellow is tricky
        tmp=`echo $HOME | sed -e 's/\//\\\\\//g'`
        tmp=`echo $i | sed "s/+/$tmp\/Mail\//g"`
        MAILPATH="${tmp}:${MAILPATH}"
    done
    export MAILPATH
fi
