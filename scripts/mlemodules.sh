#!/bin/bash

#set -x


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creation of importation list
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# mlemodules.nix
echo '[ '$(find "$current/../modules" -name '*.nix' | grep -v "/imports.nix" | sed -e "s|$current/||g")' ]' > "$current/../modules/imports.nix"

# secrets/mlesecrets.nix
echo '[ '$(find "$current/../secrets" -name '*.nix' | grep -v "/imports.nix" | sed -e "s|$current/||g")' ]' > "$current/../secrets/imports.nix"
