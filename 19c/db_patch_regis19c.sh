#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_patch_regis_${timestamp}.csv"
filename="db_patch_regis19c.csv"

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
    sp.ACTION_TIME AS "Action_Time",
    sp.ACTION AS "Action",
    sp.PATCH_UID AS "Namespace",      
    sp.TARGET_VERSION AS "Version",   
    sp.PATCH_ID AS "Id",
    sp.DESCRIPTION AS "Comments"
FROM
    DBA_REGISTRY_SQLPATCH sp
ORDER BY
    sp.PATCH_ID;

SPOOL OFF
EOF
