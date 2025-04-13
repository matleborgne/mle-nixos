#!/bin/bash

#PATH=$PATH:/run/current-system/sw/bin
#set -x

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Autosync last github modifications to modules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $current

cd "$current"/../../github
/run/current-system/sw/bin/git pull origin main

/run/current-system/sw/bin/rsync -avzhx --delete ./modules/ ../build/modules/
/run/current-system/sw/bin/rsync -avzhx --delete ./roles/ ../build/roles/
/run/current-system/sw/bin/rsync -avzhx --delete ./scripts/ ../build/scripts/

/run/current-system/sw/bin/rsync -avzhx ./base.nix ../build/base.nix
/run/current-system/sw/bin/rsync -avzhx ./flake.nix ../build/flake.nix

cd "$current"/../../build
