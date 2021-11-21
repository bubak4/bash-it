# duplicate from 00-env.bash, in some rare cases, it may not be defined
# (for example during X startup)
# portable way to get system temp directory
export TMPDIR=$(dirname $(mktemp -u))

# Using maximum Bourne Shell compatibility, it may be executed outside BASH in
# plain SH

# how to pair PID and and AUTH sock if multiple ssh-agents for the same user are running simultaneously?
ssh_agent_start()
{
    test -z "$SSH_AGENT_PID" && export SSH_AGENT_PID=$(pgrep -u $(id -u) -n ssh-agent | awk '{print $1}')
    test -z "$SSH_AUTH_SOCK" && export SSH_AUTH_SOCK=$(ls /tmp/ssh-*/agent.$(($SSH_AGENT_PID-1)) 2>/dev/null)

    ssh-add -l >/dev/null 2>&1
    if test "$?" = "2" ; then
        echo "I: starting new ssh-agent"
        eval $(ssh-agent)
    else
        echo "I: using existing ssh-agent with PID == $SSH_AGENT_PID"
    fi

    env | fgrep -e "SSH_"
}

ssh_agent_stop()
{
    local active_logins_count=$(who | fgrep -e $USER | wc -l)
    if test $active_logins_count = "1" ; then
        echo "I: killing ssh-agent with PID == $SSH_AGENT_PID"
        ssh-agent -k
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
    else
        echo "I: leaving ssh-agent alive, active logins remaining (# $active_logins_count)"
    fi
}

ssh_env_unset()
{
    echo "I: unsetting SSH env variables"
    local tmp=$(env | fgrep -e "SSH_" | cut -f 1 -d "=")
    for i in $tmp ; do
        unset $i
    done
}

if test -n "$BASH_VERSION" ; then
    sshbash_file=$(mktemp $TMPDIR/sshbash.XXXX)
    cat > $sshbash_file <<EOF
function ssh-agent-start() { ssh_agent_start ; }
function ssh-agent-stop() { ssh_agent_stop ; }
function ssh-env-unset() { ssh_env_unset ; }
EOF
    . $sshbash_file
    rm $sshbash_file
    unset sshbash_file
fi
