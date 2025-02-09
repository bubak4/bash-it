#!/bin/bash
# Time-stamp: <2025-02-09 07:34:15 martin>

target_hostnames="workbox.lan lanbox.lan"

[ "$(hostname --fqdn)" = "workbox.lan" ] && exit 1
[ "$(hostname --fqdn)" = "lanbox.lan" ] && exit 1

if nc -w 2 -z workbox.lan 22 ; then
    target_hostnames="workbox.lan lanbox.lan"
elif nc -w 2 -z aws.slouf.name 4122 ; then
    target_hostnames="workbox.lan-aws lanbox.lan-aws"
fi

log() {
    echo "I: $*"
}

# uses global `$target_hostname`
do_rsync() {
    local source=$1
    local target=$1
    log "syncing $source to $target_hostname"
    if test -d $source ; then
        cd $source || exit 1
        source="."
        target=$(pwd)
    fi
    local exclude=""
    shift
    if test -n "$*" ; then
        log "excluding: $*"
        for i in "$@" ; do
            exclude=$exclude" --exclude=$i"
        done
    fi
    rsync --archive --verbose --progress --update --delete --mkpath $exclude \
        $source martin@${target_hostname}:${target}
}

for i in $target_hostnames ; do
    target_hostname=$i

    do_rsync ~/.bash-it/sync-with-upstream.sh
    do_rsync ~/.bash-it/config/accounts
    do_rsync ~/.ssh
    # do_rsync ~/.gnupg
    do_rsync ~/.doom.d "*.backup"
    do_rsync ~/.emacs.d/upgrade.sh
    do_rsync ~/wrk/debian kernel
    do_rsync ~/.aws
done
