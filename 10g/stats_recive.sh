#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="stats_recive_${timestamp}.csv"
filename="stats_recive.csv"

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

-- Define columns with appropriate formats
COL Job_Name FORMAT A30
COL Session_ID FORMAT 9999999999
COL Job_Status FORMAT A20
COL Log_Date FORMAT A19
COL Additional_Info FORMAT A20

SPOOL $filename
SELECT 
    JOB_NAME AS Job_Name,
    SESSION_ID AS Session_ID,
    STATUS AS Job_Status,
    TO_CHAR(LOG_DATE, 'YYYY-MM-DD HH24:MI:SS') AS Log_Date,
    ADDITIONAL_INFO
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    JOB_NAME = 'GATHER_STATS_JOB'
ORDER BY 
    LOG_DATE DESC;

SPOOL OFF
EOF

