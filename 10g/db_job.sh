#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_job_${timestamp}.csv"
filename="db_job.csv"

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

COLUMN "Job" FORMAT 999999999
COLUMN "Priv_User" FORMAT A20
COLUMN "What" FORMAT A300  
COLUMN "Status" FORMAT A10
COLUMN "Warning" FORMAT A30

SPOOL $filename

SELECT
    job AS "Job",
    log_user AS "Priv_User",
    '"' || REPLACE(REPLACE(NVL(what, ' ** What Not Available ** '), '"', '""'), CHR(10), ' ') || '"' AS "What",  
    CASE
        WHEN broken = 'Y' THEN 'BROKEN'
        WHEN last_date IS NULL THEN 'PENDING'
        ELSE 'RUNNING'
    END AS "Status",
    CASE
        WHEN failures > 0 THEN 'WARNING: Failures detected'
        ELSE 'No Warnings'
    END AS "Warning"
FROM
    dba_jobs
WHERE
    log_user NOT IN (
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
ORDER BY
    job;

SPOOL OFF
EOF

