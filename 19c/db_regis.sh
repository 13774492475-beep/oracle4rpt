#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_regis_${timestamp}.csv"
filename="db_regis.csv"

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

SELECT comp_id,comp_name, version,status,TO_CHAR(TO_DATE(modified, 'DD-MON-YYYY HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') AS modified FROM  dba_registry;

SPOOL OFF
EOF

