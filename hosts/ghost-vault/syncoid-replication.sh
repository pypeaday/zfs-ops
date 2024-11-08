#!/bin/bash

# fail hcio if anything goes wrong
set -e

# hcio start
curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/syncoid/start

# # uptime kuma
# curl http://ghost:3003/api/push/CwMdeuJL4T?status=up &
# msg=OK &
# ping=

# echo "Syncing nic@ghost:tank/encrypted!"
# Really only need this because I have the "encrypted" parent dataset from not
# using encryption in the beginning. This makes sure though that tank/encrytped
# will exist on the backup
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted tank/encrypted

# echo "Syncing nic@ghost:tank/encrypted/10Fold!"
# this dataset sometimes causes issues but I don't need it anyways
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/10Fold tank/encrypted/10Fold

# echo "Syncing nic@ghost:tank/encrypted/fs!" >>/home/nic/mycron.log
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/fs tank/encrypted/fs
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/fs/home tank/encrypted/fs/home

echo "Syncing nic@ghost:tank/encrypted/vms!"
# syncoid --skip-parent --no-sync-snap --sendoptions=w -r --no-privilege-elevation nic@ghost:tank/encrypted/vms tank/encrypted/vms
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms tank/encrypted/vms
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/pihole tank/encrypted/vms/pihole
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/homeassistant tank/encrypted/vms/homeassistant
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/win10 tank/encrypted/vms/win10
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/block-subnet-router tank/encrypted/vms/block-subnet-router

echo "Syncing nic@ghost:tank/encrypted/docker!"
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/docker tank/encrypted/docker

echo "Syncing nic@ghost:tank/encrypted/docker/nextcloud-zfs!"
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/docker/nextcloud-zfs tank/encrypted/docker/nextcloud-zfs

echo "Syncing nic@ghost:tank/encrypted/nas! excluding tank/encrypted/nas/media"
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/nas tank/encrypted/nas
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/nas/documents tank/encrypted/nas/documents
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/nas/documents/paperless tank/encrypted/nas/documents/paperless
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/nas/dump tank/encrypted/nas/dump
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/nas/torrents tank/encrypted/nas/torrents

# hcio
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/syncoid

# curl http://ghost:3003/api/push/hp6KnHdVXJ?status=up &
# msg=OK &
# ping=
