#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r settings-daemon ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Mode nuit - éclairage lumière bleue ~~~~~~~~~~
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 3.9999
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 4
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
