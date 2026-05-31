#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="crs_lms_${timestamp}.txt"
filename="crs_lms_${timestamp}.txt"

lms_count=$(ps -ef | grep -E 'asm_lms[0-9]|ora_lms[0-9]' | grep -v grep | wc -l)

echo "lms_cnt\$-\$${lms_count}" > "$filename"
