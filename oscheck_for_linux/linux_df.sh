#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_df_${timestamp}.csv"
filename="linux_df.csv"

df -h | awk '
BEGIN {
    OFS = ",";  # Output field separator for CSV
    print "Filesystem,Size,Used,Available,Use%,Mounted on"
}
NR>1 {
    # Output each field separated by commas
    print $1, $2, $3, $4, $5, $6
}
' > "$filename"

