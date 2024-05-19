# ZFS Ops

This repo is for housing ZFS related configuration - specifically sanoid configuration and syncoid scripts for my various machines

## What This Does NOT Do

This ansible role does not setup any ZFS datasets - it just installs the zfs library and then sets up sanoid and syncoid using sanoid conf specific to each of my hosts. The ZFS dataset creation is left up to me to do manually right now - I'm not sure what a good pattern would be for any automatic dataset creation, but a #TODO for me is to document permissions for the user and datasets

## Hosts

There is a folder per host right now with appropriate files inside. Someday I'd like to standardize on a pattern like `app-prd01` or something, but for now homelab names are where it's at

## Sanoid

TODO: Need to fork sanoid and/or come up with ansible playbook for setting up sanoid with my appropriate file which _is done_ (will be done) by hostname
