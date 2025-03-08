#!/bin/bash

# fail hcio if anything goes wrong
set -e

# # uptime kuma
# curl http://ghost:3003/api/push/CwMdeuJL4T?status=up &
# msg=OK &
# ping=

# echo "Syncing nic@ghost:tank/encrypted!"
# Really only need this because I have the "encrypted" parent dataset from not
# using encryption in the beginning. This makes sure though that tank/encrytped
# will exist on the backup
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/syncoid/start
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted tank/encrypted
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/syncoid

# echo "Syncing nic@ghost:tank/encrypted/10Fold!"
# this dataset sometimes causes issues but I don't need it anyways
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/10Fold tank/encrypted/10Fold

# echo "Syncing nic@ghost:tank/encrypted/fs!" >>/home/nic/mycron.log
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/fs tank/encrypted/fs
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/fs/home tank/encrypted/fs/home

curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-docker/start
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/docker tank/encrypted/docker
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-docker

curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-nextcloud/start
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/docker/nextcloud-zfs tank/encrypted/docker/nextcloud-zfs
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-nextcloud

curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-paperless/start
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/docker/paperless-ngx tank/encrypted/docker/paperless-ngx
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-paperless

curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-nas/start
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/nas tank/encrypted/nas
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/nas/documents tank/encrypted/nas/documents
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/nas/documents/paperless tank/encrypted/nas/documents/paperless
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/nas/dump tank/encrypted/nas/dump
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/nas/torrents tank/encrypted/nas/torrents
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-nas

curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-vms/start
# syncoid --skip-parent --no-sync-snap --sendoptions=w -r --no-privilege-elevation nic@ghost:tank/encrypted/vms tank/encrypted/vms
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/vms tank/encrypted/vms
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/vms/pihole tank/encrypted/vms/pihole
syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation --create-bookmark --no-resume nic@ghost:tank/encrypted/vms/homeassistant tank/encrypted/vms/homeassistant
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/win10 tank/encrypted/vms/win10
# syncoid --no-sync-snap --sendoptions=w --no-privilege-elevation nic@ghost:tank/encrypted/vms/block-subnet-router tank/encrypted/vms/block-subnet-router
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/ghost-vault-vms

# curl http://ghost:3003/api/push/hp6KnHdVXJ?status=up &
# msg=OK &
# ping=
