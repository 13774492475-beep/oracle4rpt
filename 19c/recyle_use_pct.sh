#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
filename="recyle_use_pct.csv"

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
    ts.tablespace_name AS Tbs_Name,
    COUNT(rb.object_name) AS Cnt
FROM
    dba_recyclebin rb
JOIN
    dba_tablespaces ts ON rb.ts_name = ts.tablespace_name
GROUP BY
    ts.tablespace_name
ORDER BY
    ts.tablespace_name;
	
SPOOL OFF
EOF
