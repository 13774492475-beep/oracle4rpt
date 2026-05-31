#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="cnf_info_${timestamp}.csv"
filename="cnf_info.csv"

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

col IS_RECOVERY_DEST_FILE for a60
SPOOL $filename
SELECT
    '''' || cf.name || '''' AS "File_Name",
    cf.status AS "Status",
    cf.block_size AS "Block_Size",
    cf.file_size_blks AS "File_Size_Blocks",
    cf.file_size_blks * cf.block_size / (1024 * 1024) AS "Size_MB"
FROM
    v\$controlfile cf;
SPOOL OFF
EOF

