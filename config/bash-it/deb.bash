# debian package functions

function deb-keyword-search() { apt-cache search $* ; }
function deb-search-for-file()
{
    local debs=`dpkg --get-selections | cut -f 1`
    for i in $debs; do
        echo "checking in deb: ${i}"
        dpkg --listfiles $i | \
            grep -e ^"$*"$ && echo "- - - - found in: $i" && break;
    done
}
function deb-info() { apt-cache show $1 ; }
function deb-list-files() { dpkg -L $1 ; }

# udev

function udev-info()
{
    local fout=$TMPDIR/udevinfo.txt
    cat > $fout <<EOF
+----------+
| overview |
+----------+
EOF
    udevadm info --query=all --path="$1" >> $fout
    cat >> $fout <<EOF
+------------+
| attributes |
+------------+
EOF
    udevadm info --query=all --path="$1" --attribute-walk >> $fout
    less $fout
}

function udev-reload() { udevadm control --reload-rules ; }

# bat

function bat-power() { for i in /sys/class/power_supply/BAT0/energy_* ; do echo -e "$(basename $i)\t$(cat $i)" ; done }
