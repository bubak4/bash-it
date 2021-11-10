# ssh legacy functions

# usually should be run as root
# $1 .. username
function ssh-env-create-simple-bash_profile-and-link-martin-bashrc()
{
    local user="$1"

    if test -z "$user" -o "$user" = "martin"; then
        echo "E: cannot be run for user == '$user'"
        return
    fi

    local home_dir=$(echo ~$user)
    local instant=$(date --rfc-3339=seconds)
    local bash_profile="$home_dir/.bash_profile"
    local bashrc="$home_dir/.bashrc"
    local mcrc="$home_dir/.config/mc"

    cat > $bash_profile <<EOF
# ~/.bash_profile
# generated $instant

# - - - - bashrc

if test -f ~/.bashrc ; then
    source ~/.bashrc
fi
EOF
    rm -rf $bashrc
    ln -s /home/martin/.bashrc $bashrc
    chown $user:$user $bash_profile

    echo -e "I: execute 'xhost +si:localuser:$user' to allow connection to one's X session"
}

# copy current user's environment (~/.bashrc) to remote machine
function ssh-env-copy()
{
    local ssh_user="$1"
    local ssh_host="$2"
    local ssh_port="$3"
    local ssh_key="$4"

    if test -z "$ssh_user" ; then
        echo "E: usage: ssh-env-copy <user> <host> <port> <private-key>"
        echo "E: <private-key> is optional"
        return
    else
        echo "I: ssh_user = $ssh_user"
        echo "I: ssh_host = $ssh_host"
        echo "I: ssh_port = $ssh_port"
        echo "I: ssh_key = $ssh_key"
    fi

    if test -n "$ssh_key" -a -f "$ssh_key"; then
        echo "I: $ssh_key will be transfered for ssh key authentication"
    else
        echo "W: no ssh key will be transfered"
    fi

    local instant=$(date --rfc-3339=seconds)
    local bash_profile=$TMPDIR/.bash_profile
    local bash_logout=$TMPDIR/.bash_logout
    local bashrc=~/.bashrc

    cat > $bash_profile <<EOF
# ~/.bash_profile
# generated $instant

# - - - - bashrc

if test -f ~/.bashrc ; then
    source ~/.bashrc
fi

# - - - - environment

LANG=\`locale -a | egrep ^C.UTF-8$\`
if test -z "\$LANG" ; then
    LANG=C
fi
LC_ALL=\$LANG

WWW_HOME="https://www.google.com/" # lynx

export LANG LC_ALL WWW_HOME

# - - - - ssh

ssh-agent-start
EOF

    cat > $bash_logout <<EOF
# ~/.bash_logout
# generated $instant

# - - - - bashrc

if test -f ~/.bashrc ; then
    source ~/.bashrc
fi

# - - - - ssh

ssh-agent-stop
EOF

    local old_SSH_AGENT_PID=$SSH_AGENT_PID
    local old_SSH_AUTH_SOCK=$SSH_AUTH_SOCK
    SSH_AGENT_PID=
    SSH_AUTH_SOCK=

    for i in $ssh_key $bash_profile $bash_logout $bashrc ; do
        if test -f $i ; then
            echo "I: transfering $i"
            if test "$i" = "$ssh_key" ; then
                ssh-copy-id -i $ssh_key -p $ssh_port ${ssh_user}@${ssh_host}
            elif test -n "$ssh_key" ; then
                scp -i $ssh_key -P $ssh_port $i ${ssh_user}@${ssh_host}:$(basename $i)
            else
                scp -P $ssh_port $i ${ssh_user}@${ssh_host}:$(basename $i)
            fi
        else
            echo "W: unable to transfer $i -- not a file"
        fi
    done

    SSH_AGENT_PID=$old_SSH_AGENT_PID
    SSH_AUTH_SOCK=$old_SSH_AUTH_SOCK
}
