#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r just-perfection ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Just perfection ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.just-perfection dash-separator false
gsettings set org.gnome.shell.extensions.just-perfection search false
