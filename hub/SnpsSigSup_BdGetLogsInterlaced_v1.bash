#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetLogsInterlaced_v1.bash 
#DATE: Thu Oct 15 18:31:03 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2101150315Z
#GREPVCKSUM: TODO 

#PURPOSE: Gets Synopsys Black Duck (Hub) logs from containers (not downloaded .zip, yet), interlaced by timestamp. A work in progress...

#USAGE: #1. TODO
#USAGE: #2. TODO

#NOTES: Takes a few seconds to load because of pipes.  Uses cut -c1-2000 to suppress log line length craziness.  




#TODO: put container id and/or name in output line after timestamp.




#
#CONFIG
#

#2021-01-14 01:49:48 ERROR [main] --- Detect run failed: It was not possible to verify the code locations were added to the BOM within the timeout (1200s) provided.
export DATETIMEFRAG="2021-01-14 06:49"   # logs frequently in GMT


export PROJECT_NAME="GH-APPSEC-maven"
#[pjalajas@sup-pjalajas-2 SynopsysScripts]$ bash ./hub/SnpsSigSup_BdGetScanInfo.bash
#export myUUIDS="18e467a8-eda7-440d-8394-3d6ff0ac
#60f5d7e0-60b3-4c75-9593-d9108b65
#6b458a8b-5d0e-4c59-a360-132893bf
#94bf0757-6fc8-4c97-84fb-11b7b192
#c6baad86-94e3-41db-9098-798288ac"
export myUUIDS=

export myUUIDS="$(bash ./hub/SnpsSigSup_BdGetScanInfo.bash)"

#docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
export SINCE="2021-01-14T01:00:00"
export UNTIL="2021-01-14T02:00:00"

#
#FUNCTIONS
f_prep_uuids() {
  mpipeduuids="$(echo -n $myUUIDS | tr ' \n' '|')" # need -n in echo to prevent trailing pipe
  #echo "($mpipeduuids)"
  export PATTERN="($mpipeduuids)"
}
export -f f_prep_uuids

f_grep_logs() {
  #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& grep -i -e "${DATETIMEFRAG}" | cut -c1-2000 ; 
  #Odd, but enter local (EST) time here, docker returns logs corrected for GMT.
  docker container logs --details --since "$SINCE" --until "$UNTIL" $1 |& \
    grep -E -e "$PROJECT_NAME" -e "$PATTERN"
    cut -c1-2000  
}
export -f f_grep_logs

f_get_scaninfo() {
  #MOVED TO ./hub/SnpsSigSup_BdGetScanInfo.bash
  #GH-APPSEC-maven GH-APPSEC-maven-master    maven/bom     Doc/scan 94bf0757-6fc8-4c97-84fb-11b7b192834b     CL: 60f5d7e0-60b3-4c75-9593-d9108b65f2d7
  docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
  grep -e GH-APPSEC-maven -e "$mpattern"
}
export -f f_get_scaninfo

#
#MAIN
#

f_prep_uuids  # creates pattern to grep

echo
echo -e "grepping all running container logs for\n$PROJECT_NAME :: $PATTERN"
echo
docker ps | \
grep -v CONTAINER | \
grep -e scan -e jobrunner -e ".*" | \
cut -d' ' -f1 | \
parallel f_grep_logs | \
sort --stable --key=1,2 

#head -n 200000 | \


exit
#REFERENCE

[pjalajas@sup-pjalajas-2 SynopsysScripts]$ bash ./hub/SnpsSigSup_BdGetScanInfo.bash                                                                                           
18e467a8-eda7-440d-8394-3d6ff0ac
60f5d7e0-60b3-4c75-9593-d9108b65
6b458a8b-5d0e-4c59-a360-132893bf
94bf0757-6fc8-4c97-84fb-11b7b192
c6baad86-94e3-41db-9098-798288ac


parallel f_grep_logs | \


