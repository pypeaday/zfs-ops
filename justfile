default:
    @just --choose

setup-ghost-vault:
    #!/usr/bin/env bash
    set -euxo pipefail
    hostname=$(hostname)
    desired_hostname="ghost-vault"

    if [ "$hostname" != "$desired_hostname" ]; then
        echo "Hostname does not match the desired value. Exiting."
        exit 1
    fi
    export SETUP_SANOID=false
    export SETUP_SYNCOID=true
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook -bK ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"

setup-ghost:
    #!/usr/bin/env bash
    set -euxo pipefail
    hostname=$(hostname)
    desired_hostname="ghost"

    if [ "$hostname" != "$desired_hostname" ]; then
        echo "Hostname does not match the desired value. Exiting."
        exit 1
    fi
    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook -bK ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"

setup-babyblue:
    #!/usr/bin/env bash
    set -euxo pipefail
    hostname=$(hostname)
    desired_hostname="babyblue"

    if [ "$hostname" != "$desired_hostname" ]; then
        echo "Hostname does not match the desired value. Exiting."
        exit 1
    fi
    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook -bK ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"
