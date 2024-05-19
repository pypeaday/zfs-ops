default:
    @just --choose

setup desired_hostname="babyblue" install_zfs="false" setup_sanoid="false" setup_syncoid="false":
    #!/usr/bin/env bash
    set -euxo pipefail
    echo $SETUP_SANOID $SETUP_SYNCOID
    hostname=$(hostname)
    if [ "$hostname" != {{ desired_hostname }} ]; then
        echo "Hostname does not match the desired value. Exiting."
        exit 1
    fi
    ansible-playbook -bK ansible/playbook.yml \
        --extra-vars "hostname=$hostname" \
        --extra-vars "setup_syncoid=$SETUP_SYNCOID" \
        --extra-vars "setup_sanoid=$SETUP_SANOID" \
        --extra-vars "install_zfs=$INSTALL_ZFS"

setup-ghost-vault:
    #!/usr/bin/env bash
    set -euxo pipefail

    just setup ghost-vault false false true

setup-ghost:
    #!/usr/bin/env bash
    set -euxo pipefail

    just setup ghost

setup-babyblue:
    #!/usr/bin/env bash
    set -euxo pipefail

    just setup babyblue