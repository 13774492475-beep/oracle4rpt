#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="best_para_set_${timestamp}.txt"
filename="best_para_set.txt"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF        
SET UNDERLINE OFF     
SET PAGESIZE 0     
SET NEWPAGE NONE      
SET LINESIZE 2000     
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ' '        
SET TIMING OFF

SPOOL $filename

SELECT
    a.ksppinm || '\$-\$' || c.ksppstvl AS result
FROM
    x\$ksppi a
JOIN
    x\$ksppcv b ON a.indx = b.indx
JOIN
    x\$ksppsv c ON a.indx = c.indx
WHERE
    a.ksppinm IN (
        '_ash_size',
        '_cleanup_rollback_entries',
        '_clusterwide_global_transactions',
        '_cursor_obsolete_threshold',
        '_enable_automatic_sqltune',
        '_gc_bypass_readers',
        '_gc_override_force_cr',
        '_lm_tickets',
        '_optimizer_extended_cursor_sharing',
        '_optimizer_use_feedback',
        '_resource_manager_always_off',
        '_trace_files_public'
    )
ORDER BY
    a.ksppinm;

SPOOL OFF
EOF

