# dirsize

# prints out directories > 1M (only 1-level subdirs)
function dirsize()
{
    directory=$(pwd)
    if test -d "$1"; then
        directory=$1
    fi

    cd "$directory" || return
    date --iso-8601=seconds

    du -h 2>/dev/null \
        | sort -h \
        | sed -e "s/\.\///g" \
        | egrep -e "([0-9]+(,[0-9]+)?)[MG][[:space:]]+" \
        | fgrep -v -e "/"
    cd - 1>/dev/null || return
}
