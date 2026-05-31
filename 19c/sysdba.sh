#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="sysdba_${timestamp}.csv"
filename="sysdba.csv"

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

SELECT
    username AS "Username",
    CASE 
        WHEN sysdba = 'TRUE' THEN 'YES'
        ELSE 'NO'
    END AS "Sysdba"
FROM
    v\$pwfile_users
WHERE
    sysdba = 'TRUE' 
    AND username NOT IN ('SYS', 'SYSDG', 'SYSKM', 'SYSBACKUP') 
ORDER BY
    username;
	
SPOOL OFF
EOF

