#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_limit_grid_${timestamp}.txt"
filename="linux_limit_grid.txt"

nproc_hard=$(grep -E "^grid\s+hard\s+nproc" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nofile_hard=$(grep -E "^grid\s+hard\s+nofile" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
stack_hard=$(grep -E "^grid\s+hard\s+stack" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
memlock_hard=$(grep -E "^grid\s+hard\s+memlock" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nproc_soft=$(grep -E "^grid\s+soft\s+nproc" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nofile_soft=$(grep -E "^grid\s+soft\s+nofile" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
stack_soft=$(grep -E "^grid\s+soft\s+stack" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
memlock_soft=$(grep -E "^grid\s+soft\s+memlock" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')

{
    echo "nproc_hard_grid\$-\$${nproc_hard}"
    echo "nofile_hard_grid\$-\$${nofile_hard}"
    echo "stack_hard_grid\$-\$${stack_hard}"
    echo "memlock_hard_grid\$-\$${memlock_hard}"
    echo "nproc_soft_grid\$-\$${nproc_soft}"
    echo "nofile_soft_grid\$-\$${nofile_soft}"
    echo "stack_soft_grid\$-\$${stack_soft}"
    echo "memlock_soft_grid\$-\$${memlock_soft}"
} > "$filename"
