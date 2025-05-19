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
  targetPath="$current/../pkgs/$target.nix"

  wget "$github/$source.nix" -O "$targetPath"
}


replace() {
  source=${1}
  target=${2}
  targetPath="$current/../pkgs/$target.nix"

  sed -i "s/$source/$target/g" "$targetPath"
  
  source="$(tr '[:lower:]' '[:upper:]' <<< ${source:0:1})${source:1}"
  target="$(tr '[:lower:]' '[:upper:]' <<< ${target:0:1})${target:1}"
  sed -i "s/$source/$target/g" "$targetPath"
}
  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FORKING PROGRAMS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Librewolf
fork firefox librewolf
replace firefox librewolf

# Fluent-gtk-theme
fork fluent-gtk-theme
