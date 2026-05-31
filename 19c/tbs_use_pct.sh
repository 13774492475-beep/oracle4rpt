#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="tbs_use_pct_${timestamp}.csv"
filename="tbs_use_pct.csv"

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

COLUMN atablespace_name FORMAT A30
COLUMN file_number FORMAT 999999
COLUMN TOTALSIZE FORMAT A10
COLUMN FREESIZE FORMAT A10
COLUMN useperf FORMAT 999.99
COLUMN extends_size FORMAT A10
COLUMN max_size FORMAT A10
COLUMN ifextend FORMAT A3

SPOOL $filename

select rownum as aarownum,a.* from
(
select tablespace_name as atablespace_name,file_number,
       case when round(totalsize/1024/1024,2) < 1024 then round(totalsize/1024/1024,2) ||'M' else round(totalsize/1024/1024/1024,2) ||'G' end AS TOTALSIZE,
       case when round(freesize/1024/1024,2) < 1024 then round(freesize/1024/1024,2) ||'M' else round(freesize/1024/1024/1024,2) ||'G' end AS FREESIZE,
       round((totalsize - freesize) / totalsize * 100, 2) useperf,
       case when round(extends_size/1024/1024,2) < 1024 then round(extends_size/1024/1024,2) ||'M' else round(extends_size/1024/1024/1024,2) ||'G' end AS extends_size,
       case when round(maxsize/1024/1024,2) < 1024 then round(maxsize/1024/1024,2) ||'M' else round(maxsize/1024/1024/1024,2) ||'G' end AS max_size,
       decode(ifextend, 0, 'NO', 'YES') ifextend
  from (select  a.tablespace_name,
       count(a.file_id) file_number,
       sum(a.bytes) totalsize,
       decode(b.tablespace_name, null, 0, 1) ifextend,
       sum(decode(autoextensible, 'YES', maxbytes, 'NO', bytes)) maxsize,
       sum(decode(autoextensible, 'YES', maxbytes, 'NO', bytes) - BYTES) extends_size,
       nvl(c.freesize, 0) freesize
  from dba_data_files a,       
       (select distinct tablespace_name
          from dba_data_files
         where autoextensible = 'YES') b,      
      (select tablespace_name, sum(bytes) freesize
          from dba_free_space
         group by tablespace_name) c
where a.tablespace_name = b.tablespace_name(+)
   and a.tablespace_name = c.tablespace_name(+)
   AND EXISTS (select file# from v\$datafile F WHERE STATUS in ('ONLINE', 'SYSTEM') AND   a.file_id = f.FILE# )
group by a.tablespace_name,
          decode(b.tablespace_name, null, 0, 1),
          nvl(c.freesize, 0)) order by useperf desc
) a;

SPOOL OFF
EOF
