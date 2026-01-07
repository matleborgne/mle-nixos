#!/bin/bash

export GSETTINGS_SCHEMA_DIR=$(grep -r gnome-terminal ./.gschemas | tail -n 1)
gsettings set org.gnome.terminal.legacy theme-variant dark

export GSETTINGS_SCHEMA_DIR=$(grep -r ptyxis ./.gschemas | tail -n 1)
gsettings set org.gnome.Ptyxis interface-style dark
