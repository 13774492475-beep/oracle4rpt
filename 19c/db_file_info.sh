#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_file_info_${timestamp}.csv"
filename="db_file_info.csv"

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
    'DATAFILE' AS "Type",
    df.tablespace_name AS "Tablespace_Name",
    '''' || df.file_name || '''' AS "File_Name",
    ROUND(df.bytes / (1024 * 1024)) AS "Size_Mb",
    ROUND(df.maxbytes / (1024 * 1024)) AS "Max_Size_Mb",
    df.autoextensible AS "Autoextensible",
    df.status AS "Status"
FROM
    dba_data_files df
UNION ALL
SELECT
    'TEMPFILE' AS "Type",
    tf.tablespace_name AS "Tablespace_Name",
    '''' || tf.file_name || '''' AS "File_Name",
    ROUND(tf.bytes / (1024 * 1024)) AS "Size_Mb",
    ROUND(tf.maxbytes / (1024 * 1024)) AS "Max_Size_Mb",
    tf.autoextensible AS "Autoextensible",
    'N/A' AS "Status" -- Status is typically not used for temp files
FROM
    dba_temp_files tf
ORDER BY
    "Type", "Tablespace_Name", "File_Name";
SPOOL OFF
EOF
