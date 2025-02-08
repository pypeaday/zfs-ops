#!/bin/bash

# Exit on error
set -euo pipefail

# Script to replicate ZFS datasets from a source pool to a target directory using snapshots.
#
# This script performs the following actions:
# 1. Identifies all datasets within the specified ZFS pool.
# 2. Mounts the most recent snapshot for each dataset to a temporary mount point.
# 3. Uses `rsync` to recursively synchronize the dataset snapshot to a target directory.
# 4. Unmounts and removes the snapshot mount points after the sync is complete.
#
# The script supports dry-run mode for simulating the process without making any changes.
# It also provides debug logging to trace the execution in more detail.
#
# Parameters:
# - POOL_NAME: The name of the source ZFS pool (default: 'tank').
# - DESTINATION: The target directory for the rsync operation (default: '/backup').
# - RSYNC_OPTIONS: Options passed to `rsync` for file synchronization (default: '-aHAX --chmod=Da+s --info=progress2 --inplace --delete').
# - MOUNT_BASE: The base directory where ZFS snapshots will be mounted temporarily (default: '/mnt/zfs_snapshots').
# - --dry-run: If specified, the script performs a dry run without making changes.
# - --debug: If specified, the script enables debug mode for detailed logging.
#
# The script ensures that only the latest available snapshot of each dataset is used and ensures the integrity of the replication process by maintaining directory structure and synchronization status.

# Default parameters
POOL_NAME=${POOL_NAME:-tank}
DESTINATION=${DESTINATION:-/backup}
RSYNC_OPTIONS=${RSYNC_OPTIONS:-"-aHAX --chmod=Da+s --info=progress2 --inplace --delete"}
MOUNT_BASE=${MOUNT_BASE:-/mnt/zfs_snapshots}
DRY_RUN=false
DEBUG=false

# Usage information
usage() {
  echo "Usage: $0 [-p POOL_NAME] [-d DESTINATION] [-r RSYNC_OPTIONS] [-m MOUNT_BASE] [-n] [--debug]"
  echo "  -p POOL_NAME        ZFS pool name (default: 'tank')"
  echo "  -d DESTINATION      Destination for rsync (default: '/backup')"
  echo "  -r RSYNC_OPTIONS    Options passed to rsync (default: '-aHAX --chmod=Da+s --info=progress2 --inplace --delete')"
  echo "  -m MOUNT_BASE       Base directory to mount snapshots (default: '/mnt/zfs_snapshots')"
  echo "  -n, --dry-run       Perform a dry run (log actions without executing them)"
  echo "  --debug             Enable debug logging for troubleshooting"
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
    debug) DEBUG=true ;;
    *) usage ;;
    esac ;;
  h) usage ;;
  *) usage ;;
  esac
done

# Enable debug logging if requested
if [[ "$DEBUG" == "true" ]]; then
  set -x
fi

log_info() {
  echo "[INFO] $1"
}

log_warn() {
  echo "[WARN] $1"
}

log_error() {
  echo "[ERROR] $1"
  exit 1
}

# Validate destination directory
if [[ ! -d "$DESTINATION" && "$DRY_RUN" == "false" ]]; then
  log_error "Destination directory '$DESTINATION' does not exist."
fi

# Create the mount base if it doesn't exist
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$MOUNT_BASE"
fi

# Get datasets in the pool
DATASETS=$(zfs list -H -o name -t filesystem | grep "^${POOL_NAME}/" || true)
if [[ -z "$DATASETS" ]]; then
  log_warn "No datasets found in pool '$POOL_NAME'."
  exit 1
fi

log_info "Datasets found in pool '$POOL_NAME':"
echo "$DATASETS" | while read -r DATASET; do echo "  - $DATASET"; done

# Prepare an array for all mount points
MOUNT_POINTS=()

# Process each dataset
while read -r DATASET; do
  log_info "Processing dataset: $DATASET"

  # Get the most recent snapshot
  SNAPSHOT=$(zfs list -H -o name -t snapshot -r "$DATASET" 2>/dev/null | grep "^${DATASET}@" | tail -n 1 || true)
  if [[ -z "$SNAPSHOT" ]]; then
    log_warn "No snapshots found for dataset $DATASET. Skipping."
    continue
  fi
  log_info "Found snapshot: $SNAPSHOT"

  # Mount the snapshot to a temporary location
  MOUNT_POINT="${MOUNT_BASE}/${DATASET#${POOL_NAME}/}"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would create mount point: $MOUNT_POINT"
  else
    mkdir -p "$MOUNT_POINT"
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would mount snapshot $SNAPSHOT to $MOUNT_POINT"
  else
    log_info "Mounting snapshot to $MOUNT_POINT..."
    if ! mount -t zfs "$SNAPSHOT" "$MOUNT_POINT"; then
      log_error "Failed to mount snapshot $SNAPSHOT to $MOUNT_POINT. Skipping this dataset."
      rmdir "$MOUNT_POINT" # Remove the created mount point if mounting fails
      continue             # Skip this dataset and move on to the next one
    fi
  fi

  # Add mount point to the list
  MOUNT_POINTS+=("$MOUNT_POINT")

  # Ensure analogous child datasets in the target pool are mounted
  TARGET_POOL="${DESTINATION#/}"
  RELATIVE_PATH="${DATASET#$POOL_NAME/}"
  TARGET_DATASET="${TARGET_POOL}/${RELATIVE_PATH}"

  log_info "Ensuring target dataset $TARGET_DATASET is mounted..."
  if ! zfs get mounted "$TARGET_DATASET" | grep -q "mounted[[:space:]]*yes"; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "[Dry Run] Would mount $TARGET_DATASET"
    else
      log_info "Mounting target dataset $TARGET_DATASET..."
      if ! zfs mount "$TARGET_DATASET"; then
        log_error "Failed to mount target dataset $TARGET_DATASET. Skipping this dataset."
        umount "$MOUNT_POINT" # Unmount the snapshot
        rmdir "$MOUNT_POINT"  # Remove mount point if target fails to mount
        continue              # Skip this dataset and move on to the next one
      fi
    fi
  else
    log_info "Target dataset $TARGET_DATASET is already mounted."
  fi
done <<<"$DATASETS"

# Rsync from all mounted snapshots to the destination
log_info "Starting rsync operation..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[Dry Run] Would sync from ${MOUNT_BASE}/ to ${DESTINATION}/"
else
  if ! rsync $RSYNC_OPTIONS "${MOUNT_BASE}/" "$DESTINATION/"; then
    log_error "Rsync failed. Backup operation aborted."
    exit 1
  fi
fi

# Sort mount points based on depth (most nested first) and reverse the order
SORTED_MOUNT_POINTS=$(for point in "${MOUNT_POINTS[@]}"; do echo "$point"; done | sort -r)

# Unmount each mount point in reverse order
for MOUNT_POINT in $SORTED_MOUNT_POINTS; do
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would unmount $MOUNT_POINT"
  else
    log_info "Unmounting snapshot from $MOUNT_POINT..."
    umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"
  fi
done

log_info "Snapshot processing completed."
