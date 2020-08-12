#!/usr/bin/bash

#SCRIPT:     SynopsysMonitorDbActivity_202007.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-07-24          # pj move from command line dev to script
#VERSION:    2008121627Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: 2841540408 12312    # :! grep -v grepvcksum <script> | cksum
#CHANGELOG:  2008121627Z pj Add sleep command line positional parameter $1.  Add advanced usage, with new version of SnpsDbStatDelta_202008.bash which accepts input via pipe from output of this script. Change shebang to /usr/bin/bash. Fix typo. Remove customer name. 
 
#PURPOSE:    To try to detect database activity during long silent software upgrades, database migrations, etc.  
#PURPOSE:    Meant to only be used maybe every hour or two during an upgrade or similar Black Duck event, just to make sure the database is still processing data silently. 
#PURPOSE:    Suggestions welcome. 

#REQUIRES:  psql, Black Duck (FKA Hub) server.
#RECOMMENDED:  SnpsDbStatDelta_202008.bash to calculate deltas between two runs of these db stats commands. 

#USAGE: Edit CONFIGs, then:
#USAGE: SynopsysMonitorDbActivity_202007.bash 15s
#USAGE: or: SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(date --utc +%Y%m%d%a)_$(hostname -f).log 
#USAGE: or: ./SynopsysMonitorDbActivity_202007.bash |& grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash
#USAGE: Advanced:  date ; hostname -f ; pwd ; whoami ; ./SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out |& grep -zPo '(?s)^pg_statio_user_tables\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash |& tee -a /tmp/SnpsDbStatDelta_202008.bash_sup-pjalajas-hub.dc1.lan_20200809162924ZSunPJ.outDelta_202008.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out
#USAGE: For the grep -zPo filter, can use any of these "cmd" (some are more appropriate for deltas than others): v_hub_script_status v_bootstrap_script_status pg_stat_database pg_locks pg_statio_user_tables pg_stat_xact_user_tables pg_stat_user_indexes pg_statio_user_sequences pg_stat_user_functions pg_stat_xact_user_functions pg_stat_replication pg_stat_progress_vacuum pg_stat_database_conflicts pg_stat_activity

#CONFIG
PSQL="/usr/bin/psql"
#DBCONN=" -h 127.0.0.1 -p 55436 -U blackduck -d bds_hub "
DBCONN=" -h sup-pjalajas-2.dc1.lan -p 5432 -U blackduck -d bds_hub "
#For sleep duration between db stats collection runs, increase it if not enough changes to make you comfortable with progress
msleep=${1:-3s} # either put sleep as after script name, like SynopsysMonitorDbActivity_202007.bash 15s, or it defaults to 3s, or whatever you change this 3s to.
mloops=2   # 2 is good.  Just run it again later.

#INIT

date ; date --utc ; hostname -f ; pwd ; whoami ; 

#MAIN

for loop in $(seq 1 $mloops);  
do 
 
  echo
  echo v_hub script status...
  echo "SELECT now(), inet_server_addr(), 'v_hub_script_status' AS cmd, $loop AS loop, * FROM st.v_hub ORDER BY installed_on DESC LIMIT 10 ; " | \
    $PSQL $DBCONN ; 
  
  echo
  echo v_bootstrap script status...
  echo "SELECT now(), inet_server_addr(), 'v_bootstrap_script_status' AS cmd, $loop AS loop, * FROM st.v_bootstrap ORDER BY installed_on DESC LIMIT 10 ; " | \
    $PSQL $DBCONN ; 
  
  echo
  echo pg_stat_database...
  echo "SELECT now(), inet_server_addr(), 'pg_stat_database' AS cmd, $loop AS loop, * FROM pg_stat_database ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_locks...
  echo "SELECT now(), inet_server_addr(), 'pg_locks' AS cmd, $loop AS loop, * FROM pg_locks ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_statio_user_tables...
  echo "SELECT now(), inet_server_addr(), 'pg_statio_user_tables' AS cmd, $loop AS loop, * FROM pg_statio_user_tables \
      WHERE relname IN ('v_hub','v_bootstrap','scan_composite_leaf','notification','audit_event','scan_scan','scan_file','scan_chunk') ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_xact_user_tables... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_xact_user_tables' AS cmd, $loop AS loop, * FROM pg_stat_xact_user_tables \
      WHERE relname IN ('v_hub','v_bootstrap','scan_composite_leaf','notification','audit_event','scan_scan','scan_file','scan_chunk') ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_user_indexes... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_user_indexes' AS cmd, $loop AS loop, * FROM pg_stat_user_indexes \
      --take out WHERE clause to see everything, for the moment
      --WHERE relname IN ('v_hub','v_bootstrap','scan_composite_leaf','notification','audit_event','scan_scan','scan_file') \
      ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_statio_user_sequences... 
  echo "SELECT now(), inet_server_addr(), 'pg_statio_user_sequences' AS cmd, $loop AS loop, * FROM pg_statio_user_sequences \
      --take out WHERE clause to see everything, for the moment
      --WHERE relname IN ('v_hub','v_bootstrap','scan_composite_leaf','notification','audit_event','scan_scan','scan_file') \
      ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_user_functions... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_user_functions' AS cmd, $loop AS loop, * FROM pg_stat_user_functions ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_xact_user_functions... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_xact_user_functions' AS cmd, $loop AS loop, * FROM pg_stat_xact_user_functions ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_replication... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_replication' AS cmd, $loop AS loop, * FROM pg_stat_replication ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_progress_vacuum... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_progress_vacuum' AS cmd, $loop AS loop, * FROM pg_stat_progress_vacuum ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_database_conflicts... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_database_conflicts' AS cmd, $loop AS loop, * FROM pg_stat_database_conflicts ; " | \
    $PSQL $DBCONN ; 

  echo
  echo pg_stat_activity... 
  echo "SELECT now(), inet_server_addr(), 'pg_stat_activity' AS cmd, $loop AS loop, * FROM pg_stat_activity ; " | \
    $PSQL $DBCONN ; 

  echo
  echo sar...
  sar -bdBrSq -n ALL 3 1 | grep -v -e "^\s*$" -e "^Average:" | while read line ; do echo "$(date --utc +%Y%m%dT%H%M%S.%NZ%a) : sar : $line" ; done 

  echo
  if [[ "$loop" != "$mloops" ]] ; then
    echo sleeping $msleep… ; 
    sleep $msleep ;  
  fi
