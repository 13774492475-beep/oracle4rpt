#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="rman_${timestamp}.csv"
filename="rman.csv"

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

-- Set column widths for better formatting
COLUMN "Backup Status" FORMAT A30
COLUMN "Backup Type" FORMAT A15
COLUMN "Overall Start Time" FORMAT A20
COLUMN "Overall End Time" FORMAT A20
COLUMN "Elapsed Minutes" FORMAT 99999
COLUMN "Input MB/s" FORMAT A10
COLUMN "Output MB/s" FORMAT A10
COLUMN "File Backup Time (min)" FORMAT 99999
COLUMN "Start Time" FORMAT A20
COLUMN "End Time" FORMAT A20
COLUMN "Command" FORMAT A20
COLUMN "Input MB" FORMAT 99999.99
COLUMN "Output MB" FORMAT 99999.99
COLUMN "Object Type" FORMAT A20
COLUMN "Processed MB" FORMAT 99999.99
COLUMN "Device Type" FORMAT A15

SPOOL $filename

SELECT 
    '"' || s.status || '"' AS "Backup Status",
    b.INPUT_TYPE AS "Backup Type",
    TO_CHAR(b.START_TIME, 'yyyy-mm-dd hh24:mi:ss') AS "Overall Start Time",
    TO_CHAR(b.END_TIME, 'yyyy-mm-dd hh24:mi:ss') AS "Overall End Time",
    TRUNC(b.ELAPSED_SECONDS / 60, 0) AS "Elapsed Minutes",
    b.INPUT_BYTES_PER_SEC_DISPLAY AS "Input MB/s",
    b.OUTPUT_BYTES_PER_SEC_DISPLAY AS "Output MB/s",
    TRUNC((s.END_TIME - s.START_TIME) * 24 * 60, 0) AS "File Backup Time (min)",
    TO_CHAR(s.START_TIME, 'yyyy-mm-dd hh24:mi:ss') AS "Start Time",
    TO_CHAR(s.END_TIME, 'yyyy-mm-dd hh24:mi:ss') AS "End Time",
    s.OPERATION AS "Command",
    TRUNC(s.INPUT_BYTES / 1024 / 1024, 2) AS "Input MB",
    TRUNC(s.OUTPUT_BYTES / 1024 / 1024, 2) AS "Output MB",
    s.OBJECT_TYPE AS "Object Type",
    s.MBYTES_PROCESSED AS "Processed MB",
    s.OUTPUT_DEVICE_TYPE AS "Device Type"
FROM 
    v\$rman_status s, 
    v\$rman_backup_job_details b
WHERE 
    TO_CHAR(s.START_TIME, 'yyyy-mm-dd hh24:mi:ss') < TO_CHAR(SYSDATE, 'yyyy-mm-dd hh24:mi:ss')
    AND TO_CHAR(s.END_TIME, 'yyyy-mm-dd hh24:mi:ss') > TO_CHAR(SYSDATE - 7, 'yyyy-mm-dd hh24:mi:ss')
    AND s.COMMAND_ID = b.COMMAND_ID
ORDER BY 
    s.START_TIME DESC;

SPOOL OFF
EOF

