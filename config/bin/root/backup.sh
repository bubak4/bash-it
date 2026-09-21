#!/bin/bash
# Time-stamp: <2026-08-31 20:11:11 martin>

# reads /root, /var/lib/libvirt/images and restricted /etc subdirs; running as a
# normal user silently produces a partial backup, so refuse outright
if test "$(id -u)" -ne 0 ; then
    echo "E: must run as root"
    exit 1
fi

# find 'backup' mount point
backup_mount_point=`lsblk  -o mountpoint,label | fgrep -e backup | cut -f 1 -d " "`
target_dir=$backup_mount_point/backup

if test -z "$backup_mount_point" ; then
    echo "E: no backup mount point"
    exit 1
fi

if test -d "$target_dir" ; then
    target_dir=${target_dir}/`hostname`
    mkdir -p $target_dir
else
    echo "E: no target dir '$target_dir'"
    exit 1
fi

echo "backup_mount_point = $backup_mount_point"
echo "target_dir         = $target_dir"
echo "press Enter to continue or ^C"
read wait_for_enter

# debian meta-data
target_debian_dir=${target_dir}/debian
mkdir -p ${target_debian_dir}
dpkg --get-selections "*" > ${target_debian_dir}/dpkg--get-selections
for i in /var/lib/dpkg /var/lib/apt/extended_states /var/lib/aptitude/pkgstates ; do
    rsync --archive --verbose --progress --update --delete $i $target_debian_dir
done

# /etc
rsync --archive --verbose --progress --update --delete /etc $target_dir/

# /home
#
# Excludes fall into two kinds:
#   - paths starting with '/' are anchored to one exact location
#   - bare names ending in '/' are patterns matching a directory at any depth
#
# --delete-excluded is needed so that content copied here before an exclude
# existed is actually purged from the backup disk; plain --delete leaves it
# behind forever.
rsync --archive --verbose --progress --update --delete --delete-excluded \
      --exclude '/home/basex/isrep/basex/data' \
      --exclude '/home/basex/isrep/basex/source-xml' \
      --exclude '/home/martin/volumes' \
      --exclude '/home/martin/.m2/repository*' \
      --exclude '/home/martin/.cache' \
      --exclude '/home/martin/src/dain/ispop/var/oracle/dump' \
      --exclude '/home/oracle/install' \
      \
      `# games: installs are re-downloadable, saved games are not.` \
      `# unanchored, so it covers both the debian and the snap steam install.` \
      --exclude 'steamapps/common' \
      --exclude 'steamapps/shadercache' \
      --exclude '/home/martin/.cxoffice/StarCraft_II' \
      --exclude '/home/martin/.cxoffice/installers' \
      --exclude '/home/martin/.cxoffice/Dungeon_Keeper_2' \
      --exclude '/home/martin/.wine' \
      --exclude '/home/martin/.paradoxlauncher' \
      \
      `# IDE indexes and installer-sourced toolchains` \
      --exclude '/home/martin/.local/share/JetBrains' \
      --exclude '/home/martin/.local/opt' \
      --exclude '/home/martin/.local/share/Trash' \
      --exclude '/home/martin/.local/share/virtualenv' \
      --exclude '/home/martin/.local/share/virtualenvs' \
      --exclude '/home/martin/.local/share/mise' \
      --exclude '/home/martin/.m2/wrapper' \
      \
      `# electron/chromium caches (ferdium, stationv2, slack, ...)` \
      --exclude 'Cache/' \
      --exclude 'Code Cache/' \
      --exclude 'Service Worker/' \
      --exclude 'GPUCache/' \
      --exclude 'DawnCache/' \
      --exclude 'DawnGraphiteCache/' \
      --exclude 'GraphiteDawnCache/' \
      --exclude 'DawnWebGPUCache/' \
      \
      `# build artifacts.  keep .terraform/ as a directory name only -- real` \
      `# terraform.tfstate files sit as siblings and must stay backed up.` \
      --exclude '.terraform/' \
      --exclude 'node_modules/' \
      --exclude 'target/' \
      --exclude '.gradle/' \
      --exclude '.venv/' \
      --exclude 'build/' \
      --exclude '__pycache__/' \
      --exclude 'dist/' \
      \
      `# dev database data dirs living inside src checkouts` \
      --exclude '/home/martin/src/livesystems/senecura/volumes' \
      --exclude '/home/martin/src/livesystems/martin.slouf/strapi/volumes/strapi-postgres' \
      --exclude '/home/martin/src/livesystems/openplatform/openplatform-monitoring/volumes' \
      --exclude '/home/martin/src/livesystems/openplatform-2/openplatform-monitoring/volumes' \
      --exclude '/home/martin/src/7c/common/confluent-kafka-platform/volumes' \
      --exclude '/home/martin/src/7c/data-model/asset-openplatform/volumes' \
      \
      `# regenerable caches sitting inside data we do keep` \
      --exclude '/home/martin/Maildir/.notmuch/xapian' \
      --exclude '/home/martin/.mozilla/firefox/j6lmi5j4.default/storage/default/*/cache' \
      --exclude '/home/martin/.dropbox-dist' \
      --exclude '/home/martin/.dropbox' \
      \
      `# bulk media, kept out by choice -- except the cd rips, which are` \
      `# personal and irreplaceable, and the alert sound.  rsync takes`  \
      `# the first matching rule, so includes must come before the`      \
      `# exclude, and Music itself must not be excluded or it is`        \
      `# never entered.`                                                 \
      --include '/home/martin/Music/cdrip/***' \
      --include '/home/martin/Music/VesperTextAlert.wav' \
      --exclude '/home/martin/Music/*' \
      --exclude '/home/martin/Videos' \
      \
      `# gvfs fuse mount, never descend into it` \
      --exclude '/home/martin/.gvfs' \
      /home $target_dir/

# /opt
rsync --archive --verbose --progress --update --delete \
      --exclude '/opt/oracle' \
      --exclude '/opt/ORCLfmap' \
      /opt $target_dir/

# /root
rsync --archive --verbose --progress --update --delete \
      /root $target_dir/

# /var
rsync --archive --verbose --progress --update --delete \
      /var/lib/libvirt/images $target_dir/
