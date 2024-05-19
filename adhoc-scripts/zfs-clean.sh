#!/bin/bash

# Specify the dataset name to be saved
SAVE_DATASET="tank/encrypted/docker/nextcloud-zfs"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get a list of child datasets
CHILD_DATASETS=($(zfs list -H -o name -r tank/encrypted/docker))

# Iterate through child datasets
for DATASET in "${CHILD_DATASETS[@]}"; do
  # Check if the current dataset is not the parent or the one to be saved
  if [ "$DATASET" != "tank/encrypted/docker" ] && [ "$DATASET" != "$SAVE_DATASET" ]; then
    if [ "$DRY_RUN" == true ]; then
      # Dry run mode, just display what would be done
      echo "[Dry Run] Would delete dataset: $DATASET"
    else
      # Delete the dataset
      zfs destroy "$DATASET"
      echo "Dataset $DATASET deleted."
    fi
  fi
done

echo "Script execution complete."