pkg mgr scan  scanType=BDIO
2021-01-14 06:29:29,444Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [94bf0757-6fc8-4c97-84fb-11b7b192834b] is now associated with scan "GH-APPSEC-maven-master maven/bom" [94bf0757-6fc8-4c97-84fb-11b7b192834b] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]

 2021-01-14 06:29:32,756Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=94bf0757-6fc8-4c97-84fb-11b7b192834b, codeLocationId=60f5d7e0-60b3-4c75-9593-d9108b65f2d7, scanType=BDIO, scannerVersion=<unspecified>, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master maven/bom, hostName=<unknown host>, ownerEntityKeyToken=LD#94bf0757-6fc8-4c97-84fb-11b7b192834b, baseDir=/, createdOn=2021-01-14T06:29:28.799Z, lastModifiedOn=2021-01-14T06:29:32.726Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=0, numNonDirFiles=0, status=MATCHING, fileSystemSize=0, scanSourceType=LD, scanSourceId=94bf0757-6fc8-4c97-84fb-11b7b192834b, timeLastModified=1610605772726, timeToPersistMs=48, scanTime=1610605768799, bomImportComponentAuditEventUrl=/internal/bom-import/component-audit-events/94bf0757-6fc8-4c97-84fb-11b7b192834b}

 2021-01-14 06:29:32,757Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom

 2021-01-14 06:29:32,772Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom


sig scan  scanType=FS
 2021-01-14 06:29:34,898Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [6b458a8b-5d0e-4c59-a360-132893bf2641] is now associated with scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641] in code location [18e467a8-eda7-440d-8394-3d6ff0aca053]

 2021-01-14 06:29:42,392Z[GMT] [scan-upload-0] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [c6baad86-94e3-41db-9098-798288ace648] corresponds to an existing scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641]

 2021-01-14 06:29:58,915Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=6b458a8b-5d0e-4c59-a360-132893bf2641, codeLocationId=18e467a8-eda7-440d-8394-3d6ff0aca053, scanType=FS, scannerVersion=2020.12.0, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master scan, hostName=sup-pjalajas-hub.dc1.lan, ownerEntityKeyToken=SN#6b458a8b-5d0e-4c59-a360-132893bf2641, baseDir=/home/pjalajas/Documents/dev/hub/test/projects/cust/s1/scotiabank_test/maven, createdOn=2021-01-14T06:29:34.232Z, lastModifiedOn=2021-01-14T06:29:58.818Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=1721, numNonDirFiles=3199, status=MATCHING, fileSystemSize=8489114, scanSourceType=SN, scanSourceId=6b458a8b-5d0e-4c59-a360-132893bf2641, timeLastModified=1610605798818, timeToPersistMs=2866, scanTime=1610605774232}



: '
Usage:  docker container logs [OPTIONS] CONTAINER

Fetch the logs of a container

Options:
      --details        Show extra details provided to logs
  -f, --follow         Follow log output
      --since string   Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
      --tail string    Number of lines to show from the end of the logs (default "all")
  -t, --timestamps     Show timestamps
      --until string   Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
'

[pjalajas@sup-pjalajas-hub hub]$ docker ps -q | while read mcontainerid ; do docker ps | grep $mcontainerid ; docker container logs $mcontainerid |& grep -i -e "10-15 16:.*Binding .*\(_LINKED. to parameter:\|adjustedValue\=\)" ; 
echo ; done |& sort --stable --key=1,2 | less -inRF                                                                                                                                                                                  
2020-10-15 16:30:58,540Z[GMT] [https-jsse-nio-8443-exec-3] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:31:06,330Z[GMT] [https-jsse-nio-8443-exec-3] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [2]
2020-10-15 16:31:30,361Z[GMT] [https-jsse-nio-8443-exec-8] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:42:11,313Z[GMT] [https-jsse-nio-8443-exec-7] TRACE org.hibernate.type.EnumType - Binding [STATICALLY_LINKED] to parameter: [15]
2020-10-15 16:42:18,580Z[GMT] [https-jsse-nio-8443-exec-7] TRACE org.hibernate.type.EnumType - Binding [STATICALLY_LINKED] to parameter: [2]
2020-10-15 16:42:32,695Z[GMT] [https-jsse-nio-8443-exec-5] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:42:40,962Z[GMT] [https-jsse-nio-8443-exec-5] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [2]
