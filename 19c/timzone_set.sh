#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="timzone_set_${timestamp}.csv"
filename="timzone_set.csv"

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

SPOOL $filename
SELECT dbtimezone AS "Dbtimezone",'+08:00' AS "Expected Value" FROM v\$database;
SPOOL OFF
EOF
