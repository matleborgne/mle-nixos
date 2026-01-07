#!/bin/bash

# ~~~~~~~~~~ Désactivation de la mise en veille ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r settings-daemon ./.gschemas | tail -n 1)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.desktop.session idle-delay 0
