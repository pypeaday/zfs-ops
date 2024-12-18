# ZFS Ops

This repo is for housing ZFS related configuration - specifically sanoid configuration and syncoid scripts for my various machines

It is assumed to be a Debian/Ubuntu machine

# TODO

1. don't use `hosts` folder. Change that to a server directory with functional names like "AppSrvPrd" etc.
2. Aurora backup is broken because I can't install syncoid/sanoid on the host, and I can't see the zfs datasets in an ubuntu distrobox

## What This Does NOT Do

This ansible role does not setup any ZFS datasets - it just installs the zfs library and then sets up sanoid and syncoid using sanoid conf specific to each of my hosts. The ZFS dataset creation is left up to me to do manually right now - I'm not sure what a good pattern would be for any automatic dataset creation, but a #TODO for me is to document permissions for the user and datasets

## Running Things

To run things I'm using [just](https://github.com/casey/just)

`curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin`

## Setup

1. clone repo to $HOME (assumed for syncoid replication scripts and sanoid conf links)
2. run `just sanoid`

There is a folder for each of my machines right now with the sanoid/syncoid related configuration. The playbook takes 3 variables which I just handle at runtime in my `justfile`

`setup_sanoid`, `setup_syncoid`, and `install_zfs`

There's a caveat to the folder matching the `hostname` because that's assumed in the `syncoid-replication.service` file
