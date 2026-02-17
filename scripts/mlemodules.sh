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

# NIX Syntax
prefix="{ config, pkgs, pkgsUnstable, lib, ... }:

{
  imports = ["

suffix="  ];
}"

# NIX modules
{
  printf "%s\n" "$prefix"

  find "$current/../modules" -name '*.nix' \
    | grep -v "/default.nix" \
    | sed -e "s|$current/||g" \
    | sort \
    | sed 's/^/      /'

  printf "%s\n" "$suffix"
} > "$current/../modules/default.nix"


# NIX secrets except for hardware-conf
{
  printf "%s\n" "$prefix"

  find "$current/../secrets" -name '*.nix' \
    | grep -v "/default.nix" \
    | grep -v "/hardware-configuration*" \
    | sed -e "s|$current/||g" \
    | sort \
    | sed 's/^/      /'

} > "$current/../secrets/default.nix"

# NIX hardware-conf
{
  find "$current/../secrets" -name "*hardware-configuration-$host.nix" \
    | sed -e "s|$current/||g" \
    | sort \
    | sed 's/^/      /'

  printf "%s\n" "$suffix"
} >> "$current/../secrets/default.nix"
