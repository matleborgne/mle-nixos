#!/bin/bash

# ~~~~~~~~~~ Schemas DIR ~~~~~~~~~~
export GSETTINGS_SCHEMA_DIR=$(grep -r dash-to-panel ./.gschemas | tail -n 1)

# ~~~~~~~~~~ Dash to panel ~~~~~~~~~~
gsettings set org.gnome.shell.extensions.dash-to-panel dot-style-focused "DASHES"
gsettings set org.gnome.shell.extensions.dash-to-panel dot-style-unfocused "DOTS"
gsettings set org.gnome.shell.extensions.dash-to-panel dot-position "TOP"
gsettings set org.gnome.shell.extensions.dash-to-panel focus-highlight-opacity 15
gsettings set org.gnome.shell.extensions.dash-to-panel panel-sizes "{'0':40,'1':40}"
gsettings set org.gnome.shell.extensions.dash-to-panel panel-positions "{'0':'TOP','1':'TOP'}"
gsettings set org.gnome.shell.extensions.dash-to-panel stockgs-keep-dash true
gsettings set org.gnome.shell.extensions.dash-to-panel trans-panel-opacity 0.0
gsettings set org.gnome.shell.extensions.dash-to-panel trans-use-custom-opacity true
gsettings set org.gnome.shell.extensions.dash-to-panel animate-appicon-hover false
gsettings set org.gnome.shell.extensions.dash-to-panel appicon-padding 4
gsettings set org.gnome.shell.extensions.dash-to-panel appicon-margin 1
gsettings set org.gnome.shell.extensions.dash-to-panel show-favorites false
gsettings set org.gnome.shell.extensions.dash-to-panel show-activities-button false
gsettings set org.gnome.shell.extensions.dash-to-panel tray-size 20
gsettings set org.gnome.shell.extensions.dash-to-panel status-icon-padding 4

gsettings set org.gnome.shell.extensions.dash-to-panel panel-element-positions {\
  "0":[\
    {"element":"showAppsButton","visible":false,"position":"stackedTL"},\
    {"element":"activitiesButton","visible":true,"position":"stackedTL"},\
    {"element":"leftBox","visible":true,"position":"stackedTL"},\
    {"element":"taskbar","visible":true,"position":"stackedTL"},\
    {"element":"dateMenu","visible":true,"position":"centerMonitor"},\
    {"element":"centerBox","visible":true,"position":"stackedBR"},\
    {"element":"rightBox","visible":true,"position":"stackedBR"},\
    {"element":"systemMenu","visible":true,"position":"stackedBR"},\
    {"element":"desktopButton","visible":false,"position":"stackedBR"}
  ],\
  "1":[\
    {"element":"showAppsButton","visible":false,"position":"stackedTL"},\
    {"element":"activitiesButton","visible":true,"position":"stackedTL"},\
    {"element":"leftBox","visible":true,"position":"stackedTL"},\
    {"element":"taskbar","visible":true,"position":"stackedTL"},\
    {"element":"dateMenu","visible":true,"position":"centerMonitor"},
    {"element":"centerBox","visible":true,"position":"stackedBR"},\
    {"element":"rightBox","visible":true,"position":"stackedBR"},\
    {"element":"systemMenu","visible":true,"position":"stackedBR"},\
    {"element":"desktopButton","visible":false,"position":"stackedBR"}\
  ]\
}
