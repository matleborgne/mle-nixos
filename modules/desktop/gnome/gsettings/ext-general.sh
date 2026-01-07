#!/bin/bash

# ~~~~~~~~~~ Activation of extensions ~~~~~~~~~~
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.shell disabled-extensions "disabled"
gsettings set org.gnome.shell enabled-extensions "['pop-shell@system76.com', 'appindicatorsupport@rgcjonas.gmail.com', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'Vitals@CoreCoding.com', 'dash-to-panel@jderose9.github.com', 'just-perfection-desktop@just-perfection', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'rounded-window-corners@fxgn']"
