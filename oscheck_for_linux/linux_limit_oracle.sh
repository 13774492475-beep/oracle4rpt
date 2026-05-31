#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_limit_oracle_${timestamp}.txt"
filename="linux_limit_oracle.txt"

nproc_hard=$(grep -E "^oracle\s+hard\s+nproc" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nofile_hard=$(grep -E "^oracle\s+hard\s+nofile" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
stack_hard=$(grep -E "^oracle\s+hard\s+stack" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
memlock_hard=$(grep -E "^oracle\s+hard\s+memlock" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nproc_soft=$(grep -E "^oracle\s+soft\s+nproc" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
nofile_soft=$(grep -E "^oracle\s+soft\s+nofile" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
stack_soft=$(grep -E "^oracle\s+soft\s+stack" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')
memlock_soft=$(grep -E "^oracle\s+soft\s+memlock" /etc/security/limits.conf | grep -v '^#' | awk '{print $4}')

{
    echo "nproc_hard_oracle\$-\$${nproc_hard}"
    echo "nofile_hard_oracle\$-\$${nofile_hard}"
    echo "stack_hard_oracle\$-\$${stack_hard}"
    echo "memlock_hard_oracle\$-\$${memlock_hard}"
    echo "nproc_soft_oracle\$-\$${nproc_soft}"
    echo "nofile_soft_oracle\$-\$${nofile_soft}"
    echo "stack_soft_oracle\$-\$${stack_soft}"
    echo "memlock_soft_oracle\$-\$${memlock_soft}"
} > "$filename"
