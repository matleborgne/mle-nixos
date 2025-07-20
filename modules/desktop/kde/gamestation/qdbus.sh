#!/run/current-system/sw/bin/bash

# Autohide PANEL
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                      var panel = panels()[0];
                      panel.hiding = \"autohide\";
                      "

# Mode performance
# Authorize sudo access for this command
sudo powerprofilesctl set performance
