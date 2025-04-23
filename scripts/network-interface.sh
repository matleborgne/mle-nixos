#!/bin/bash

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
netIface=$(ip link | grep enp | awk -F ": " '{ print $2 }')

cat <<- EOF > "$current/../secrets/keys/netIface"
{ ifaceString = \"$netIface\"; ifaceList = [ $netIface ] }
EOF
