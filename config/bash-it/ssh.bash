# ssh

# duplicate from 00-env.bash, somehow, it is not defined
# portable way to get system temp directory
export TMPDIR=$(dirname $(mktemp -u))

# how to pair PID and and AUTH sock if multiple ssh-agents for the same user are running simultaneously?
function ssh-agent-start()
{
    local start_new=1

    # try to find running ssh-agent
    if test -z "$SSH_AGENT_PID" -a -z "$SSH_AUTH_SOCK" ; then
        echo "I: no ssh-agent found in env"
        SSH_AGENT_PID=$(pgrep -U $(id -u) ssh-agent | sort -n | head -1 | cut -f 1 -d " ")
        local name=agent.$(find $TMPDIR -name "agent.*" -user $(id -u) 2>/dev/null | cut -f 2 -d "." | sort -n | head -1)
        if test -n "$name" ; then
            SSH_AUTH_SOCK=$(find $TMPDIR -name $name -user $(id -u) 2>/dev/null)
        fi
    fi

    if test -n "$SSH_AGENT_PID" -a -n "$SSH_AUTH_SOCK" ; then
        if ps -p $SSH_AGENT_PID -o pid h >/dev/null && test -r $SSH_AUTH_SOCK ; then
            echo "I: reusing existing ssh-agent with PID == $SSH_AGENT_PID and SOCK == $SSH_AUTH_SOCK"
            export SSH_AGENT_PID
            export SSH_AUTH_SOCK
            start_new=0
        fi
    else
        echo "W: no suitable ssh-agent with PID == $SSH_AGENT_PID found"
    fi

    if test "$start_new" = "1" ; then
        eval $(ssh-agent)
        echo "I: started ssh-agent with PID == $SSH_AGENT_PID and SOCK == $SSH_AUTH_SOCK"
    fi

    # always register keys
    ssh-add -D
    local ssh_add_key_script=~/.ssh/ssh-add-keys.py
    if test -f "$ssh_add_key_script" && python -c "import pexpect" > /dev/null 2>&1; then
        $ssh_add_key_script
    else
        key_path=~/.ssh
        for i in $key_path/*.pem ; do
            /usr/bin/ssh-add $i
        done
    fi
}

function ssh-agent-stop()
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

function ssh-agent-force-restart()
{
    local active_logins_count=$(who | fgrep -e $USER | wc -l)
    echo "I: killing ssh-agent with PID=$SSH_AGENT_PID (# $active_logins_count)"
    ssh-agent -k
    ssh-agent-start
}

function ssh-env-unset()
{
    echo "I: unsetting SSH env variables"
    local tmp=$(env | fgrep -e "SSH_" | cut -f 1 -d "=")
    for i in "$tmp" ; do
        unset $i
    done
}
