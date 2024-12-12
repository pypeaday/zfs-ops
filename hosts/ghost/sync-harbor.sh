#!/bin/bash

set -e

# hcio start
curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/harbor-replication/start

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
# --no-stream:
# This argument tells syncoid to use -i incrementals, not -I. This updates the
# target with the newest snapshot from the source, without replicating the
# intermediate snapshots in between. (If used for an initial synchronization,
# will do a full replication from newest snapshot and exit immediately, rather
# than starting with the oldest and then doing an immediate -i to the newest.)
#
# ONLY USED FOR INITIAL SYNC
# --preserve-properties:
# Preserves ZFS dataset properties (like compression, deduplication, mountpoints, etc.) during replication.

syncoid --no-sync-snap --sendoptions=w -r --no-privilege-elevation --create-bookmark --no-resume --no-stream --preserve-properties tank/encrypted harbor/encrypted

# hcio
curl https://hc-ping.com/uWDfVXr2W4O9rF7deuOEog/harbor-replication
