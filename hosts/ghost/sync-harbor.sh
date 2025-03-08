#!/bin/bash

set -u

# hcio start
curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/harbor-replication/start

# --skip-parent
# This will skip the syncing of the parent dataset. Does nothing without '--recursive' option.
#
# --no-sync-snap:
# No new snapshot is created; replication uses existing snapshots.
#
# --sendoptions=w:
# Includes all written data in replication, ensuring synchronous send, and encryption on the target
#
# -r:
# Replicates the dataset and all its child datasets recursively.
#
# --no-privilege-elevation:
# No automatic privilege escalation (e.g., with sudo).
#
# --create-bookmark:
# Creates a zfs bookmark for the newest snapshot on the source after replication succeeds (only works with --no-sync-snap)
#
# --no-resume:
# Disables resumable transfers, requiring the replication to complete in one go.
#
# ONLY USED FOR INITIAL SYNC
# --preserve-properties:
# Preserves ZFS dataset properties (like compression, deduplication, mountpoints, etc.) during replication.

# TODO: change to --exclude-datasets once I update sanoid/syncoid on ghost
# syncoid --no-sync-snap --sendoptions=w -r --no-privilege-elevation --create-bookmark --no-resume --preserve-properties  --exclude-datasets tank/encrypted/nas/documents/paperless/consume tank/encrypted harbor/encrypted
syncoid --skip-parent --no-sync-snap --sendoptions=w -r --no-privilege-elevation --create-bookmark --no-resume --preserve-properties --exclude tank/encrypted/nas/documents/paperless/consume tank/encrypted harbor/encrypted

# hcio
curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/harbor-replication
