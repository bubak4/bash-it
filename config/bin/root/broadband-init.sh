#!/bin/bash
# Time-stamp: <2026-05-04 09:25:33 martin>

script_name=$(basename "$0")

logger "$script_name Network Manager WWAN $(nmcli radio wwan)"

# get device
logger "$script_name searching for broadband device"
device=$(ls /dev/cdc-wdm?)
logger "$script_name found $device"
mbimcli -p -d $device --quectel-set-radio-state=on
logger "$script_name fcc-lock disabled for $device"

# get modem (number)
logger "$script_name looking for modem"
modem=$(mmcli --list-modems | perl -p -e 's/.*Modem\/(\d+) .*/\1/g')
logger "$script_name found modem by number '$modem'"
mmcli --modem=$modem --enable
logger "$script_name modem by number '$modem' enabled at $device"

logger "$script_name to view logs: journalctl -u ModemManager -f"

tail -10 /var/log/syslog | grep -F -e "$script_name"
