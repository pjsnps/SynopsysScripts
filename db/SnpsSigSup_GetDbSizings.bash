#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetDbSizings.bash
#DATE: Fri Oct 30 18:40:13 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010301953Z
#GREPVCKSUM: TODO 

#PURPOSE: Try to give some details on the size of the Synopsys Black Duck (Hub) database, including db size, largest table sizes, counts of projects, scans, components, ec. 

#NOTES:  Suggestions welcome.  

#USAGE: sudo bash SnpsSigSup_GetDbSizings.bash

#CONFIG
BDHOST=sup-pjalajas-2.dc1.lan
PGHOST="${BDHOST}"
DATABASEDIR=/var/lib/pgsql/9.6/data/base # no trailing slash

#TODO:
#TODO: add instruction to copy to SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server; workaround for now: copy this script to remote /tmp then run over ssh
#TODO: make sure we are getting the data from the correct host (script, bd, pg)...until then, just run it on the pg host.

#MAIN

echo
echo "$(date) : $(date --utc) : SCRIPT HOST : $(hostname -f) :: BDHOST : ${BDHOST} : PGHOST : ${PGHOST}"
#echo "nproc : $(nproc) "; 
#echo
#echo "free -g : "
#free -g ; 

echo
echo $(grep -e MemTotal -e SwapTotal /proc/meminfo)

echo
df -hPT $DATABASEDIR 
#df -hPT | grep -e Filesystem -e /dev/mapper ; 

#echo
#echo Black Duck Version: 
#psql -h $PGHOST -U postgres -d bds_hub \
  #-c "SELECT version FROM st.v_hub ORDER BY installed_on DESC LIMIT 1 ; " 

echo
echo "du data/base :"
du -sh $DATABASEDIR ; 

echo
psql -qAt -h $PGHOST -U postgres -d bds_hub -c "
  SELECT version() 
; " ; 

echo
echo Black Duck Version: $(curl -k -s -L https://${BDHOST}/api/current-version | jq -r .version )

echo
psql -h $PGHOST -U postgres -d bds_hub -c "\\l+ " | grep -e Size -e bds -e alert

#echo
#psql -h $PGHOST -U postgres -d bds_hub -c "
#SELECT d.datname as Name,  pg_catalog.pg_get_userbyid(d.datdba) as Owner,
    #CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        #THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        #ELSE 'No Access'
    #END as Size
#FROM pg_catalog.pg_database d
    #order by
    #CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        #THEN pg_catalog.pg_database_size(d.datname)
        #ELSE NULL
    #END desc -- nulls first
    #LIMIT 20;"

echo
psql -h $PGHOST -U postgres -d bds_hub -c "
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_relation_size(C.oid)) AS "size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
  ORDER BY pg_relation_size(C.oid) DESC
  LIMIT 10;"

echo
for mcol in timetopersistms timetoscanms match_count num_non_dir_files num_dirs file_system_size ; 
do 
  echo -n "max $mcol : " ; 
  psql -h $PGHOST -qAt -U postgres -d bds_hub -c "SELECT MAX($mcol) FROM st.scan_scan ;"  ; 
done ; 

echo ;
psql -qAt -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT DISTINCT 'count unique scans' AS column, COUNT(id) FROM st.scan_scan ; " 
psql -qAt -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT DISTINCT 'count unique code locations' AS column, COUNT(code_location_id) FROM st.scan_scan ; "       
psql -qAt -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT DISTINCT 'count unique scan_source_id' AS column, COUNT(scan_source_id) FROM st.scan_scan ; "
psql -qAt -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT 'count unique release_ids' AS column, COUNT(*) FROM (SELECT DISTINCT project_id,release_id FROM st.version_bom) As tmp ; "
psql -qAt -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT 'count scan_component_dependency' AS column, COUNT(*) FROM st.scan_component_dependency ; "
echo
psql -h $PGHOST -U postgres -d bds_hub \
  -c "SELECT project_id, COUNT(release_id) AS proj_versions FROM st.version_bom GROUP BY project_id ORDER BY COUNT(release_id) DESC LIMIT 5 ; "
echo TODO: bloat, db_user_stats


exit
#REFERENCE
: '


[pjalajas@sup-pjalajas-hub api]$ date ; date --utc ; python3 hub-rest-api-python/examples/get_project_versions.py PN_monkeyfist5_Many_Versions | jq -C '. | length' # PJHIST number of versions for a project
Fri Oct 30 15:00:33 EDT 2020
Fri Oct 30 19:00:33 UTC 2020
111



'
