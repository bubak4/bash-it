# various programming environments

function env-refresh()
{
    local env_path=$HOME/bin

    for i in $(alias | cut -f 1 -d = | cut -c7- | egrep -e "^env-") ; do
        unalias $i
    done

    if test -d $env_path; then
        for i in $env_path/env-*.sh ; do
            name=$(basename $i .sh | tr "_" "-")
            alias "${name}"=". $i"
        done
    fi

    alias | cut -f 1 -d = | cut -c7- | egrep -e "^env-"
}

env-refresh > /dev/null
