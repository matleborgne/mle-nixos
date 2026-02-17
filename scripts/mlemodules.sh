#!/usr/bin/env bash

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
host=$(cat /etc/hostname)

# nix formatting
prefix="
{ config, pkgs, pkgsUnstable, lib, ... }:

{
  imports =
    [
"

suffix="
    ];
 
}
"

# mlemodules.nix
#echo "$prefix" $(find "$current/../modules" -name '*.nix' \
#          | grep -v "/imports.nix" \
#          | sed -e "s|$current/||g") "$suffix" \
#          > "$current/../modules/imports.nix"

{
  printf "%s\n" "$prefix"

  find "$current/../modules" -name '*.nix' \
    | grep -v "/imports.nix" \
    | sed -e "s|$current/||g" \
    | sed 's/^/      /'

  printf "%s\n" "$suffix"
} > "$current/../modules/imports.nix"


# secrets/mlesecrets.nix but hardware conf
echo "$prefix" $(find "$current/../secrets" -name '*.nix' \
          | grep -v "/imports.nix" \
          | grep -v "/hardware-configuration*" \
          | sed -e "s|$current/||g") ' \
          > "$current/../secrets/imports.nix"

# specific import for secrets/hardware-configuration
echo $(find "$current/../secrets" -name "*hardware-configuration-$host.nix" \
          | sed -e "s|$current/||g")' "$suffix" \
          >> "$current/../secrets/imports.nix"

# correction import.nix
echo $(sed -z 's/\n//g' "$current/../secrets/imports.nix") > "$current/../secrets/imports.nix"
