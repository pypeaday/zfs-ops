default:
    @just --choose

setup desired_hostname="babyblue":
    #!/usr/bin/env bash
    set -euxo pipefail
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

    export SETUP_SANOID=false
    export SETUP_SYNCOID=true
    export INSTALL_ZFS=false

    just setup ghost-vault

setup-ghost:
    #!/usr/bin/env bash
    set -euxo pipefail

    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false

    just setup ghost

setup-babyblue:
    #!/usr/bin/env bash
    set -euxo pipefail

    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false

    just setup babyblue