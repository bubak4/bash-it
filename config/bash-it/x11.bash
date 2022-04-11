# duplicate from 00-env.bash, in some rare cases, it may not be defined
# (for example during X startup)
# portable way to get system temp directory
export TMPDIR=$(dirname $(mktemp -u))

#######################
# generic X utilities #
#######################

# Produces screenshot image of the screen.
# $1 .. file name without extension (defaults to 'screenshot')
# $2 .. file type extension (defaults to 'png')
function x-screenshot()
{
    local img="screenshot"
    local type="png"
    local ts=$(date +%F-%s)
    if test -n "$1"; then
        img=$1
    fi
    if test -n "$2"; then
        type=$2
    fi
    local xwd_file=$(mktemp $TMPDIR/x-screenshot-${img}-${ts}.XXXX.xwd)
    local target_file=${img}-${ts}.${type}
    xwd -out $xwd_file
    convert $xwd_file $target_file
    rm $xwd_file
    ls -l $target_file
}

function x-screenshot-jpg() { screenshot "screenshot" "jpg" ; }

function x-screensaver-on()
{
    xset +dpms
    xset s on
    pkill -SIGCONT -U $(id -u) xscreensaver
}

function x-screensaver-off()
{
    xset -dpms
    xset s off
    pkill -SIGSTOP -U $(id -u) xscreensaver
}

function x-kb-reset() {
    setxkbmap -model thinkpad60 -layout us -option
    xset -b # disable system beep
}

function x-kb-thinkpad()
{
    setxkbmap -model thinkpad60 \
        -layout us,cz \
        -option grp:shifts_toggle \
        -option grp_led:caps \
        -option ctrl:nocaps \
        -option compose:ralt
    xset -b # disable system beep
}

function x-kb-logitech()
{
    setxkbmap -model logidinovoedge \
        -layout us,cz \
        -option grp:shifts_toggle \
        -option grp_led:caps \
        -option ctrl:nocaps \
        -option compose:ralt
    xset -b # disable system beep
}

function x-mouse()
{
    # xset m acceleration threshold
    xset m 3 1
    for device_id in $(xinput --list | fgrep -e "TrackPoint" |
                           fgrep -e "pointer" |
                           perl -p -e 's/.*id=(\d+).*/\1/g') ; do
        if xinput --list-props $device_id | fgrep "libinput Accel Speed" >/dev/null ; then
            echo "I: setting movement speed for device $(xinput --list --name-only $device_id)"
            xinput --set-prop $device_id "libinput Accel Speed" -0.5
        fi
    done
}

function x-touchpad-on()
{
    if which synclient > /dev/null ; then
        synclient TouchpadOff=0
    fi
}

function x-touchpad-off()
{
    if which synclient > /dev/null ; then
        synclient TouchpadOff=1
    fi
}

#######################
# X display functions #
#######################

# Sets wallpaper (only for X11 session (ie. not GNOME on wayland)).
function x-wallpaper()
{
    local wallpaper=${WALLPAPER:-""}
    if test -z "$wallpaper" ; then
        #local wallpaper=galadriel-1440x900.jpg
        #local wallpaper=sc2_hyperion-1680x1050.jpg
        #local wallpaper=sc2_hyperion2-1680x1050.jpg
        #local wallpaper=sc2_sarah-1920x1200.jpg
        #local wallpaper=sc2_zeratul-1920x1200.jpg
        #local wallpaper=kv_malaovecka-1100x728.jpg
        #local wallpaper=kv_ponociruzove-1100x766.jpg
        local wallpaper=kv_nesusidodnanocisen-1100x723.jpg
        #local wallpaper=ritchey-p29er-1280x912.jpg
        #local wallpaper=ritchey-p29er-2880x1620-1080p.jpg
        #local wallpaper=ritchey-SwissCross-4k-1080p.jpg
        wallpaper=$BASH_IT/config/etc-x/wallpapers/$wallpaper
    fi
    if test -f "$wallpaper" && which hsetroot >/dev/null ; then
        hsetroot -fill $wallpaper
    else
        xsetroot -solid silver
    fi
}

