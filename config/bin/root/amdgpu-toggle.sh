#!/bin/bash

x11_conf=/etc/X11/xorg.conf.d/framebuffer-device.conf
fb_conf=/etc/modprobe.d/amdgpu-blacklist.conf
suffix=not-used

if test -f $x11_conf -a -f $fb_conf ; then
    x11_conf_source=$x11_conf
    x11_conf_target=${x11_conf}.${suffix}
    fb_conf_source=$fb_conf
    fb_conf_target=${fb_conf}.${suffix}
else
    x11_conf_source=${x11_conf}.${suffix}
    tmp=$(basename ${x11_conf} .${suffix})
    x11_conf_target=$(dirname $x11_conf)/$tmp
    fb_conf_source=${fb_conf}.${suffix}
    tmp=$(basename ${fb_conf} .${suffix})
    fb_conf_target=$(dirname $fb_conf)/$tmp
fi

echo "$x11_conf_source -> $x11_conf_target"
mv $x11_conf_source $x11_conf_target

echo "$fb_conf_source -> $fb_conf_target"
mv $fb_conf_source $fb_conf_target

test -f $x11_conf_target || echo "not found $x11_conf_target"
test -f $fb_conf_target || echo "not found $fb_conf_target"

update-grub
