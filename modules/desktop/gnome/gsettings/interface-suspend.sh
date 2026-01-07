#!/bin/bash

# ~~~~~~~~~~ Désactivation de la mise en veille ~~~~~~~~~~
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.desktop.session idle-delay 0
