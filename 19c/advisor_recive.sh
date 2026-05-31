#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="advisor_recive_${timestamp}.csv"
filename="advisor_recive.csv"

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
    WINDOW_START_TIME AS Job_Start_Time,
    JOB_STATUS AS Job_Status,
    JOB_DURATION AS Job_Duration
FROM 
    DBA_AUTOTASK_JOB_HISTORY
WHERE 
    CLIENT_NAME = 'sql tuning advisor'
ORDER BY 
    WINDOW_START_TIME DESC;

SPOOL OFF
EOF
