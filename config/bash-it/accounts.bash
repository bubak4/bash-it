# accounts function

function accounts()
{
    local script=$BASH_IT/config/accounts/accounts.py
    if test -x $script ; then
        $script "$@"
    fi
}
