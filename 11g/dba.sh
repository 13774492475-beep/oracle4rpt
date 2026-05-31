#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="dba_${timestamp}.csv"
filename="dba.csv"

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
    grantee AS "Username",
    'YES' AS "DBA"
FROM
    dba_role_privs
WHERE
    granted_role = 'DBA'  
    AND grantee NOT IN ('SYS', 'SYSDG', 'SYSKM', 'SYSBACKUP')  
ORDER BY
    grantee;  
	
SPOOL OFF
EOF
