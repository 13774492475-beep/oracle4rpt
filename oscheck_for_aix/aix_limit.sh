#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_limit_${timestamp}.txt"
filename="aix_limit.txt"

{
    echo "time(seconds)\$-\$$(ulimit -t)"
    echo "file(blocks)\$-\$$(ulimit -f)"
    echo "data(kbytes)\$-\$$(ulimit -d)"
    echo "stack(kbytes)\$-\$$(ulimit -s)"
    echo "memory(kbytes)\$-\$$(ulimit -m)"
    echo "coredump(blocks)\$-\$$(ulimit -c)"
    echo "nofiles(descriptors)\$-\$$(ulimit -n)"
    echo "threads(per process)\$-\$$(ulimit -u)"  
    echo "processes(per user)\$-\$$(ulimit -u)"
} > "$filename"
