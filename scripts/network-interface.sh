#!/bin/bash

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
netIface=$(ip link | grep enp | awk -F ": " '{ print $2 }')

echo ''{ ifaceString = \"$netIface\"; ifaceList = [ $netIface ] }'' > "$current/../secrets/keys/netIface"
