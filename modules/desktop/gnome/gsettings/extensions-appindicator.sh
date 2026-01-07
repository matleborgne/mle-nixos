#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r appindicator ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Appindicator ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.appindicator tray-pos "center"
gsettings set org.gnome.shell.extensions.appindicator icon-brightness -0.3
