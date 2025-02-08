# ZFS Ops

This repo contains ZFS replication configurations and scripts for my various machines. It uses systemd timers to schedule regular ZFS dataset replication between hosts.

## Overview

The repository is organized by host, with each host having its own replication configuration:

```
hosts/
  ├── ghost/                 # Primary server
  │   ├── harbor-replication.service
  │   ├── harbor-replication.timer
  │   └── syncoid-replication.sh
  └── ghost-vault/          # Backup server
      ├── syncoid-replication.service
      ├── syncoid-replication.timer
      └── syncoid-replication.sh
```

## Replication Schedule

- Harbor replication runs on even hours (0,2,4,...,22)
- Syncoid replication runs on odd hours (1,3,5,...,23)

This ensures that replications don't overlap and are spread evenly throughout the day.

## Setup

1. Clone this repo to your home directory:
   ```bash
   git clone <repo-url> ~/zfs-ops
   ```

2. Install dependencies:
   - sanoid/syncoid (for ZFS snapshot management and replication)
   - [just](https://github.com/casey/just) for running setup recipes
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
   ```

3. Run the appropriate setup recipe for your host:
   ```bash
   just setup-ghost      # For ghost server
   just setup-ghost-vault # For ghost-vault server
   ```

## Available Recipes

- `setup-ghost`: Sets up harbor replication on the ghost server
- `setup-ghost-vault`: Sets up syncoid replication on the ghost-vault server
- `setup-harbor`: Installs and enables the harbor replication systemd service/timer

## Notes

- The repository assumes installation in the home directory as some scripts reference absolute paths
- Healthcheck URLs in the replication scripts should be updated with your own URLs
- ZFS dataset creation and permissions are not handled by this repository - they must be set up manually

## Legacy

The `ansible/` directory contains the old ansible-based setup which is being phased out in favor of direct systemd service management.
