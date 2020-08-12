#!/usr/bin/bash

#SCRIPT:     SnpsDbStatDelta_202008.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-07-26          # 
#VERSION:    2008121709Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: 1383907451 14645    # :! grep -v grepvcksum <script> | cksum
#CHANGELOG:  2008121709Z pj add accept pipe input, other cleanup.

#PURPOSE:    Intended to help show relevant db activity during hours-long very quiet periods during Black Duck upgrades/migrations (like when a huge 1TB table is being copied). Intended to show changes in database stats between exactly two runs of a db stats command which were output to the same file. For each cell with a numerical value, substracts the earlier value from the later value.  Dates are subtracted and the interval is reported in seconds (that is, the time interval between the two runs or loops of the stats gathering script).

#REQUIRES:    Two runs of a postgresql db stats query as input to this script, so that changes in the stats that occured between those two runs can be calculated. .   
#RECOMMENDED: n/a

#USAGE: See REFERENCE section at bottom of this script.
#USAGE: Simple option: First run SynopsysMonitorDbActivity_202007.bash and output to a .log file.  Then pull out of that log file the data from the two runs of db stats query (for example, for pg_stats_database), into a file named "input":
#USAGE:   cat SynopsysMonitorDbActivity_202007.bash_20200727Mon_sup-pjalajas-hub.dc1.lan.log | grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' > input
#USAGE: Then, edit CONFIGs below, if any, then run, for example:
#USAGE: bash SnpsDbStatDelta_202008.bash | less -inRF # or:
#USAGE: bash SnpsDbStatDelta_202008.bash | grep -e "^now\ " -e bds_hub\  # show just changes in bds_hub db (need escape after bds_hub to distinguish from bds_hub_report if it exists).
#USAGE: Advanced:  date ; hostname -f ; pwd ; whoami ; ./SynopsysMonitorDbActivity_202007.bash 15s |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out |& grep -zPo '(?s)^pg_statio_user_tables\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash |& tee -a /tmp/SnpsDbStatDelta_202008.bash_sup-pjalajas-hub.dc1.lan_20200809162924ZSunPJ.outDelta_202008.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a)PJ.out
#USAGE: For the grep -zPo filter, can use any of these "cmd" (some are more appropriate for deltas than others): v_hub_script_status v_bootstrap_script_status pg_stat_database pg_locks pg_statio_user_tables pg_stat_xact_user_tables pg_stat_user_indexes pg_statio_user_sequences pg_stat_user_functions pg_stat_xact_user_functions pg_stat_replication pg_stat_progress_vacuum pg_stat_database_conflicts pg_stat_activity
#USAGE: Works until year 2029 (see "202." lines below). 

#TODO:  Enhance so this can walk through an entire db stats file that has 2 runs of several different db stats commands. 
#TODO:  Watch out for empty cells, like stats_reset; and columns with spaces, like dates.

#CONFIG

#FUNCTIONS

#INIT
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
date ; date --utc ; hostname -f ; pwd ; whoami ; 

#MAIN

