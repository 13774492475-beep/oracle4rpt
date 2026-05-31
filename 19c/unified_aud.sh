#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="unified_aud_${timestamp}.csv"
filename="unified_aud.csv"

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
SELECT PARAMETER,VALUE FROM V\$OPTION WHERE PARAMETER = 'Unified Auditing';
SPOOL OFF
EOF

