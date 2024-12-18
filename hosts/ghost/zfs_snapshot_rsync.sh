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
  ./zfs_snapshot_rsync.sh [-p POOL_NAME] [-d DESTINATION] [-r RSYNC_OPTIONS] [-m MOUNT_BASE] [-n]

Parameters:
  -p POOL_NAME        ZFS pool name to process (default: "tank").
  -d DESTINATION      Directory where datasets will be synced (default: "/backup").
  -r RSYNC_OPTIONS    Options to pass to the `rsync` command (default: "-aHAX --chmod=Da+s --info=progress2 --inplace  --delete").
  -m MOUNT_BASE       Base directory where snapshots will be temporarily mounted 
                      (default: "/mnt/zfs_snapshots").
  -n, --dry-run       Perform a dry run. No snapshots will be mounted or synced, but actions
                      will be logged as if the script were running.

Examples:
  Sync the most recent snapshots from "tank" to "/backup":
    ./zfs_snapshot_rsync.sh -p tank -d /backup

  Specify custom rsync options and enable dry run:
    ./zfs_snapshot_rsync.sh -r "-a --delete" -n

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

Default rsync options breakdown:

  -a (archive mode): 
  ensures that symbolic links, permissions, ownership, timestamps, and
  directories are preserved. It is a shorthand for -rlptgoD.

  -H (preserve hard links): 
    If your source contains hard links, this option will
    ensure that the hard links are preserved during the sync.

  -A (preserve ACLs)

  -X (preserve extended attributes): 
    Extended attributes are filesystem-specific attributes used by various
    systems (e.g., SELinux, Apple file systems, etc.). This ensures they are
    copied as well.

  --chmod=Da+s (apply file permissions): 
    Modifies file permissions during the sync. Specifically:

      D ensures that directories have proper permissions. 
      a+s ensures that the "setuid" and "setgid" bits are preserved for
      executable files. 

  --info=progress2 (show progress): 
    Provides detailed progress information, including the number of files
    transferred and the total transfer speed.

  --inplace (update files in place): 
    Update the files in the destination directory in place instead of creating
    temporary copies.

  --delete (remove extraneous files): 
    Makes the destination folder mirror the source exactly. Files
    in the destination that do not exist in the source will be deleted. 
'

# Default parameters
POOL_NAME=${POOL_NAME:-tank}
DESTINATION=${DESTINATION:-/backup}
RSYNC_OPTIONS=${RSYNC_OPTIONS:-"-aHAX --chmod=Da+s --info=progress2 --inplace  --delete"}
MOUNT_BASE=${MOUNT_BASE:-/mnt/zfs_snapshots}
DRY_RUN=false

usage() {
  echo "Usage: $0 [-p POOL_NAME] [-d DESTINATION] [-r RSYNC_OPTIONS] [-m MOUNT_BASE] [-n]"
  echo "  -p POOL_NAME        ZFS pool name (default: 'tank')"
  echo "  -d DESTINATION      Destination for rsync (default: '/backup')"
  echo "  -r RSYNC_OPTIONS    Options passed to rsync (default: '-aHAX --chmod=Da+s --info=progress2 --inplace  --delete')"
  echo "  -m MOUNT_BASE       Base directory to mount snapshots (default: '/mnt/zfs_snapshots')"
  echo "  -n, --dry-run       Perform a dry run (log actions without executing them)."
  exit 1
}

# Parse command-line arguments
while getopts ":p:d:r:m:nh-:" opt; do
  case "${opt}" in
  p) POOL_NAME=${OPTARG} ;;
  d) DESTINATION=${OPTARG} ;;
  r) RSYNC_OPTIONS=${OPTARG} ;;
  m) MOUNT_BASE=${OPTARG} ;;
  n) DRY_RUN=true ;;
  -) # Handle long options
    case "${OPTARG}" in
    dry-run) DRY_RUN=true ;;
    *) usage ;;
    esac ;;
  h) usage ;;
  *) usage ;;
  esac
done

# Ensure destination directory exists
if [[ ! -d "$DESTINATION" && "$DRY_RUN" == "false" ]]; then
  echo "Error: Destination directory '$DESTINATION' does not exist."
  exit 1
fi

# Create the mount base if it doesn't exist
mkdir -p "$MOUNT_BASE"

# Get the datasets in the pool (exclude the pool name itself)
DATASETS=$(zfs list -H -o name -t filesystem | grep "^${POOL_NAME}/")

if [[ -z "$DATASETS" ]]; then
  echo "No datasets found in pool '$POOL_NAME'."
  exit 1
fi
echo "Datasets found: $DATASETS"

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

  # Prepare mount point based on dataset name
  MOUNT_POINT="${MOUNT_BASE}/${DATASET//\//_}"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [Dry Run] Would create mount point: $MOUNT_POINT"
  else
    mkdir -p "$MOUNT_POINT"
  fi

  # Mount the snapshot in read-only mode
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [Dry Run] Would mount snapshot $SNAPSHOT to $MOUNT_POINT (read-only)"
  else
    echo "  Mounting snapshot to $MOUNT_POINT..."
    zfs mount -o ro "$SNAPSHOT" "$MOUNT_POINT"
  fi

  # Determine target path, preserving hierarchy
  RELATIVE_PATH="${DATASET#$POOL_NAME/}" # Strip the pool name from the dataset path
  TARGET_PATH="${DESTINATION}/${RELATIVE_PATH}"

  # Sync the mounted snapshot to the target destination
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [Dry Run] Would sync $MOUNT_POINT/ to $TARGET_PATH/"
  else
    echo "  Syncing snapshot to $TARGET_PATH..."
    mkdir -p "$TARGET_PATH"
    rsync $RSYNC_OPTIONS "$MOUNT_POINT/" "$TARGET_PATH/"
  fi

  # Unmount the snapshot
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [Dry Run] Would unmount $MOUNT_POINT"
  else
    echo "  Unmounting snapshot from $MOUNT_POINT..."
    umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"
  fi
done

echo "All datasets processed successfully!"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "[Dry Run] No changes were made. This was a simulation."
fi
