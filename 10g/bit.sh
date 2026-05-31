#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="bit_${timestamp}.csv"
filename="bit.csv"

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

SPOOL $filename

select sum(num) objnum from
(
 select count(1) num from dba_triggers where TRIGGER_NAME like  'DBMS_%_INTERNAL%'
 union all
 select count(1) from dba_procedures a where a.object_name like 'DBMS_%_INTERNAL% '
); 
	
SPOOL OFF
EOF
