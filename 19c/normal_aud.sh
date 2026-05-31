#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="normal_aud_${timestamp}.csv"
filename="normal_aud.csv"

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

COLUMN name FORMAT A30
COLUMN value FORMAT A300

SPOOL $filename
SELECT name, 
       '"' || REPLACE(REPLACE(value, '"', '""'), CHR(10), ' ') || '"' AS value 
FROM v\$system_parameter 
WHERE name IN ('audit_file_dest', 'audit_sys_operations', 'audit_trail');
SPOOL OFF
EOF

