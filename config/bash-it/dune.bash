# Frank Herbert's Dune fortune

function dune-fortune()
{
    local script=$BASH_IT/config/dune/dune.sh
    if test -x $script ; then
        $script
    fi
}
