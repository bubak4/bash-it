# legacy fbpanel functions -- not used anymore

# restarts fbpanel config (start panel if none is running)
function x-panel-restart()
{
    local cmd=`which fbpanel`
    if test -x $cmd ; then
        dbus-start
        pkill fbpanel
        for i in default launcher ; do
            $cmd --profile $i &
        done
    fi
}

# reloads fbpanel config (without restarting)
function x-panel-reload()
{
    local cmd=`which fbpanel`
    if test -x /usr/local/fbpanel/bin/fbpanel ; then
        cmd=/usr/local/fbpanel/bin/fbpanel
    fi
    if test -x $cmd ; then
        dbus-start
        pkill -SIGUSR1 fbpanel
    fi
}

# legacy dbus functions -- only as dependency of fbpanel -- intentionally commented out

# MY_DBUS_FILE=$TMPDIR/$(id -u -n)-$(id -u)_dbus

# function dbus-start()
# {
#     local start_new=1
#     if test -f $MY_DBUS_FILE ; then
#         echo "I: checking $MY_DBUS_FILE"
#         source $MY_DBUS_FILE
#         if ps -p $DBUS_SESSION_BUS_PID > /dev/null ; then
#             echo "I: reusing existing dbus with PID == $DBUS_SESSION_BUS_PID"
#             start_new=
#         fi
#     fi

#     if test -n "$start_new" ; then
#         echo "I: starting new dbus"
#         dbus-launch --sh-syntax --exit-with-session > $MY_DBUS_FILE
#         eval $(cat $MY_DBUS_FILE)
#         echo "I: dbus with PID == $DBUS_SESSION_BUS_PID"
#     fi
# }

# function dbus-stop()
# {
#     local active_logins_count=$(who | fgrep -e $(id -u -n) | wc -l)
#     if test $active_logins_count = "1" ; then
#         echo "I: killing dbus"
#         pkill -U $(id -u) dbus-daemon
#         dbus-cleanup-sockets
#         rm -f $MY_DBUS_FILE
#     else
#         echo "I: do not killing dbus, active logins remaining (# $active_logins_count)"
#     fi
# }
