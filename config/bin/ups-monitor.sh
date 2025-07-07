#!/bin/bash

for ups in $(upsc -l 2>/dev/null) ; do

    echo -e "####\n# $ups\n####"
    upsc $ups 2>/dev/null | fgrep -e "battery.charge:" -e "battery.runtime:" -e "device.model:"
    for i in $(upsc -c $ups 2>/dev/null) ; do
        name=$(nslookup $i | cut -d "=" -f 2 | tr -d " ")
    	echo -e "connected clients: $i\t$name"
    done
    echo

done
