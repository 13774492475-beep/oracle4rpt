#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="invi_par_idx1_${timestamp}.csv"
filename="invi_par_idx1.csv"

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
    p.index_owner AS "Owner",
    p.index_name AS "Index Name",
    i.index_type AS "Index Type",
    i.table_name AS "Table Name",  -- 添加表名信息
    p.partition_name AS "Unusable Partition Name",
    MIN(TO_CHAR(o.created, 'YYYY-MM-DD HH24:MI:SS')) AS "Created Time",
    MAX(TO_CHAR(o.last_ddl_time, 'YYYY-MM-DD HH24:MI:SS')) AS "Last Invalidation Time",
    'UNUSABLE' AS "Partition Index Status"
FROM
    dba_ind_partitions p
JOIN
    dba_indexes i ON p.index_name = i.index_name AND p.index_owner = i.owner
JOIN
    dba_objects o ON i.owner = o.owner AND i.index_name = o.object_name
WHERE
    p.status = 'UNUSABLE'
    AND p.index_owner NOT IN (
        'CTXSYS', 'SCOTT', 'OUTLN', 'DBSNMP', 'ORDSYS', 'ORDPLUGINS',
        'SI_INFORMTN_SCHEMA', 'MDSYS', 'PERFSTAT', 'MGMT_VIEW', 'MDDATA',
        'OLAPSYS', 'ANONYMOUS', 'ORACLE_OCM', 'TSMSYS', 'DIP', 'WMSYS',
        'EXFSYS', 'DMSYS', 'XDB', 'SYSMAN', 'SYS', 'SYSTEM', 'ORDDATA',
        'APEX_030200', 'FLOWS_FILES', 'GSMADMIN_INTERNAL', 'AUDSYS', 'DVSYS',
        'OJVMSYS', 'LBACSYS', 'WKSYS', 'CPR', 'ODM', 'OE', 'QS_CBADM',
        'QS', 'TRACESVR', 'AURORA$JIS$UTILITY$', 'OSE$HTTP$ADMIN', 'WKUSER',
        'WK_TEST', 'REPADMIN', 'DVF', 'ODM_MTR', 'QS_ES', 'QS_WS', 'QS_OS',
        'QS_CB', 'QS_CS', 'QS_ADM', 'APEX_PUBLIC_USER', 'APPQOSSYS',
        'AURORA$ORB$UNAUTHENTICATED', 'BI', 'FLOWS_040100', 'HR', 'IX',
        'OAS_PUBLIC', 'OWBSYS_AUDIT', 'PM', 'RMAN', 'SH',
        'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR', 'WEBSYS', 'WKPROXY',
        'XS$NULL', 'SYS$UMF', 'DBSFWUSER', 'GGSYS', 'GSMCATUSER', 'C##YUNQU',
        'REMOTE_SCHEDULER_AGENT', 'SYSBACKUP', 'GSMUSER', 'C##CPR', 'SYSRAC',
        'C##YS', 'SYSKM', 'C##TEST', 'SYSDG', 'GSMROOTUSER', 'C##CPR123'
    )
GROUP BY
    p.index_owner, p.index_name, i.index_type, i.table_name, p.partition_name
ORDER BY
    p.index_owner, p.index_name, p.partition_name;

SPOOL OFF
EOF
