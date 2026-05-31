#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_df_${timestamp}.csv"
filename="aix_df.csv"

df -Pm | sed -n '1!p' | awk '
BEGIN {
    OFS = ",";  
    print "Filesystem,Total Size,Used,Available,Use%,Mounted on"
}
{
    print $1, $2, $3, $4, $5, $6
}
' > "$filename"
