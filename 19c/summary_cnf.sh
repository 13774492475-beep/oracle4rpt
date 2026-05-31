#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#output_file="summary_cnf_${timestamp}.txt"
output_file="summary_cnf.txt"

sqlplus -s "/ as sysdba" <<EOF > $output_file
SET COLSEP ','
SET LINESIZE 2000
SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING OFF
SET TRIMSPOOL ON
SET ECHO OFF

SELECT 'db_version\$-\$' || banner AS result
FROM v\$version
WHERE rownum < 2
UNION ALL
SELECT 'db_run_mode\$-\$' || open_mode AS result
FROM v\$database
UNION ALL
SELECT 'db_run_role\$-\$' || database_role AS result
FROM v\$database
UNION ALL
SELECT 'cnf_keptime\$-\$' || value AS result
FROM v\$parameter
WHERE name = 'control_file_record_keep_time'
UNION ALL
SELECT 'cnf_name\$-\$' || name AS result
FROM v\$controlfile
UNION ALL
SELECT 'fast_mttr\$-\$' || value AS result
FROM v\$parameter
WHERE name = 'fast_start_mttr_target'
UNION ALL
SELECT 'db_incarnation\$-\$' || incarnation# AS result
FROM v\$database_incarnation
WHERE status = 'CURRENT';

EXIT;
EOF


