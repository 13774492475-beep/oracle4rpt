#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_patch_regis11g_${timestamp}.csv"
filename="db_patch_regis11g.csv"

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

SELECT
    ACTION_TIME AS "Action_Time",
    ACTION AS "Action",
    ID AS "Id",
    NAMESPACE AS "Namespace",
    VERSION AS "Version",
    COMMENTS AS "Comments"
FROM
    DBA_REGISTRY_HISTORY
ORDER BY
    ID;

SPOOL OFF
EOF

