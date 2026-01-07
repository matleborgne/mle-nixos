#!/bin/bash

# ~~~~~~~~~~ Nautilus ~~~~~~~~~~
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
gsettings set org.gnome.nautilus.preferences show-create-link true
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"

gsettings set org.gnome.nautilus.list-view default-zoom-level "small"

gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