#echo Input:
#cat input ;  # TESTING
mindex=0 ; 
unset line
unset input
input=""
input="$(cat)" # wow, so easy to pipe in...TODO: too easy?
#echo -e "\$input:\n${input}"; echo
mcols=$(echo "$input" | grep "^\s*now\s*" | head -n 1 | wc -w) ;  # count number of space-separated "words" including | in pg output header row
mrowsperloop=$(($(echo "$input" | grep \| | wc -l)/2)) ;  # head -n 4 for TESTING, one header, 3 data = 2 loops; just count psql output with | 
mcellsperloop=$((mcols*mrowsperloop)) ; 
#Presume 2 loops; that is, two runs of data to compare (subtract), to see what changed between the runs/loops.
#echo columns: $mcols ;  # TESTING
#echo rows per loop: $mrowsperloop ;  # TESTING
#echo cells per loop: $mcellsperloop ;  # TESTING
#unset myarray; 
declare -a myarray
read -a myarray < <(echo "${input}" | grep \| | tr -s \  | sed -re 's/(202.-..-..) /\1T/g;s/\| *\|/| _ |/g;s/\| *\|/| _ |/g;s/\| $/| _/g' | xargs) 
#echo "\$myarray:" # TESTING
#echo "${myarray[@]}" ;  # TESTING.  Can be big; this prints all the data on one row of output, first all the cells of the first run, then all the cells of the second run.
echo
echo Output:
for mrow in $(seq 1 ${mrowsperloop}) ; 
do for mcell in $(seq 1 ${mcols}) ; 
   do subtrahendindex=$((mindex)) ;  # array index of cell in first loop
      minuendindex=$((mindex+mcellsperloop)) ;  # array index of cell in second loop; TODO: off by two?(!?)?
      #echo ; echo "====================" ; echo row:$mrow :: cell:$mcell :: secondindex:$minuendindex :: firstindex:$subtrahendindex :: secondvalue:${myarray[${minuendindex}]} :: firstvalue:${myarray[${subtrahendindex}]} ;  echo "====================" ; echo ; # TESTING
      #Start with index 0, the first cell of first loop, if it's numeric, then subtract that from the first cell of the second loop (using the much higher array index), 
      if [[ ${myarray[${minuendindex}]} =~ ^-?[0-9]+[.]?([0-9]+)?$ ]] && [[ ${myarray[${subtrahendindex}]} =~ ^-?[0-9]+[.]?([0-9]+)?$ ]] ; then 
        #is numeric, so do substract 
        #replace 0 with .; replace empty cell with _
        mdiff="$((${myarray[${minuendindex}]}-${myarray[${subtrahendindex}]}))" ; 
        if [[ "$mdiff" -gt "0" ]] ; then 
          echo -n "$((${myarray[${minuendindex}]}-${myarray[${subtrahendindex}]})) " ; 
        else
          echo -n \.\  # too many 0s are distracting
        fi
        #Dates can have variable number of nanoseconds
        #  + [[ 2020-08-02T19:23:26.248555+00 =~ ^202.-..-..T..:..:..\.......\+..$ ]]
        #                                + [[ 2020-08-02T19:23:17.86022+00 =~ ^202.-..-..T..:..:..\.......\+..$ ]]
      elif [[ ${myarray[${minuendindex}]} =~ ^202.-..-..T..:..:..\.[0-9]*\+..$ ]] && [[ ${myarray[${subtrahendindex}]} =~ ^202.-..-..T..:..:..\.[0-9]*\+..$ ]] ; then 
        echo -n "$(($(date +%s -d "${myarray[${minuendindex}]}")-$(date +%s -d "${myarray[${subtrahendindex}]}")))_seconds "
      else 
        echo -n "${myarray[${minuendindex}]} " ;  # just echo the string. TODO: maybe better option here?
      fi ; 
      mindex=$((mindex+1)) ; # continue to walk along the wide array, x indexes apart
    done ; 
  echo ; 
done | column -t  
exit

#REFERENCE
put notes here

[pjalajas@sup-pjalajas-hub 00811525_Install2020.6.0]$ ./SynopsysMonitorDbActivity_202007.bash |& grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' |& ./SnpsDbStatDelta_202008.bash | cat -A | grep -e "^now" -e bds_hub\ 
now        |  inet_server_addr  |  cmd               |  loop  |  datid  |  datname         |  numbackends  |  xact_commit  |  xact_rollback  |  blks_read  |  blks_hit  |  tup_returned  |  tup_fetched  |  tup_inserted  |  tup_updated  |  tup_deleted  |  conflicts  |  temp_files  |  temp_bytes  |  deadlocks  |  blk_read_time  |  blk_write_time  |  stats_reset$
6_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bds_hub         |  .            |  228          |  .              |  .          |  8885      |  115029        |  2495         |  .             |  3            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$



Collect several kinds of stats.  That script runs the db stats queries twice, with a few seconds sleep between loops:
$ ./SynopsysMonitorDbActivity_202007.bash |& tee -a /tmp/SynopsysMonitorDbActivity_202007.bash_$(date --utc +%Y%m%d%a)_$(hostname -f).log 

Create a file of one of the kinds of stats from the log file from above, for example the pg_stat_database view:
$ grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' SynopsysMonitorDbActivity_202007.bash_20200727Mon_sup-pjalajas-hub.dc1.lan.log > input

Show the differences of the stats from the two runs of pg_stat_database in that "input" file, for just the bds_hub database
$ bash SnpsDbStatDelta_202008.bash | grep -e "^now\ " -e bds_hub\ 
Output:
now        |  inet_server_addr  |  cmd               |  loop  |  datid  |  datname         |  numbackends  |  xact_commit  |  xact_rollback  |  blks_read  |  blks_hit  |  tup_returned  |  tup_fetched  |  tup_inserted  |  tup_updated  |  tup_deleted  |  conflicts  |  temp_files  |  temp_bytes  |  deadlocks  |  blk_read_time  |  blk_write_time  |  stats_reset
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bds_hub         |  .            |  290          |  .              |  .          |  9660      |  103486        |  3096         |  .             |  7            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds



