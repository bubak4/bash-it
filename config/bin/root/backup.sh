#!/bin/bash
# Time-stamp: < rsync-backup.sh (2018-07-10 13:12) >

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
rsync --archive --verbose --progress --update --delete \
      --exclude '/home/basex/isrep/basex/data' \
      --exclude '/home/basex/isrep/basex/source-xml' \
      --exclude '/home/martin/src/dain/ispop/var/oracle/dump' \
      --exclude '/home/oracle/install' \
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
