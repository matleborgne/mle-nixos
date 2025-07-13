#!/bin/bash

#set -x

# TODO BEFORE EXECUTING FORK SCRIPT

# USECASE example : duplication of config for Librewolf along Firefox

# 1. Go to https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/PROGRAM_NAME.nix
# 2. Check if everything can be easily forked (like librewolf which just replace firefox by librewolf everywhere)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FUNCTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

github="https://github.com/NixOS/nixpkgs/raw/refs/heads/nixos-unstable"
current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


fork() {
  source=${1}
  target=${2}
  targetPath="${current}/../modules/forks/${target}.nix"

  wget "$github/$source" -O "$targetPath"
}
  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FORKING PROGRAMS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Librewolf
fork "nixos/modules/programs/firefox.nix" librewolf
sed -i "s/firefox/librewolf/g" "$current/../modules/forks/librewolf.nix"
sed -i "s/Firefox/Librewolf/g" "$current/../modules/forks/librewolf.nix"

sed '/config.programs.librewolf/a\ correctedVersion = builtins.elemAt (lib.strings.splitString "-" (config.programs.librewolf.package.version)) 0;' "$current/../modules/forks/librewolf.nix"
sed -i "s/cfg.package.version/correctedVersion/g" "$current/../modules/forks/librewolf.nix"

# Fluent-gtk-theme
fork "pkgs/by-name/fl/fluent-gtk-theme/package.nix" fluent-gtk-theme
sed -i "s/icon nixos/icon default/g" "$current/../modules/forks/fluent-gtk-theme.nix"
