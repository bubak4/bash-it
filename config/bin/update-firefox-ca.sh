#!/bin/bash
# Time-stamp: <2023-10-22 13:39:37 martin>
# synchronizes /usr/local/share/ca-certificates with firefox certstore
# please use default system utilities to manage /usr/local/share/ca-certificates (update-ca-certificates)

which certutil >/dev/null || (echo "W: please install libnss3-tools (Debian: apt install libnss3-tools)" && exit 1)
test $? -ne 0 && exit 1

firefox_ca_prefix="Local CA"
firefox_ca_store=$(find ~/.mozilla -name cert9.db)
firefox_ca_dir=$(dirname "$firefox_ca_store")
firefox_local_ca=$(certutil -d sql:"${firefox_ca_dir}" -L | fgrep -e "${firefox_ca_prefix}")
# root CA must end with *.crt -- convention for
system_local_ca=$(find /usr/local/share/ca-certificates/ -name "*.crt")
cp "$firefox_ca_store" "${firefox_ca_store}-backup-$(date --iso-8601)"

echo "I: firefox_ca_store = $firefox_ca_store"
echo "I: firefox_ca_dir   = $firefox_ca_dir"
echo "I: system_local_ca  = $system_local_ca"

#certutil -d sql:/home/martin/.mozilla/firefox/j6lmi5j4.default -D -n "Local CA - seven-root-ca"
#openssl x509 -noout -modulus -in ${crt} | openssl md5
#certutil -d sql:/home/martin/.mozilla/firefox/j6lmi5j4.default -L -n "Local CA - localhost" -r | openssl x509 -in /dev/stdin -outform pem | openssl x509 -noout -modulus -in /dev/stdin | openssl md5

for i in $system_local_ca ; do
    ca_name=$(openssl x509 -in "$i" -text | fgrep -e "Issuer:" | perl -p -e 's/.*CN = ([\w-_ ]+).*/\1/g')
    ca_md5=$(openssl x509 -noout -modulus -in "$i" | openssl md5)
    ff_name=$(certutil -d "sql:${firefox_ca_dir}" -L | fgrep -e "$ca_name")
    ff_nickname="$firefox_ca_prefix - $ca_name"
    crt_add=""
    echo "---- checking $ca_name ($i)"
    if echo $firefox_local_ca | fgrep -e "$ca_name" > /dev/null ; then
        echo "  found '$ca_name' ($i) in firefox"
        ff_md5=$(certutil -d "sql:${firefox_ca_dir}" -L -n "${ff_nickname}" -r | openssl x509 -in /dev/stdin -outform pem | openssl x509 -noout -modulus -in /dev/stdin | openssl md5)
        echo "  $ca_name ca_md5 = $ca_md5"
        echo "  $ca_name ff_md5 = $ff_md5"
        if test "$ca_md5" = "$ff_md5" ; then
            echo "  $ca_name == $ff_nickname, no action necessary"
        else
            echo "  $ca_name will be updated"
            certutil -d sql:${firefox_ca_dir} -D -n "$ff_nickname"
            echo "  $ca_name deleted"
            crt_add="1"
        fi
    else
        echo "  $ca_name will be added"
        crt_add="1"
    fi

    if test -n "$crt_add" ; then
        certutil -d sql:${firefox_ca_dir} -A -i $i -n "$ff_nickname" -t "TC,,"
        echo "  $ca_name imported as $ff_nickname"
    fi
done

echo
certutil -d sql:${firefox_ca_dir} -L | fgrep -e "$firefox_ca_prefix"
