#!/bin/bash

# Exit on error
set -euo pipefail

: '
zfs_snapshot_rsync.sh
----------------------

This script automates the process of mounting the most recent ZFS snapshots for all datasets 
in a specified ZFS pool, syncing the contents to a specified destination using `rsync`, and 
then unmounting the snapshots. The snapshots are mounted in read-only mode to ensure data integrity.

Usage:
  ./zfs_snapshot_rsync.sh [-p POOL_NAME] [-d DESTINATION] [-r RSYNC_OPTIONS] [-m MOUNT_BASE]

Parameters:
  -p POOL_NAME        ZFS pool name to process (default: "tank").
  -d DESTINATION      Directory where snapshots will be synced (default: "/backup").
  -r RSYNC_OPTIONS    Options to pass to the `rsync` command (default: "-av --progress").
  -m MOUNT_BASE       Base directory where snapshots will be temporarily mounted 
                      (default: "/mnt/zfs_snapshots").

Examples:
  Sync the most recent snapshots from "tank" to "/backup":
    ./zfs_snapshot_rsync.sh -p tank -d /backup

  Specify custom rsync options and mount directory:
    ./zfs_snapshot_rsync.sh -r "-aHAX --delete" -m /tmp/mnt_snapshots

  Use environment variables for configuration:
    export POOL_NAME=tank
    export DESTINATION=/data/backup
    ./zfs_snapshot_rsync.sh

Requirements:
  - ZFS must be installed and configured on the system.
  - The destination directory must exist before running the script.
  - The user must have sufficient privileges to manage ZFS mounts and snapshots.

Notes:
  - The script cleans up mount points after syncing to avoid clutter.
  - Errors in mounting or unmounting are logged to the console.
  - Ensure you have enough storage space at the destination for the data being synced.
'
# Default parameters (can be overridden by arguments or environment variables)
POOL_NAME=${POOL_NAME:-tank}
DESTINATION=${DESTINATION:-/backup}
RSYNC_OPTIONS=${RSYNC_OPTIONS:-"-av --progress"}
MOUNT_BASE=${MOUNT_BASE:-/mnt/zfs_snapshots}

# Helper function to print usage
usage() {
  echo "Usage: $0 [-p POOL_NAME] [-d DESTINATION] [-r RSYNC_OPTIONS] [-m MOUNT_BASE]"
  echo "  -p POOL_NAME        ZFS pool name (default: 'tank')"
  echo "  -d DESTINATION      Destination for rsync (default: '/backup')"
  echo "  -r RSYNC_OPTIONS    Options passed to rsync (default: '-av --progress')"
  echo "  -m MOUNT_BASE       Base directory to mount snapshots (default: '/mnt/zfs_snapshots')"
  exit 1
}

# Parse command-line arguments
while getopts ":p:d:r:m:h" opt; do
  case "${opt}" in
  p) POOL_NAME=${OPTARG} ;;
  d) DESTINATION=${OPTARG} ;;
  r) RSYNC_OPTIONS=${OPTARG} ;;
  m) MOUNT_BASE=${OPTARG} ;;
  h) usage ;;
  *) usage ;;
  esac
done

# Verify that the destination directory exists
if [[ ! -d "$DESTINATION" ]]; then
  echo "Error: Destination directory '$DESTINATION' does not exist."
  exit 1
fi

# Create the mount base if it doesn't exist
mkdir -p "$MOUNT_BASE"

# Get the datasets in the pool
DATASETS=$(zfs list -H -o name -t filesystem | grep "^${POOL_NAME}")

if [[ -z "$DATASETS" ]]; then
  echo "No datasets found in pool '$POOL_NAME'."
  exit 1
fi

echo "Starting to process datasets in pool '$POOL_NAME'..."

for DATASET in $DATASETS; do
  echo "Processing dataset: $DATASET"

  # Get the most recent snapshot
  SNAPSHOT=$(zfs list -H -o name -t snapshot -r "$DATASET" | tail -n 1)

  if [[ -z "$SNAPSHOT" ]]; then
    echo "  No snapshots found for dataset $DATASET. Skipping."
    continue
  fi

  echo "  Found snapshot: $SNAPSHOT"

  # Prepare mount point
  MOUNT_POINT="${MOUNT_BASE}/${SNAPSHOT//\//_}"
  mkdir -p "$MOUNT_POINT"

  # Mount the snapshot in read-only mode
  echo "  Mounting snapshot to $MOUNT_POINT..."
  zfs mount -o ro "$SNAPSHOT" "$MOUNT_POINT"

  # Sync the mounted snapshot
  echo "  Syncing snapshot to $DESTINATION..."
  rsync $RSYNC_OPTIONS "$MOUNT_POINT/" "${DESTINATION}/${SNAPSHOT//\//_}/"

  # Unmount the snapshot
  echo "  Unmounting snapshot from $MOUNT_POINT..."
  umount "$MOUNT_POINT"

  # Cleanup mount point
  rmdir "$MOUNT_POINT"
done

echo "All datasets processed successfully!"
