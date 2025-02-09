#!/bin/bash
# Time-stamp: <2023-08-11 15:39:55 martin>

# workbox has static IP 192.168.1.19
# this scripts:
# - adds IP 192.168.1.1 to local bridge br0 (using the same subnet 192.168.1.0/24)
# - adds local ethernet iface (enp0s31f6) to local bridge br0
# - adds route to workbox via local bridge

# add additional IP to br0
ip addr add 192.168.1.1/32 dev br0 || echo "IP already assigned to bridge"

# add eth0 (enp0s31f6) to br0
brctl addif br0 enp0s31f6 || echo "IF already added to bridge"

# add direct route to workbox
ip route add 192.168.1.19/32 via 192.168.1.1

# UNDO
if false ; then
    ip route del 192.168.1.19/32
    brctl delif br0 enp0s31f6
    ip addr del 192.168.1.1/32 dev br0
fi