# Find the connected/connected primary xrandr output, if any argument
# is given, just use it (if valid).
# Prints the result to stdout.  Usage: output=$(x-output)
function x-output()
{
    # save xrandr output as tmp data
    local tmp=$(mktemp $TMPDIR/x-output.XXXX)
    xrandr > $tmp

    if test -n "$1" ; then
        local all=$(cat $tmp | fgrep -e " connected " | cut -f 1 -d " ")
        for i in $all ; do
            if test $i = $1 ; then
                echo $1;
                return
            fi
        done
    fi

    # try to guess output
    local number_of_connected=$(cat $tmp | fgrep -e " connected" | wc -l)
    if test $number_of_connected = 1 ; then
        output=$(cat $tmp | fgrep -e " connected" | cut -f 1 -d " ")
    else
        local number_of_primary=$(cat $tmp | fgrep -e " connected primary" | wc -l)
        if test $number_of_primary = 1 ; then
            output=$(cat $tmp | fgrep -e " connected primary" | cut -f 1 -d " ")
        fi
    fi

    rm -f $tmp
    echo $output
}

# Computes DPI for specified output -- valid results can be computed
# only for connected and active outputs.
# Prints the result to stdout.
# Usage: dpi=$(x-dpi eDP1)
function x-dpi()
{
    local output=$(x-output "$1")
    local dpi=${DPI:-"96"}

    # save xrandr output as tmp data
    local tmp=$(mktemp $TMPDIR/x-dpi.XXXX)
    xrandr > $tmp

    if test -n "$output"; then

        if cat $tmp | egrep -e "^$output connected " | fgrep -e "mm x ">/dev/null 2>&1 ; then
            # output connected and resolution + size (in mm) is known
            $(cat $tmp | egrep -e "^$output connected " | perl -pe 's/.* (\d+)x(\d+)\+.* (\d+)mm x (\d+)mm/export x_px=\1 x_mm=\3 y_px=\2 y_mm=\4/g')
            if test -n "$x_px" -a -n "$x_mm" -a -n "$y_px" -a -n "$y_mm" ; then
                # all the variables are extracted
                local x_dpi=$(perl -e "print(int($x_px / ($x_mm / 25.4)))")
                local y_dpi=$(perl -e "print(int($y_px / ($y_mm / 25.4)))")
                unset x_px
                unset x_mm
                unset y_px
                unset y_mm
                dpi=$(expr $(expr $x_dpi + $y_dpi) / 2) # official value
            fi
        fi

    fi

    rm -f $tmp
    echo $dpi
}

# Applies given DPI to output and Xft.
# If output is not given, try to guess one.
# If dpi is not given, try to compute one.
# Usage: x-dpi-apply eDP1 96
function x-dpi-apply()
{
    local dpi=${2:-$(x-dpi $1)}
    echo "I: dpi == $dpi"
    echo "Xft.dpi: $dpi" | xrdb -merge
    xrandr --dpi $dpi
}

