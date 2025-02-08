default:
    @just --choose

# Setup systemd services and timers for ghost-vault ZFS replication
setup-ghost-vault:
    #!/usr/bin/env bash
    set -euxo pipefail

    sudo cp ./hosts/ghost-vault/syncoid-replication.service /etc/systemd/system/syncoid-replication.service
    sudo cp ./hosts/ghost-vault/syncoid-replication.timer /etc/systemd/system/syncoid-replication.timer

    sudo systemctl daemon-reload
    sudo systemctl enable syncoid-replication.timer
    sudo systemctl start syncoid-replication.timer

# Setup systemd services and timers for harbor replication on ghost
setup-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail

    sudo cp ./hosts/ghost/harbor-replication.service /etc/systemd/system/harbor-replication.service
    sudo cp ./hosts/ghost/harbor-replication.timer /etc/systemd/system/harbor-replication.timer

    sudo systemctl daemon-reload
    sudo systemctl enable harbor-replication.timer
    sudo systemctl start harbor-replication.timer

# Setup ZFS load-key service for encrypted datasets
setup-zfs-load-key:
    #!/usr/bin/env bash
    set -euxo pipefail

    sudo cp ./ansible/roles/zfs/templates/zfs-load-key.service /etc/systemd/system/zfs-load-key.service
    sudo systemctl daemon-reload
    sudo systemctl enable zfs-load-key.service
    sudo systemctl start zfs-load-key.service

# Check status of harbor replication on ghost
status-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail
    systemctl status harbor-replication.timer

# Check status of syncoid replication on ghost-vault
status-syncoid:
    #!/usr/bin/env bash
    set -euxo pipefail
    systemctl status syncoid-replication.timer

# Stop harbor replication on ghost
stop-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl stop harbor-replication.timer

# Stop syncoid replication on ghost-vault
stop-syncoid:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl stop syncoid-replication.timer

# Start harbor replication on ghost
start-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl start harbor-replication.timer

# Start syncoid replication on ghost-vault
start-syncoid:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl start syncoid-replication.timer

# Reload systemd and restart harbor replication on ghost
reload-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl daemon-reload
    sudo systemctl restart harbor-replication.timer

# Reload systemd and restart syncoid replication on ghost-vault
reload-syncoid:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo systemctl daemon-reload
    sudo systemctl restart syncoid-replication.timer
