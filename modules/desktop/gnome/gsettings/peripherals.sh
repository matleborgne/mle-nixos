#!/bin/bash

# ~~~~~~~~~~ Souris et touchpad ~~~~~~~~~~
gsettings set org.gnome.desktop.peripherals.touchpad click-method "areas"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad speed .25

gsettings set org.gnome.desktop.peripherals.mouse speed .25

# ~~~~~~~~~~ Raccourcis clavier ~~~~~~~~~~
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Alt><Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Alt><Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
