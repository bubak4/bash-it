# environment setup

# portable way to get system temp directory
export TMPDIR=$(dirname $(mktemp -u))

export BROWSER="run_firefox"

# - - - - less

export PAGER="less"
export VIEWER="$PAGER"
export LESS="-R"
if test -f /usr/share/source-highlight/src-hilite-lesspipe.sh ; then
    LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
    export LESSOPEN
fi

# - - - - fetchmail

FETCHMAIL_INCLUDE_DEFAULT_X509_CA_CERTS=1
export FETCHMAIL_INCLUDE_DEFAULT_X509_CA_CERTS

# - - - - xmllint

XMLLINT_INDENT="    "
export XMLLINT_INDENT

# - - - - rsync

CVS_RSH="ssh"
RSYNC_RSH="ssh"

export CVS_RSH RSYNC_RSH

# - - - - libvirt

VIRSH_DEFAULT_CONNECT_URI=qemu:///session
LIBVIRT_DEBUG=1

export VIRSH_DEFAULT_CONNECT_URI LIBVIRT_DEBUG
