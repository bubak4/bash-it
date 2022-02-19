#!/bin/bash
# Time-stamp: <2022-01-30 09:19:52 martin>
# synchronizes /usr/local/share/ca-certificates with firefox certstore
# please use default system utilities to manage /usr/local/share/ca-certificates (update-ca-certificates)

which certutil >/dev/null || (echo "W: please install libnss3-tools (Debian: apt install libnss3-tools)" && exit 1)
test $? -ne 0 && exit 1

firefox_ca_store=$(find ~/.mozilla -name cert9.db)
firefox_ca_dir=$(dirname $firefox_ca_store)
firefox_local_ca=$(certutil -d sql:${firefox_ca_dir} -L | fgrep -e "Local CA")
# root CA must end with *.crt -- convention for
system_local_ca=$(find /usr/local/share/ca-certificates/ -name "*.crt")
cp $firefox_ca_store ${firefox_ca_store}-backup-$(date --iso-8601)

echo "I: firefox_ca_store = $firefox_ca_store"
echo "I: firefox_ca_dir   = $firefox_ca_dir"
echo "I: system_local_ca  = $system_local_ca"
echo

for i in $system_local_ca ; do
    ca_name=$(openssl x509 -in $i -text | fgrep -e "Issuer:" | perl -p -e 's/.*CN = ([\w-_ ]+).*/Local CA - \1/g')
    if echo $firefox_local_ca | fgrep -e "$ca_name" > /dev/null ; then
        echo "I: ALREADY THERE $ca_name ($i)"
    else
        echo "I: IMPORTING '$i' with nickname '$ca_name'"
        certutil -d sql:${firefox_ca_dir} -A -i $i -n "$ca_name" -t "TC,,"
    fi
done

echo
certutil -d sql:${firefox_ca_dir} -L | fgrep -e "Local CA"
