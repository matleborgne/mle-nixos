#!/bin/bash

distro = $(cat /etc/os-release | grep '^ID=' | awk -F '=' '{print $NF }')

if [ $distro == "nixos" ] ; then
  echo $(find -L "/run/current-system/sw/share/gsettings-schemas/" -type d -name "schemas") > ./.gschemas
  echo $(find -L "/run/current-system/sw/share/gnome-shell/extensions/" -type d -name "schemas") >> ./.gschemas
  echo $(find -L "$HOME/.local/share/gnome-shell/" -type d -name "schemas") >> ./.gschemas
  sed -i "s/ /\n/g" .gschemas
else
  ls -d /usr/share/glib-2.0/schemas/* > ./.gschemas
elif
