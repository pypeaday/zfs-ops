# Sanoid and Syncoid

This Ansible role sets up sanoid and syncoid and systemd configuration. It's specific to me right now - ie. some paths are hardcoded.

I have directories for each host with a `syncoid-replication.sh` script that's unique to each one, the ansible role templates out the syncoid service so the path to the script is correct for each machine.

## For others

Others could probably use this by editing the templates - specifically the ExecStart in syncoid-replication.service.j2, and then it should probably be fine?