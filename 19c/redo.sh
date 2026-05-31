#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="redo_info_${timestamp}.csv"
filename="redo_info.csv"

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
    l.THREAD# AS "Thread",
    l.GROUP# AS "Group",
    '''' || lf.MEMBER || '''' AS "Member",  
    l.STATUS AS "Status",
    l.SEQUENCE# AS "Sequence",
    ROUND(l.BYTES / (1024 * 1024)) AS "Mb",
    CASE
        WHEN db.database_role = 'PRIMARY' THEN 'Primary Redo'
        WHEN db.database_role = 'PHYSICAL STANDBY' THEN 'Standby Redo'
        ELSE 'Unknown'
    END AS "Logtype"
FROM
    v\$log l
JOIN
    v\$logfile lf ON l.GROUP# = lf.GROUP#
JOIN
    v\$database db ON 1 = 1
ORDER BY
    l.THREAD#, l.GROUP#, lf.MEMBER;
SPOOL OFF
EOF
