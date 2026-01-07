#!/bin/bash

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
