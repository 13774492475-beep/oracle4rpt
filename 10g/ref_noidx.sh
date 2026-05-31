#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="ref_noidx_${timestamp}.csv"
filename="ref_noidx.csv"

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

COLUMN "Owner" FORMAT A30
COLUMN "Constraint Name" FORMAT A30
COLUMN "Table Name" FORMAT A30
COLUMN "Column Name" FORMAT A30
COLUMN "Status" FORMAT A10

SPOOL $filename

SELECT
    a.owner AS "Owner",
    a.constraint_name AS "Constraint Name",
    a.table_name AS "Table Name",
    a.column_name AS "Column Name",
    b.status AS "Status"
FROM
    dba_cons_columns a
JOIN
    dba_constraints b ON a.constraint_name = b.constraint_name
                      AND a.owner = b.owner
                      AND a.table_name = b.table_name
WHERE
    b.constraint_type = 'R' 
    AND a.owner NOT IN (
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
    AND NOT EXISTS (
        SELECT 1
        FROM dba_ind_columns c
        WHERE a.owner = c.table_owner
          AND a.table_name = c.table_name
          AND a.column_name = c.column_name
    )
ORDER BY
    a.owner, a.table_name, a.constraint_name;

SPOOL OFF
EOF


