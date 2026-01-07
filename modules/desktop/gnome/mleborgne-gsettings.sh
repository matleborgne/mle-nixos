#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Paramètres généraux de GNOME
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~ Mode nuit - éclairage lumière bleue ~~~~~~~~~~
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 3.9999
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 4
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false


# ~~~~~~~~~~ Police et taille d'interface ~~~~~~~~~~
gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-name "Ubuntu Regular 11"
gsettings set org.gnome.desktop.interface document-font-name "Ubuntu Regular 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono Regular 12"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"

gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,close"
gsettings set org.gnome.desktop.wm.preferences theme "adw-gtk3"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Ubuntu Bold 11"
gsettings set org.gnome.desktop.wm.preferences focus-mode "click"


# ~~~~~~~~~~ Raccourcis clavier ~~~~~~~~~~
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Alt><Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Alt><Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"


