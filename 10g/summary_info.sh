#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#output_file="summary_info_${timestamp}.txt"
output_file="summary_info.txt"

sqlplus -s "/ as sysdba" <<EOF > $output_file
SET COLSEP ','
SET LINESIZE 2000
SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING OFF
SET TRIMSPOOL ON
SET ECHO OFF

SELECT 'db_name\$-\$' || name AS result FROM v\$database
UNION ALL
SELECT 'db_uname\$-\$' || db_unique_name AS result FROM v\$database
UNION ALL
SELECT 'os_info\$-\$' || PLATFORM_NAME AS result FROM v\$database
UNION ALL
SELECT 'force_log\$-\$' || force_logging AS result FROM v\$database
UNION ALL
SELECT 'sup_log\$-\$' || SUPPLEMENTAL_LOG_DATA_MIN AS result FROM v\$database
UNION ALL
SELECT 'flash_on\$-\$' || flashback_on AS result FROM v\$database
UNION ALL
SELECT 'arch_on\$-\$' || log_mode AS result FROM v\$database
UNION ALL
SELECT 'ist_name\$-\$' || instance_name AS result FROM v\$instance
UNION ALL
SELECT 'db_stime\$-\$' || TO_CHAR(startup_time, 'YYYY-MM-DD HH24:MI:SS') AS result FROM v\$instance
UNION ALL
SELECT 'cpu_cnt\$-\$' || CPU_COUNT_CURRENT AS result FROM v\$license
UNION ALL
SELECT 'phy_mem\$-\$' || ROUND(value / 1024 / 1024, 2) AS result FROM v\$osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES'
UNION ALL
SELECT 'nls_ter\$-\$' || value AS result FROM v\$parameter WHERE name = 'nls_territory'
UNION ALL
SELECT 'nls_lan\$-\$' || value AS result FROM v\$parameter WHERE name = 'nls_language'
UNION ALL
SELECT 'db_blks\$-\$' || value AS result FROM v\$parameter WHERE name = 'db_block_size'
UNION ALL
SELECT 'use_spf\$-\$' || value AS result FROM v\$parameter WHERE name = 'spfile'
UNION ALL
SELECT 'dbf_pct\$-\$' || ROUND((df.count_files / TO_NUMBER(p.value)) * 100, 2) || '%' AS result
FROM 
    (SELECT COUNT(*) AS count_files FROM dba_data_files) df,
    (SELECT value FROM v\$parameter WHERE name = 'db_files') p
UNION ALL
SELECT 'nls_chr\$-\$' || VALUE AS result FROM V\$NLS_PARAMETERS WHERE PARAMETER = 'NLS_CHARACTERSET'
UNION ALL
SELECT 'nls_nchr\$-\$' || VALUE AS result FROM V\$NLS_PARAMETERS WHERE PARAMETER = 'NLS_NCHAR_CHARACTERSET'
UNION ALL
SELECT 'per_tbs_cnt\$-\$' || COUNT(*) AS result FROM dba_tablespaces WHERE contents = 'PERMANENT'
UNION ALL
SELECT 'undo_tbs_cnt\$-\$' || COUNT(*) AS result FROM dba_tablespaces WHERE contents = 'UNDO'
UNION ALL
SELECT 'tmp_tbs_cnt\$-\$' || COUNT(*) AS result FROM dba_tablespaces WHERE contents = 'TEMPORARY'
UNION ALL
SELECT 'dbf_cnt\$-\$' || COUNT(*) AS result FROM v\$datafile
UNION ALL
SELECT 'tmp_cnt\$-\$' || COUNT(*) AS result FROM v\$tempfile
UNION ALL
SELECT 'cnf_cnt\$-\$' || COUNT(*) AS result FROM v\$controlfile
UNION ALL
SELECT 'redo_cnt\$-\$' || COUNT(*) AS result FROM v\$log
UNION ALL
SELECT 'max_redo_size\$-\$' || MAX(bytes) / 1024 / 1024 AS result FROM v\$log
UNION ALL
SELECT 'min_redo_size\$-\$' || MIN(bytes) / 1024 / 1024 AS result FROM v\$log
UNION ALL
SELECT 'redo_same_size\$-\$' || bytes || ' bytes with count: ' || COUNT(*) AS result
FROM v\$log
GROUP BY bytes
HAVING COUNT(*) > 1
UNION ALL
SELECT 'stby_cnt\$-\$' || COUNT(*) AS result FROM v\$standby_log
UNION ALL
SELECT 'per_redo_mem\$-\$group#:' || group# || ', member_count:' || COUNT(member) AS result
FROM v\$logfile
GROUP BY group#
UNION ALL
SELECT 'redo_mutil\$-\$group#:' || group# || ', num_locations:' || COUNT(*) AS result
FROM v\$logfile
GROUP BY group#
HAVING COUNT(*) > 1
UNION ALL
SELECT 'cuser_cnt\$-\$' || COUNT(*) AS result FROM dba_users
UNION ALL
SELECT 'auser_cnt\$-\$' || COUNT(*) AS result FROM dba_users WHERE account_status = 'OPEN'
UNION ALL
SELECT 'tmp_size\$-\$' || ROUND(SUM(bytes) / 1024 / 1024, 2) || ' MB' AS result FROM dba_temp_files
UNION ALL
SELECT 'dbf_size\$-\$' || ROUND(SUM(bytes) / 1024 / 1024, 2) AS result FROM dba_data_files
UNION ALL
SELECT 'undo_size\$-\$tablespace:' || dt.tablespace_name || ', size:' || ROUND(SUM(df.bytes) / 1024 / 1024, 2) || ' MB' AS result
FROM dba_tablespaces dt
JOIN dba_data_files df ON dt.tablespace_name = df.tablespace_name
WHERE dt.contents = 'UNDO'
GROUP BY dt.tablespace_name
UNION ALL
SELECT 'seg_size\$-\$' || ROUND(SUM(bytes) / 1024 / 1024, 2) AS result FROM dba_segments
UNION ALL
SELECT 'max_obj_id\$-\$' || MAX(object_id) AS result FROM dba_objects
UNION ALL
SELECT 'sga_graual\$-\$component:' || COMPONENT || ', granule_size_mb:' || ROUND(GRANULE_SIZE / 1024 / 1024, 2) || ' MB' AS result
FROM v\$sga_dynamic_components
UNION ALL
SELECT 'parallel_max_servers\$-\$' || value AS result FROM v\$system_parameter WHERE name = 'parallel_max_servers'
UNION ALL
SELECT 'standby_file_management\$-\$' || value AS result FROM v\$system_parameter WHERE name = 'standby_file_management'
UNION ALL
SELECT 'spf_parallel_max_servers\$-\$' || value AS result FROM v\$spparameter WHERE name = 'parallel_max_servers'
UNION ALL
SELECT 'spf_standby_file_management\$-\$' || value AS result FROM v\$spparameter WHERE name = 'standby_file_management';

EXIT;
EOF

