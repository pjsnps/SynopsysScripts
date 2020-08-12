#!/usr/bin/env bash

#SCRIPT:     SnpsDbStatDelta_202008.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-07-26          # 
#VERSION:    2008081812Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: ____under dev# :! grep -v grepvcksum <script> | cksum

#PURPOSE:    Intended to help show relevant db activity during hours-long very quiet periods during Black Duck upgrades/migrations (like when a huge 1TB table is being copied). 
#PURPOSE:    Intended to try to show changes in database stats between exactly two runs of a db stats command which were output to the same file. For each cell with a numerical value, substracts the earlier value from the later value.  Dates are subtracted and the interval is reported in seconds (that is, the time interval between the two runs or loops of the stats gathering script)..

#USAGE: See REFERENCE section at bottom of this script.
#USAGE: For now, first pull out the one stats query that was run twice, with like, for pg_stats_database: 
#USAGE:   cat SynopsysMonitorDbActivity_202007.bash_20200727Mon_sup-pjalajas-hub.dc1.lan.log | grep -zPo '(?s)^pg_stat_database\.\.\..*?rows\)' > input
#USAGE: Edit CONFIGs, then:
#USAGE: bash SnpsDbStatDelta_202008.bash | less -inRF  
#USAGE: bash SnpsDbStatDelta_202008.bash | grep -e "^now\ " -e bds_hub\  # show just changes in bds_hub db (need escape to delimit from bds_hub_report if exists).
#USAGE: Works until year 2029 (see "202." lines below). 

#CHANGELOG: 2008081812Z pj trying to change to pipe input

#TODO:  Enhance so this can walk through an entire file that has 2 runs of a few different db stats commands. 

#CONFIG
#input=./input # path/filename.ext of input file containing exactly 2 runs of the db stats command separated by some time period (few seconds or minutes)
#PSQL="/usr/bin/psql" # db connection not needed for this script
#DBCONN=" -h 127.0.0.1 -p 55436 -U blackduck -d bds_hub " # db connection not needed for this script
#msleep=5s  # sleep between loops, increase if not enough changes to make you comfortable with progress
#mloops=2   # 2 is good.  Just run it again later.

#FUNCTIONS

help_wanted() {
    [ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]
}

  if help_wanted "$@"; then
    usage
    exit 0
  fi

#INIT
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
date ; date --utc ; hostname -f ; pwd ; whoami ; 

#MAIN

echo
#echo Input:
#cat input ;  # TESTING
mindex=0 ; 
#Watch out for empty cells, like stats_reset; and columns with spaces, like dates.
#TODO: allow pipe in:  while read line ; do echo "$line" ; done < "${1:-/dev/stdin}"
#ORIGINAL, WORKS:  read -a myarray < <(grep \| $input | tr -s \  | sed -re 's/(202.-..-..) /\1T/g;s/\| *\|/| _ |/g;s/\| *\|/| _ |/g;s/\| $/| _/g' | xargs) ;  # head -n 4 for TESTING; need to remove spaces within cells
unset line
unset input
input=""
#IFS=$'\n'
#while read -r line
#do
  #input="$(echo -e "${input}${line}")\n"
  #input="$(echo -e "${input}${line}")"
  #input="$(echo -e "${input}\n")"
#done < "${1:-/dev/stdin}"
input="$(cat)" # wow, so easy to pipe in
echo
#echo -e "\$input:\n${input}"
#echo
mcols=$(echo "$input" | grep "^\s*now\s*" | head -n 1 | wc -w) ;  # count number of space-separated "words" including | in pg output header row
mrowsperloop=$(($(echo "$input" | grep \| | wc -l)/2)) ;  # head -n 4 for TESTING, one header, 3 data = 2 loops; just count psql output with | 
mcellsperloop=$((mcols*mrowsperloop)) ; 
#Presume 2 loops; that is, two runs of data to compare (subtract), to see what changed between the runs/loops.
#echo columns: $mcols ;  # TESTING
#echo rows per loop: $mrowsperloop ;  # TESTING
#echo cells per loop: $mcellsperloop ;  # TESTING
#unset myarray; 
declare -a myarray
#read -a myarray < <(grep \| $input | tr -s \  | sed -re 's/(202.-..-..) /\1T/g;s/\| *\|/| _ |/g;s/\| *\|/| _ |/g;s/\| $/| _/g' | xargs) ;  # head -n 4 for TESTING; need to remove spaces within cells
read -a myarray < <(echo "${input}" | grep \| | tr -s \  | sed -re 's/(202.-..-..) /\1T/g;s/\| *\|/| _ |/g;s/\| *\|/| _ |/g;s/\| $/| _/g' | xargs) ;  # head -n 4 for TESTING; need to remove spaces within cells
#echo "\$myarray:"
#echo "${myarray[@]}" ;  # TESTING.  Can be big, maybe comment out; this prints all the data on one row of output, first all the cells of the first run, then all the cells of the second run.
echo
echo Output:
for mrow in $(seq 1 ${mrowsperloop}) ; 
do for mcell in $(seq 1 ${mcols}) ; 
   do subtrahendindex=$((mindex)) ;  # array index of cell in first loop
      minuendindex=$((mindex+mcellsperloop-1)) ;  # array index of cell in second loop; TODO: off by two?(!?)?
      minuendindex=$((mindex+mcellsperloop)) ;  # array index of cell in second loop; TODO: off by two?(!?)?
      #echo ; echo "====================" ; echo row:$mrow :: cell:$mcell :: secondindex:$minuendindex :: firstindex:$subtrahendindex :: secondvalue:${myarray[${minuendindex}]} :: firstvalue:${myarray[${subtrahendindex}]} ;  echo "====================" ; echo ; # TESTING
      #Start with index 0, the first cell of first loop, if it's numeric, then subtract that from the first cell of the second loop (using the much higher array index), 
      if [[ ${myarray[${minuendindex}]} =~ ^-?[0-9]+[.]?([0-9]+)?$ ]] && [[ ${myarray[${subtrahendindex}]} =~ ^-?[0-9]+[.]?([0-9]+)?$ ]] ; then 
        #is numeric, so do substract 
        #replace 0 with .; empty with _
        mdiff="$((${myarray[${minuendindex}]}-${myarray[${subtrahendindex}]}))" ; 
        if [[ "$mdiff" -gt "0" ]] ; then 
          echo -n "$((${myarray[${minuendindex}]}-${myarray[${subtrahendindex}]})) " ; 
        else
          echo -n \.\  # too many 0s are distracting
        fi
        #Dates can have variable number of nanoseconds
        #  + [[ 2020-08-02T19:23:26.248555+00 =~ ^202.-..-..T..:..:..\.......\+..$ ]]
        #                                + [[ 2020-08-02T19:23:17.86022+00 =~ ^202.-..-..T..:..:..\.......\+..$ ]]
      #elif [[ ${myarray[${minuendindex}]} =~ ^202.-..-..T..:..:..\.......\+..$ ]] && [[ ${myarray[${subtrahendindex}]} =~ ^202.-..-..T..:..:..\.......\+..$ ]] ; then 
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






Collect several kinds of stats.  This runs twice, with a few seconds sleep between loops:
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
[pjalajas@sup-pjalajas-hub 00811525_Install2020.6.0]$ 
