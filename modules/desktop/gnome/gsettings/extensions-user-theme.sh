#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r user-theme ./.gschemas | tail -n 1)

# ~~~~~~~~~~ User theme ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.user-theme name "Fluent-round-Dark"
