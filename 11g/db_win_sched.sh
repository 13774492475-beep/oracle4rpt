#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_win_sched_${timestamp}.csv"
filename="db_win_sched.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 4096      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

COLUMN "Window Name" FORMAT A50  
COLUMN "Resource Plan" FORMAT A30  
COLUMN "Repeat Interval" FORMAT A80  
COLUMN "Enabled Status" FORMAT A15
COLUMN "Warning" FORMAT A50

SPOOL $filename
SELECT
    window_name AS "Window Name",       
    resource_plan AS "Resource Plan",   
    repeat_interval AS "Repeat Interval", 
    enabled AS "Enabled Status",        
    CASE
        WHEN enabled = 'FALSE' THEN 'WARNING: Window Disabled'
        ELSE 'No Warnings'
    END AS "Warning"                    
FROM
    dba_scheduler_windows
where window_name NOT IN ('WEEKNIGHT_WINDOW', 'WEEKEND_WINDOW')
ORDER BY
    window_name; 
	
SPOOL OFF
EOF
