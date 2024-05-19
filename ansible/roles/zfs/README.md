# ZFS setup

This Ansible role sets up ZFS filesystem + a systemd service to make docker wait on ZFS to mount any datasets. This is for when docker uses datasets as bind mounts - need to make sure that any containers that start up wait for the dataset to be properly mounted