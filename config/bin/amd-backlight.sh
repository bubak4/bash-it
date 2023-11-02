#!/bin/bash
# Time-stamp: <2023-11-01 02:49:56 martin>

usage() { echo "$0 usage:" && grep " .)\ # " "$0"; exit 0; }

[ $# -eq 0 ] && usage

target_value=80

while getopts ":hi:d:" arg; do
  case $arg in
    i) # Increase brightness by value
        target_value=$(expr $(cat /sys/class/backlight/amdgpu_bl0/brightness) + $OPTARG)
      ;;
    d) # Decrease brightness by value.
        target_value=$(expr $(cat /sys/class/backlight/amdgpu_bl0/brightness) - $OPTARG)
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done

echo "requested brightness $target_value"
if test "$target_value" -lt 20 -o "$target_value" -gt 200 ; then
    target_value=50
    echo "override brigtness to $target_value"
fi
echo $target_value | sudo tee /sys/class/backlight/amdgpu_bl0/brightness
