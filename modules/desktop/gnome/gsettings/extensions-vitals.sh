#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r itals ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Vitals ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.vitals update-time 3
gsettings set org.gnome.shell.extensions.vitals hide-icons true
gsettings set org.gnome.shell.extensions.vitals fixed-widths true
gsettings set org.gnome.shell.extensions.vitals show-system false
gsettings set org.gnome.shell.extensions.vitals show-fan false
gsettings set org.gnome.shell.extensions.vitals show-voltage false
gsettings set org.gnome.shell.extensions.vitals show-network false
gsettings set org.gnome.shell.extensions.vitals show-storage false
gsettings set org.gnome.shell.extensions.vitals show-battery true
gsettings set org.gnome.shell.extensions.vitals battery-slot 1
