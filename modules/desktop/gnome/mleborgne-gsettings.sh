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


# ~~~~~~~~~~ Session mutter ~~~~~~~~~~
gsettings set org.gnome.mutter check-alive-timeout 30000
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.mutter edge-tiling true
gsettings set org.gnome.mutter workspaces-only-on-primary true

gsettings set org.gnome.system.location enabled false

gsettings set org.gnome.desktop.background color-shading-type "solid"
gsettings set org.gnome.desktop.background picture-options "zoom"
gsettings set org.gnome.desktop.background picture-uri "file:////$HOME/.local/share/.wallpaper.jpg";
gsettings set org.gnome.desktop.background picture-uri-dark "file:////$HOME/.local/share/.wallpaper.jpg";

gsettings set org.gnome.terminal.legacy theme-variant dark
gsettings set org.gnome.Ptyxis interface-style dark


# ~~~~~~~~~~ Souris et touchpad ~~~~~~~~~~
gsettings set org.gnome.desktop.peripherals.touchpad click-method "areas"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad speed .25

gsettings set org.gnome.desktop.peripherals.mouse speed .25


# ~~~~~~~~~~ Désactivation de la mise en veille ~~~~~~~~~~
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.desktop.session idle-delay 0

