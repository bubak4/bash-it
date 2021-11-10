#!/bin/bash

dune_dir=$(dirname "$(readlink -f "$0")")
if test -x /usr/games/fortune ; then
    echo
    /usr/games/fortune $dune_dir/fortunes/dune
    echo
fi