done 

exit

#REFERENCE
put notes here

Can use any one (only one for now) of these "cmd" in grep -zPo filter, though some may have no data of which to take deltas:
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ grep -Po "\'.*\' AS cmd" ./SynopsysMonitorDbActivity_202007.bash | tr -d \' | sed -re 's/ AS cmd//g'                             
v_hub_script_status
v_bootstrap_script_status
pg_stat_database
pg_locks
pg_statio_user_tables
pg_stat_xact_user_tables
pg_stat_user_indexes
pg_statio_user_sequences
pg_stat_user_functions
pg_stat_xact_user_functions
pg_stat_replication
pg_stat_progress_vacuum
pg_stat_database_conflicts
pg_stat_activity

[pjalajas@sup-pjalajas-hub SynopsysScripts]$ grep USAGE SynopsysMonitorDbActivity_202007.bash
#USAGE: Edit CONFIGs, then:
#USAGE: SynopsysMonitorDbActivity_202007.bash 15s
#USAGE: or: SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(date --utc +%Y%m%d%a)_$(hostname -f).log 
#USAGE: or: ./SynopsysMonitorDbActivity_202007.bash |& grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash
#USAGE: Advanced:  date ; hostname -f ; pwd ; whoami ; ./SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out |& grep -zPo '(?s)^pg_statio_user_tables\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash |& tee -a /tmp/SnpsDbStatDelta_202008.bash_sup-pjalajas-hub.dc1.lan_20200809162924ZSunPJ.outDelta_202008.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ date ; hostname -f ; pwd ; whoami ; ./SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out |& grep -zPo '(?s)^pg_statio_user_tables\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash |& tee -a /tmp/SnpsDbStatDelta_202008.bash_sup-pjalajas-hub.dc1.lan_20200809162924ZSunPJ.outDelta_202008.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out
Tue Aug 11 16:28:47 EDT 2020
sup-pjalajas-hub.dc1.lan
/home/pjalajas/Documents/dev/customers/customer/00811525_Install2020.6.0/SynopsysScripts
pjalajas
Tue Aug 11 16:28:47 EDT 2020
Tue Aug 11 20:28:47 UTC 2020
sup-pjalajas-hub.dc1.lan
/home/pjalajas/Documents/dev/customers/customer/00811525_Install2020.6.0/SynopsysScripts
pjalajas



Output:
now                            |  inet_server_addr  |  cmd                    |  loop  |  relid  |  schemaname  |  relname              |  heap_blks_read  |  heap_blks_hit  |  idx_blks_read  |  idx_blks_hit  |  toast_blks_read  |  toast_blks_hit  |  tidx_blks_read  |  tidx_blks_hit
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  v_bootstrap          |  .               |  1              |  .              |  2             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  audit_event          |  .               |  534            |  .              |  53            |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  notification         |  .               |  .              |  .              |  .             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  scan_composite_leaf  |  .               |  .              |  .              |  .             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  scan_scan            |  .               |  10544          |  .              |  8             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  v_hub                |  .               |  4              |  .              |  2             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  scan_chunk           |  .               |  .              |  .              |  .             |  .                |  .               |  .               |  .
2020-08-11T16:29:05.731918-04  |  10.1.65.50        |  pg_statio_user_tables  |  1     |  .      |  st          |  scan_file            |  .               |  .              |  .              |  .             |  .                |  .               |  .               |  .



Just show the deltas for pg_stat_database for bds_hub db:
[pjalajas@sup-pjalajas-hub 00811525_Install2020.6.0]$ ./SynopsysMonitorDbActivity_202007.bash |& grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash | cat -A | grep -e "^now" -e bds_hub\ 
now         |  inet_server_addr  |  cmd               |  loop  |  datid  |  datname         |  numbackends  |  xact_commit  |  xact_rollback  |  blks_read  |  blks_hit  |  tup_returned  |  tup_fetched  |  tup_inserted  |  tup_updated  |  tup_deleted  |  conflicts  |  temp_files  |  temp_bytes  |  deadlocks  |  blk_read_time  |  blk_write_time  |  stats_reset$
18_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bds_hub         |  .            |  538          |  .              |  .          |  10093     |  127820        |  3079         |  .             |  9            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$
