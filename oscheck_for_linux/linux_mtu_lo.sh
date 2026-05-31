#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_mtu_lo_${timestamp}.txt"
filename="linux_mtu_lo.txt"

lo_mtu=$(ip link show lo | grep -oP 'mtu \K\d+')

{
    echo "lo_mtu\$-\$${lo_mtu}"
} > "$filename"
