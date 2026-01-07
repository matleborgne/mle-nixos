#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r text-editor ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Text Editor ~~~~~~~~~~
gsettings set org.gnome.TextEditor restore-session false
gsettings set org.gnome.TextEditor show-line-numbers true
gsettings set org.gnome.TextEditor discover-settings false
