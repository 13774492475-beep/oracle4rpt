#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="tbs_fre_pct_${timestamp}.csv"
filename="tbs_fre_pct.csv"

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

SELECT a.tablespace_name AS "TABLESPACE_NAME",
       sqrt(max(a.blocks) / sum(a.blocks)) * (100 / sqrt(sqrt(count(a.blocks)))) AS "FSFI"
  FROM dba_free_space a, dba_tablespaces b
 WHERE a.tablespace_name = b.tablespace_name
   AND b.contents NOT IN ('TEMPORARY', 'UNDO','SYSAUX','SYSTEM') and a.tablespace_name NOT IN ('SYSAUX','SYSTEM')
 GROUP BY a.tablespace_name
 ORDER BY FSFI;

SPOOL OFF
EOF

