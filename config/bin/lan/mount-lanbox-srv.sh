#!/bin/bash

sudo sshfs \
  -o ro,nodev,noatime,allow_other,max_read=65536,StrictHostKeyChecking=no,UserKnownHostsFile=/dev/null,IdentityFile=/home/martin/.ssh/id_rsa.pem,port=5022 \
  martin@aws.slouf.name:/srv /mnt
