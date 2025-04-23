#!/bin/bash

set -x

netIface = $(ip link | grep enp | awk -F ": " '{ print $2 }')
echo $netIface > ../secrets/keys/netIface
