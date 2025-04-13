#!/bin/bash

PATH=$PATH:/run/current-system/sw/bin
#set -x

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Autosync last github modifications to modules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $current

cd "$current"/../../github
git pull origin main

rsync -avzhx --delete ./modules/ ../build/modules/
rsync -avzhx --delete ./roles/ ../build/roles/
rsync -avzhx --delete ./scripts/ ../build/scripts/

rsync -avzhx ./base.nix ../build/base.nix
rsync -avzhx ./flake.nix ../build/flake.nix

cd "$current"/../../build
