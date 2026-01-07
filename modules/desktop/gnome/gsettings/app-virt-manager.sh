#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r virt-manager ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Virt-manager ~~~~~~~~~~
gsettings set org.virt-manager.virt-manager enable-libguestfs-vm-inspection true
gsettings set org.virt-manager.virt-manager.console resize-guest 1
gsettings set org.virt-manager.virt-manager.details show-toolbar false
gsettings set org.virt-manager.virt-manager.paths image-default /var/machines
