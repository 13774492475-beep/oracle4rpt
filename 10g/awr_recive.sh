#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="awr_recive_${timestamp}.csv"
filename="awr_recive.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 500      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

SPOOL $filename
SELECT
    SNAP_INTERVAL,
    RETENTION
FROM
    DBA_HIST_WR_CONTROL;

SPOOL OFF
EOF
