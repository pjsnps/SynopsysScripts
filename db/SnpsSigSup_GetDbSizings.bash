#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetDbSizings.bash
#DATE: Fri Oct 30 18:40:13 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2011170253Z
#GREPVCKSUM: TODO 

#PURPOSE: Try to give some details on the size of the Synopsys Black Duck (Hub) database, including db size, largest table sizes, counts of projects, scans, components, ec. 

#NOTES:  Suggestions welcome.  

#USAGE: sudo bash SnpsSigSup_GetDbSizings.bash

#CONFIG
BDHOST=sup-pjalajas-2.dc1.lan
PGHOST="${BDHOST}"
PGHOST="pjalajas-blackduck-2020-10-0c.cyabejla8bjm.us-east-1.rds.amazonaws.com"
PGUSER="blackduck"
#TODO:  mod db dir commands for aws rds
#DATABASEDIR=/var/lib/pgsql/9.6/data/base # no trailing slash

#TODO:
#TODO: add instruction to copy to SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server; workaround for now: copy this script to remote /tmp then run over ssh
#TODO: make sure we are getting the data from the correct host (script, bd, pg)...until then, just run it on the bd or pg host.

#MAIN

echo
echo -e "$(date) : $(date --utc) \nSCRIPT HOST : $(hostname -f)     ::     BDHOST : ${BDHOST}     ::     PGHOST : ${PGHOST}"
echo -n $0 
grep "\#VERSION" $0  # TODO fix me, echos command
echo


for mhost in localhost $BDHOST $PGHOST
do 
  echo $mhost
  echo
  #TODO hack, use timout cop out for aws rds pghost
  timeout 3s ssh $mhost "echo nproc : $(nproc) " 
  echo
  timeout 3s ssh $mhost 'echo -e "free -g :\n$(free -g)"'
  echo
  timeout 3s ssh $mhost 'echo $(grep -e MemTotal -e SwapTotal /proc/meminfo)'
  echo
  timeout 3s ssh $mhost 'df -hPT | grep -v -e container -e docker' #TODO fix me
  echo
done

echo

echo
#df -hPT $DATABASEDIR 

#echo
#echo Black Duck Version: 
#psql -h $PGHOST -U $PGUSER -d bds_hub \
  #-c "SELECT version FROM st.v_hub ORDER BY installed_on DESC LIMIT 1 ; " 

#TODO: mod to allow aws rds
#echo
#echo "du data/base :"
#du -sh $DATABASEDIR ; 

echo
#psql -qAt -h $PGHOST -U $PGUSER -d bds_hub -c "
psql -qAt -h $PGHOST -U $PGUSER -d template1 -c "
  SELECT version() 
; " ; 

