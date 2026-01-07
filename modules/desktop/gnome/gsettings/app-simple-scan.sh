#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r simple-scan ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Scanner ~~~~~~~~~~
gsettings set org.gnome.simple-scan jpeg-quality 23
gsettings set org.gnome.SimpleScan jpeg-quality 23
