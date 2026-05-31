#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="timzone_version_${timestamp}.csv"
filename="timzone_version.csv"

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
    (SELECT banner FROM v\$version WHERE banner LIKE 'Oracle Database%' AND ROWNUM = 1) AS "Db_Version",
    (SELECT version FROM v\$timezone_file) AS "Dst_Version",
    (SELECT version FROM dba_registry WHERE comp_id = 'CATPROC') AS "Regist_Version"
FROM
    dual;

SPOOL OFF
EOF