echo
echo Black Duck Version: $(curl -k -s -L https://${BDHOST}/api/current-version | jq -r .version )

#non-pg database names
#echo
#psql -h $PGHOST -U $PGUSER -d template1 -c "\\l+ " | grep -v -e " postgres " -e " template[01] " -e " rdsadmin "

#echo
#echo database sizes
##psql -h $PGHOST -U $PGUSER -d bds_hub -c "\\l+ " | grep -e Size -e bds -e alert
##psql -h $PGHOST -U $PGUSER -d template1 -c "\\l+ " | grep -e Size -e bds -e alert
#psql -h $PGHOST -U $PGUSER -d template1 -c "\\l+ "
#psql -h $PGHOST -U $PGUSER -d template1 -c "SELECT pg_size_pretty(pg_database_size('dbname') );"


echo
echo database sizes
psql -h $PGHOST -U $PGUSER -d bds_hub -c "
SELECT d.datname as Name,  pg_catalog.pg_get_userbyid(d.datdba) as Owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE 'No Access'
    END as Size
FROM pg_catalog.pg_database d
    order by
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END desc -- nulls first
    LIMIT 10;" | grep -v -e " postgres " -e " template[01]" -e " rdsadmin "


echo
echo largest relations
for mdb in bds_hub bds_hub_report alert ; do
        echo largest relations in $mdb:
	#psql -h $PGHOST -U $PGUSER -d bds_hub -c "
	psql -h $PGHOST -U $PGUSER -d $mdb -c "
	SELECT nspname || '.' || relname AS "relation",
	    pg_size_pretty(pg_relation_size(C.oid)) AS "size"
	  FROM pg_class C
	  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
	  --WHERE nspname NOT IN ('pg_catalog', 'information_schema')
	  WHERE nspname NOT IN ('pg_catalog', 'information_schema','pg_toast')
	  ORDER BY pg_relation_size(C.oid) DESC
	  LIMIT 10;" 2> /dev/null
          echo
done


echo
for mcol in timetopersistms timetoscanms match_count num_non_dir_files num_dirs file_system_size ; 
do 
  echo -n "max $mcol : " ; 
  psql -h $PGHOST -qAt -U $PGUSER -d bds_hub -c "SELECT MAX($mcol) FROM st.scan_scan ;"  ; 
done ; 

echo ;
psql -qAt -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT DISTINCT 'count unique scans' AS column, COUNT(id) FROM st.scan_scan ; " 
psql -qAt -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT DISTINCT 'count unique code locations' AS column, COUNT(code_location_id) FROM st.scan_scan ; "       
psql -qAt -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT DISTINCT 'count unique scan_source_id' AS column, COUNT(scan_source_id) FROM st.scan_scan ; "
psql -qAt -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT 'count unique release_ids' AS column, COUNT(*) FROM (SELECT DISTINCT project_id,release_id FROM st.version_bom) As tmp ; "
psql -qAt -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT 'count scan_component_dependency' AS column, COUNT(*) FROM st.scan_component_dependency ; "

echo
echo Projects with most versions:
psql -h $PGHOST -U $PGUSER -d bds_hub \
  -c "SELECT project_id, COUNT(release_id) AS proj_versions FROM st.version_bom GROUP BY project_id ORDER BY COUNT(release_id) DESC LIMIT 5 ; "


echo

echo "
set search_path=st ;
select status_applied, count(*) from scan_state_event group by status_applied;
select * from scan_state_event where scan_id in (select a.id from (select id, trunc((timelastmodified-scantime)/60000,0) as scan_time from scan_scan where trunc((timelastmodified-scantime)/60000,0) > 40 order by scan_time desc limit 3) a) order by transition_timestamp_db;
select * from scan_state_event where scan_id in (select a.id from (select id, trunc((timelastmodified-scantime)/60000,0) as scan_time from scan_scan where trunc((timelastmodified-scantime)/60000,0) <= 40 and trunc((timelastmodified-scantime)/60000,0) > 10 order by scan_time desc limit 3) a) order by transition_timestamp_db;
select * from scan_state_event where scan_id in (select a.id from (select id, trunc((timelastmodified-scantime)/60000,0) as scan_time from scan_scan where trunc((timelastmodified-scantime)/60000,0) <= 10 and trunc((timelastmodified-scantime)/60000,0) > 0 order by scan_time desc limit 3) a) order by scan_id, transition_timestamp_db;
select status_applied, count(*), trunc(avg(elapsed_msec_previous_state)/60000,0) as avg_scan_time_minutes, trunc(min(elapsed_msec_previous_state)/60000,0) as min_scan_time, trunc(max(elapsed_msec_previous_state)/60000,0) as max_scan_time from scan_state_event where scan_id not in (select distinct scan_id from scan_state_event where status_applied = 'ERROR') group by status_applied order by max_scan_time;
" | \
psql -h $PGHOST -U $PGUSER -d bds_hub 




echo
echo TODO: bloat, db_user_stats


exit
#REFERENCE
: '


[pjalajas@sup-pjalajas-hub api]$ date ; date --utc ; python3 hub-rest-api-python/examples/get_project_versions.py PN_monkeyfist5_Many_Versions | jq -C '. | length' # PJHIST number of versions for a project
Fri Oct 30 15:00:33 EDT 2020
Fri Oct 30 19:00:33 UTC 2020
111



'
