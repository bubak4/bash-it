# legacy subversion functions

function svn-prop-eol-style-native()
{
    for i in "$@" ; do
        if test -f "$i" ; then
            fromdos "$i"
            svn propset svn:eol-style native "$i"
        else
            echo "E: not a file '$i'"
        fi
    done
}

function svn-prop-executable-on()
{
    for i in "$@" ; do
        if test -f "$i" ; then
            chmod +x "$i"
            svn propset svn:executable on "$i"
        else
            echo "E: not a file '$i'"
        fi
    done
}