# Manages connected visual ports (physical displays).
# Default action is to change mode according to connected external device.
function x-display()
{
    # info | external | duplicate | extend | off
    local action=${1:-"info"}

    local requested_dpi=${DPI:-$(x-dpi)}
    local requested_mode=${MODE:-""}

    # save xrandr output as tmp data
    local tmp=$(mktemp $TMPDIR/x-display.XXXX)
    xrandr > $tmp

    # all connected devices
    local all=$(cat $tmp | fgrep -e " connected " | cut -f 1 -d " " | tr "\n" " ")

    # internal (hardcoded) vs external
    local internal=
    local externals=
    local external= # last external device is used as default
    # x230 -> LVDS*, x390 -> eDP*
    echo $all | fgrep -e LVDS >/dev/null && internal=LVDS
    echo $all | fgrep -e eDP >/dev/null && internal=eDP    
    for i in $all ; do
         if [[ $i == ${internal}* ]] ; then # startswith
            internal=$i
         else
            externals="$i $externals"
            external=$i
         fi
    done

    if test -z "$internal" ; then
        echo "E: no internal device found"
        return
    fi

    # reset any transformations
    if test $action != "info" ; then
        for i in $all ; do
            echo "I: resetting transformations for $i"
            xrandr --output $i --transform none
        done
    fi

    # get DPI
    local internal_dpi=$(x-dpi $internal)
    if test -n "$external" ; then
        local external_dpi=$(x-dpi $external)
    fi

    # find suitable internal and external mode
    local internal_mode=
    if test -n "$internal" ; then
        internal_mode=$(cat $tmp | egrep -e "^$internal " -A 1 | fgrep -v -e $internal | perl -pe 's/(\s+)((\d+)x(\d+))(.*)/\2/g')
    fi
    local external_mode=
    if test -n "$external" ; then
        external_mode=$(cat $tmp | egrep -e "^$external " -A 1 | fgrep -v -e $external | perl -pe 's/(\s+)((\d+)x(\d+))(.*)/\2/g')
    fi

    echo "I: all                         = $all"
    echo "I: internal                    = $internal"
    echo "I: internal_mode               = $internal_mode"
    echo "I: internal_dpi                = $internal_dpi"
    echo "I: externals                   = $externals"
    echo "I: external                    = $external"
    echo "I: external_mode               = $external_mode"
    echo "I: external_dpi                = $external_dpi"
    echo "I: requested_dpi               = $requested_dpi"
    echo "I: requested_mode              = $requested_mode"
    echo "I: action                      = $action"
    echo "I: GDK_SCALE                   = $GDK_SCALE"
    echo "I: GDK_DPI_SCALE               = $GDK_DPI_SCALE"
    xrdb -query | fgrep -e "Xft"

    if test "$action" = "info" ; then
        return
    elif test "$action" = "external" ; then
        xrandr --output $internal --off
        xrandr --output $external --primary
        x-dpi-apply $external $external_dpi
        local mode_to_apply=${requested_mode:-$external_mode}
        xrandr --output $external --auto --mode $mode_to_apply
        # recalculate DPI once the monitor is on (and the correct dimensions are known)
        old_external_dpi=$external_dpi
        new_external_dpi=$(x-dpi $external)
        if test $old_external_dpi -ne $new_external_dpi ; then
            echo "W: recalculated external dpi ($old_external_dpi => $new_external_dpi)"
            external_dpi=$new_external_dpi
            x-dpi-apply $external $external_dpi
            # reset mode and dpi to correct values
            xrandr --output $external --auto --mode $mode_to_apply
        fi
        # scaling if any
        if test $external_dpi -ge 144 ; then
            echo "I: scaling in effect"
            #xrandr --output $external --scale-from $internal_mode
            xrandr --output $external --scale 0.7x0.7
            dpi_after_scaling=$(x-dpi $external)
            # hack to override DPI to its logical valuez
            echo "Xft.dpi: $dpi_after_scaling" | xrdb -merge
            echo "I: dpi after scaling $dpi_after_scaling"
        fi
    elif test "$action" = "duplicate" ; then
        # internal
        xrandr --output $internal --primary
        xrandr --output $internal --auto --mode $internal_mode --dpi $internal_dpi
        # external
        x-dpi-apply $external $external_dpi # Xft will be set to $external_dpi
        xrandr --output $external --mode $external_mode --scale-from $internal_mode --same-as $internal
    elif test "$action" = "extend" ; then
        xrandr --output $internal \
            --auto \
            --primary \
            --mode $internal_mode \
            --dpi $internal_dpi

        x-dpi-apply $external # Xft will be set to $external_dpi
        # --above, --below, --right-of, --left-of
        xrandr --output $external \
            --auto \
            --mode $external_mode \
            --right-of $internal \
            --scale-from $internal_mode
    elif test "$action" = "off" ; then
        # check for disconnected external and fix them
        local disconnected_externals=$(cat $tmp | fgrep -e " disconnected " | fgrep -v "$internal" | cut -f 1 -d " ")
        for i in $disconnected_externals ; do
            external_mode=$(cat $tmp | fgrep -e $i -A 1 | fgrep -v -e $i | perl -pe 's/(\s+)((\d+)x(\d+))(.*)/\2/g')
            if [[ "$external_mode" =~ [[:digit:]]+x[[:digit:]]+ ]] ; then
                xrandr --addmode $i $internal_mode
                xrandr --output $i --mode $internal_mode
                xrandr --output $i --off
                xrandr --delmode $i $internal_mode
                echo "W: fixing disconnected external $i"
            fi
        done

        # turn off all but internal
        for i in $externals ; do
            xrandr --output $i --off
        done

        xrandr --output $internal --transform none
        xrandr --output $internal --panning 0x0
        xrandr --output $internal --primary
        x-dpi-apply $internal $requested_dpi
        xrandr --output $internal --auto
    fi

    x-wallpaper
    x-mouse
    x-kb-thinkpad

    if ps -C i3 >/dev/null ; then
        i3-msg restart
    fi

    # remove tmp data
    rm -f $tmp
}

function x-info()
{
    x-display info
}

function x-external-display-off()
{
    # unset DPI
    # unset MODE
    # unset GDK_SCALE
    # unset GDK_DPI_SCALE
    export DPI=120 # == 96 * 1.25 => 125%
    x-display off
}

# Full HD 16:9
function x-1k-display-on()
{
    unset DPI
    export MODE=1920x1080
    x-display external
}

# Quad HD 16:9
function x-2k-display-on()
{
    unset DPI
    export MODE=2560x1440
    x-display external
}

# Ultra HD 16:9
function x-4k-display-on()
{
    unset DPI
    export MODE=3840x2160
    x-display external
}

function x-duplicate()
{
    x-display duplicate
}
