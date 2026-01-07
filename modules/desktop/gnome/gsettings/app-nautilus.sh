#!/bin/bash

# ~~~~~~~~~~ Nautilus ~~~~~~~~~~
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
gsettings set org.gnome.nautilus.preferences show-create-link true
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"

gsettings set org.gnome.nautilus.list-view default-zoom-level "small"

gsettings set org.gtk.settings.file-chooser show-hidden true
gsettings set org.gtk.settings.file-chooser sort-directories-first true
