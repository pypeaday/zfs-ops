default:
    @just --choose


# sanoid: desired_hostname="babyblue" install_zfs="false" setup_sanoid="false" setup_syncoid="false":
#     #!/usr/bin/env bash
#     set -euxo pipefail
# 
#     echo {{ setup_sanoid }} {{ setup_syncoid }}
#     hostname=$(hostname)
#     if [ "$hostname" != {{ desired_hostname }} ]; then
#         echo "Hostname does not match the desired value. Exiting."
#         exit 1
#     fi
#     ansible-playbook -bK ansible/playbook.yml \
#         --extra-vars "hostname=$hostname" \
#         --extra-vars "setup_syncoid={{ setup_syncoid }}" \
#         --extra-vars "setup_sanoid={{ setup_sanoid }}" \
#         --extra-vars "install_zfs={{ install_zfs }}"
# 
# setup-ghost-vault:
#     #!/usr/bin/env bash
#     set -euxo pipefail
# 
#     just setup ghost-vault false false true
# 
# setup-ghost:
#     #!/usr/bin/env bash
#     set -euxo pipefail
# 
#     just setup ghost
# 
# setup-babyblue:
#     #!/usr/bin/env bash
#     set -euxo pipefail
# 
#     just setup babyblue

setup-harbor:
    #!/usr/bin/env bash
    set -euxo pipefail

    sudo cp ./hosts/ghost/harbor-replication.service /etc/systemd/system/harbor-replication.service
    sudo cp ./hosts/ghost/harbor-replication.timer /etc/systemd/system/harbor-replication.timer

    sudo systemctl daemon-reload
    sudo systemctl enable harbor-replication.timer
    sudo systemctl start harbor-replication.timer