[pjalajas@sup-pjalajas-hub 00811525_Install2020.6.0]$ bash SnpsDbStatDelta_202008.bash | cat -A
Sat Aug  1 15:21:33 EDT 2020$
Sat Aug  1 19:21:33 UTC 2020$
sup-pjalajas-hub.dc1.lan$
/home/pjalajas/Documents/dev/customers/customer/00811525_Install2020.6.0$
pjalajas$
$
Input:$
columns: 45$
rows per loop: 7$
cells per loop: 315$
now | inet_server_addr | cmd | loop | datid | datname | numbackends | xact_commit | xact_rollback | blks_read | blks_hit | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | stats_reset 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 12404 | postgres | 0 | 141505 | 119 | 1004 | 4886793 | 69015045 | 784219 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2020-06-08T17:43:02.724372+00 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 16384 | bds_hub | 8 | 170610214 | 26796 | 9527237 | 2101812277 | 34366996551 | 1769643523 | 5596626 | 14738456 | 39832 | 0 | 36 | 1788780172 | 0 | 0 | 0 | 2020-06-08T17:43:03.347337+00 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 1 | template1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | _ 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 12403 | template0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | _ 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 16427 | bds_hub_report | 0 | 172894 | 0 | 14763 | 10205022 | 108443542 | 1568608 | 64677 | 66277 | 4161 | 0 | 0 | 0 | 0 | 0 | 0 | 2020-06-08T17:43:06.326829+00 2020-07-27T18:27:29.688658+00 | 10.0.0.66 | pg_stat_database | 1 | 16433 | bdio | 1 | 13279230 | 13112853 | 27021833 | 3300881541 | 12729021747 | 12386966470 | 9294423 | 4865953 | 858917 | 0 | 319 | 8142731981 | 0 | 0 | 0 | 2020-06-08T17:45:19.395492+00 now | inet_server_addr | cmd | loop | datid | datname | numbackends | xact_commit | xact_rollback | blks_read | blks_hit | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | stats_reset 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 12404 | postgres | 0 | 141505 | 119 | 1004 | 4886793 | 69015045 | 784219 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2020-06-08T17:43:02.724372+00 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 16384 | bds_hub | 6 | 170610504 | 26796 | 9527237 | 2101821937 | 34367100037 | 1769646619 | 5596626 | 14738463 | 39832 | 0 | 36 | 1788780172 | 0 | 0 | 0 | 2020-06-08T17:43:03.347337+00 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 1 | template1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | _ 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 12403 | template0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | _ 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 16427 | bds_hub_report | 0 | 172896 | 0 | 14763 | 10205091 | 108444699 | 1568619 | 64677 | 66277 | 4161 | 0 | 0 | 0 | 0 | 0 | 0 | 2020-06-08T17:43:06.326829+00 2020-07-27T18:27:38.071008+00 | 10.0.0.66 | pg_stat_database | 2 | 16433 | bdio | 1 | 13279247 | 13112870 | 27021833 | 3300881541 | 12729021747 | 12386966470 | 9294423 | 4865953 | 858917 | 0 | 319 | 8142731981 | 0 | 0 | 0 | 2020-06-08T17:45:19.395492+00$
$
Output:$
now        |  inet_server_addr  |  cmd               |  loop  |  datid  |  datname         |  numbackends  |  xact_commit  |  xact_rollback  |  blks_read  |  blks_hit  |  tup_returned  |  tup_fetched  |  tup_inserted  |  tup_updated  |  tup_deleted  |  conflicts  |  temp_files  |  temp_bytes  |  deadlocks  |  blk_read_time  |  blk_write_time  |  stats_reset$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  postgres        |  .            |  .            |  .              |  .          |  .         |  .             |  .            |  .             |  .            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bds_hub         |  .            |  290          |  .              |  .          |  9660      |  103486        |  3096         |  .             |  7            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  template1       |  .            |  .            |  .              |  .          |  .         |  .             |  .            |  .             |  .            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  _$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  template0       |  .            |  .            |  .              |  .          |  .         |  .             |  .            |  .             |  .            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  _$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bds_hub_report  |  .            |  2            |  .              |  .          |  69        |  1157          |  11           |  .             |  .            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$
9_seconds  |  10.0.0.66         |  pg_stat_database  |  1     |  .      |  bdio            |  .            |  17           |  17             |  .          |  .         |  .             |  .            |  .             |  .            |  .            |  .          |  .           |  .           |  .          |  .              |  .               |  0_seconds$
