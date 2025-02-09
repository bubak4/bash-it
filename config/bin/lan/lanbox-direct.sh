#!/bin/bash
# Time-stamp: <2023-10-08 07:13:21 martin>

# lanbox uses DHCP, so it is capable of requesting IP from DHCP server,
# which is default behaviour for any iface that is added to br0 bridge
# this scripts:
# - adds local ethernet iface (enp0s31f6) to local bridge br0
# - adds special broadcast address forwarding to local bridge br0 (for UPnP)
# - local dnsmasq provides IP in range 192.168.100.* by default

# add eth0 (enp0s31f6) to br0
brctl addif br0 enp0s31f6 || echo "IF already added to bridge"

# add broadcasting address to br0
ip route add 224.0.0.0/4 via 192.168.100.1

# UNDO
if false ; then
    brctl delif br0 enp0s31f6
    ip route del 224.0.0.0/4
fi
