#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_mtu_lo_${timestamp}.txt"
filename="aix_mtu_lo.txt"

lo0_mtu=$(netstat -i | awk '/lo0/ {print $2; exit}')

{
    echo "lo_mtu_aix\$-\$${lo0_mtu}"
} > "$filename"
