#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r pop-shell ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Pop shell ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.pop-shell tile-by-default true
gsettings set org.gnome.shell.extensions.pop-shell gap-inner 4
gsettings set org.gnome.shell.extensions.pop-shell gap-outer 4
