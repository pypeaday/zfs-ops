default:
    @just --choose

setup-ghost-vault:
    #!/usr/bin/env bash
    set -euxo pipefail
    export SETUP_SANOID=false
    export SETUP_SYNCOID=true
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"-i "localhost"

setup-ghost:
    #!/usr/bin/env bash
    set -euxo pipefail
    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"-i "localhost"

setup-babyblue:
    #!/usr/bin/env bash
    set -euxo pipefail
    export SETUP_SANOID=false
    export SETUP_SYNCOID=false
    export INSTALL_ZFS=false
    export HOSTNAME=`hostname`
    ansible-playbook ansible/playbook.yml --extra-vars "hostname=$HOSTNAME" --extra-vars "setup_syncoid=$SETUP_SYNCOID" --extra-vars "setup_sanoid=$SETUP_SANOID" --extra-vars "install_zfs=$INSTALL_ZFS"-i "localhost"
