# python

PYTHONPATH=""
export PYTHONPATH

PYVENV_DIR=~/.virtualenvs

function pyvenv-refresh()
{
    for i in $(alias | cut -f 1 -d = | cut -c7- | egrep -e "^pyvenv\-") ; do
        unalias $i
    done

    if test -d $PYVENV_DIR; then
        for i in $PYVENV_DIR/* ; do
            name="pyvenv-$(basename $i)"
            alias "${name}"=". $i/bin/activate"
        done
    fi

    alias | cut -f 1 -d = | cut -c7- | egrep -e "^pyvenv\-"
}

function pyvenv-deactivate()
{
    local pyvenv_path=$(echo $PATH | tr ":" "\n" | fgrep $PYVENV_DIR)
    if test -n "$pyvenv_path" ; then
        echo "I: deactivating $(dirname $pyvenv_path)"
        deactivate
    fi
}

pyvenv-refresh > /dev/null

# support for Python virtualenv inside GNU Emacs
WORKON_HOME=$PYVENV_DIR
export WORKON_HOME
