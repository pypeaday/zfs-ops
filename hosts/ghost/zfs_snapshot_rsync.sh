#!/bin/bash

# Exit on error
set -euo pipefail

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
DATASETS=$(zfs list -H -o name -t filesystem | grep "^${POOL_NAME}/")
if [[ -z "$DATASETS" ]]; then
  log_warn "No datasets found in pool '$POOL_NAME'."
  exit 1
fi

log_info "Datasets found in pool '$POOL_NAME':\n$DATASETS"

# Process each dataset
for DATASET in $DATASETS; do
  log_info "Processing dataset: $DATASET"

  # Get the most recent snapshot
  SNAPSHOT=$(zfs list -H -o name -t snapshot -r "$DATASET" | grep "^${DATASET}@" | tail -n 1)
  if [[ -z "$SNAPSHOT" ]]; then
    log_warn "No snapshots found for dataset $DATASET. Skipping."
    continue
  fi
  log_info "Found snapshot: $SNAPSHOT"

  # Prepare mount point
  MOUNT_POINT="${MOUNT_BASE}/${DATASET//\//_}"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would create mount point: $MOUNT_POINT"
  else
    mkdir -p "$MOUNT_POINT"
  fi

  # Mount the snapshot
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would mount snapshot $SNAPSHOT to $MOUNT_POINT (read-only)"
  else
    log_info "Mounting snapshot to $MOUNT_POINT..."
    zfs mount -o ro "$SNAPSHOT" "$MOUNT_POINT"
  fi

  # Sync snapshot to destination
  RELATIVE_PATH="${DATASET#$POOL_NAME/}"
  TARGET_PATH="${DESTINATION}/${RELATIVE_PATH}"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would sync $MOUNT_POINT/ to $TARGET_PATH/"
  else
    log_info "Syncing snapshot to $TARGET_PATH..."
    mkdir -p "$TARGET_PATH"
    rsync $RSYNC_OPTIONS "$MOUNT_POINT/" "$TARGET_PATH/"
  fi

  # Unmount snapshot
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[Dry Run] Would unmount $MOUNT_POINT"
  else
    log_info "Unmounting snapshot from $MOUNT_POINT..."
    umount "$MOUNT_POINT"
    rmdir "$MOUNT_POINT"
  fi
done

log_info "Snapshot processing completed."
