#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="alert_info_${timestamp}.txt"
filename="alert_info.txt"

TRACE_PATH=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT value FROM v\$diag_info WHERE name='Diag Trace';
EOF
)

if [[ -z "$TRACE_PATH" ]]; then
    echo "无法获取 Oracle Background Dump 路径。" >&2
    exit 1
fi

> "$filename"

find "$TRACE_PATH" -name 'alert_*.log' | while read -r logfile; do
    echo "Processing $logfile..." >> "$filename"
    tail -n 50000 "$logfile" >> "$filename"
done
