#!/bin/bash

set -e
# fail hcio if anything goes wrong
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/babyblue-aurora

# hcio start
# make new endpoint for local backup
# curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/syncoid/start

syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/docker tank/unencrypted_backup/docker

syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/docker/nextcloud-zfs tank/unencrypted_backup/docker/nextcloud-zfs

syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/nas tank/unencrypted_backup/nas
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/nas/documents tank/unencrypted_backup/nas/documents
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/nas/documents/paperless tank/unencrypted_backup/nas/documents/paperless
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/nas/dump tank/unencrypted_backup/nas/dump

# syncoid --skip-parent --no-sync-snap -r --no-privilege-elevation nic@ghost:tank/encrypted/vms tank/encrypted/vms
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/vms tank/unencrypted_backup/vms
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/vms/pihole tank/unencrypted_backup/vms/pihole
syncoid --no-sync-snap --no-privilege-elevation nic@ghost:tank/encrypted/vms/homeassistant tank/unencrypted_backup/vms/homeassistant

# hcio
curl -m 10 --retry 5 https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/babyblue-aurora