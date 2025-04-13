#!/bin/bash

PATH=$PATH:/run/current-system/sw/bin
#set -x

# TODO BEFORE EXECUTING FORK SCRIPT

# USECASE example : duplication of config for Librewolf along Firefox

# 1. Go to https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/PROGRAM_NAME.nix
# 2. Check if everything can be easily forked (like librewolf which just replace firefox by librewolf everywhere)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creation of importation list
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# mlemodules.nix
echo '[ '$(find "$current/../modules" -name '*.nix' | grep -v "/imports.nix" | sed -e "s|$current/||g")' ]' > "$current/../modules/imports.nix"

# secrets/mlesecrets.nix
echo '[ '$(find "$current/../secrets" -name '*.nix' | grep -v "/imports.nix" | sed -e "s|$current/||g")' ]' > "$current/../secrets/imports.nix"
