#!/bin/bash

#set -x

# TODO BEFORE EXECUTING FORK SCRIPT

# USECASE example : duplication of config for Librewolf along Firefox

# 1. Go to https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/PROGRAM_NAME.nix
# 2. Check if everything can be easily forked (like librewolf which just replace firefox by librewolf everywhere)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FUNCTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

github="https://github.com/NixOS/nixpkgs/raw/refs/heads/nixos-unstable/nixos/modules/programs"
current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


fork() {
  source=${1}
  if [ -z ${2} ]; then target=${1}; else target=${2}; fi 
  targetPath="${current}/../pkgs/${target}.nix"

  wget "$github/$source.nix" -O "$targetPath"
}
  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FORKING PROGRAMS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Librewolf
fork firefox librewolf
sed -i "s/firefox/librewolf/g" "$current/../pkgs/librewolf.nix"
sed -i "s/Firefox/Librewolf/g" "$current/../pkgs/librewolf.nix"

# Fluent-gtk-theme
fork fluent-gtk-theme
sed -i "s/icon nixos/icon default/g" "$current/../pkgs/fluent-gtk-theme.nix"
