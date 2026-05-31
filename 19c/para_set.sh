#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="para_set_${timestamp}.csv"
filename="para_set.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 1800     
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

COLUMN Inst_Id FORMAT 99999
COLUMN Name FORMAT A40
COLUMN Value FORMAT A20

SPOOL $filename

WITH cpu_info AS (
    SELECT value AS cpu_count FROM gv\$parameter WHERE name = 'cpu_count'
)
SELECT
    inst_id AS "Inst_Id",
    a.name AS "Name",
    a.value AS "Value"
FROM
    gv\$system_parameter a
WHERE
    a.name IN (
        'control_file_record_keep_time',
        'parallel_max_servers',
        'recovery_parallelism',
        'result_cache_max_size',
        'standby_file_management'
    )
ORDER BY
    a.name;
	
SPOOL OFF
EOF

