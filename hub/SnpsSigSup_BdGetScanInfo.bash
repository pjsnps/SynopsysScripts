#!/usr/bin/bash
#SCRIPT: hub/SnpsSigSup_BdGetScanInfo.bash 
#DATE: Fri Jan 15 04:16:24 UTC 2021
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2101150517Z
#GREPVCKSUM: TODO 
#CHANGELOG: add second pass to find more UUIDs associated with this project and scan

#PURPOSE: Gets UUIDs for Synopsys Black Duck (Hub) scans (scan, code location, ...so far) from containers (not downloaded .zip, yet).  
#Use these UUIDs to troubleshoot scan fails.
#A work in progress...

#USAGE: #1. TODO
#USAGE: #2. TODO



#
#CONFIG
#
  #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
  #Unknown-2021-01-13T04:50:09.873343Z[GMT]   https://sup-pjalajas-2.dc1.lan/api/codelocations/b0a2079d-fa89-4b0f-a147-7a30c666a619
export SINCE="2021-01-12T23:00:00"  # local or utc?
export UNTIL="2021-01-13T12:00:00"
export TEST_UUID="b0a2079d-fa89-4b0f-a147-7a30c666a619"
export PROJECT_NAME="GH-APPSEC-maven"

#2021-01-14 01:49:48 ERROR [main] --- Detect run failed: It was not possible to verify the code locations were added to the BOM within the timeout (1200s) provided.

#
#FUNCTIONS

f_prep_uuids() {
  #input string of stack of UUIDs, output grep PATTERN
  mstrings="$(echo -e "$PROJECT_NAME\n$myUUIDS")"
  mpipedstrings="$(echo -n $mstrings | tr ' \n' '|')" # need -n in echo to prevent trailing pipe
  #echo "($mpipeduuids)"
  export PATTERN="($mpipeduuids)"
}
export -f f_prep_uuids



f_get_scaninfo() {
  #input project name, output first pass of UUIDs from log lines containing project name
  #GH-APPSEC-maven GH-APPSEC-maven-master    maven/bom     Doc/scan 94bf0757-6fc8-4c97-84fb-11b7b192834b     CL: 60f5d7e0-60b3-4c75-9593-d9108b65f2d7
  #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
  docker container logs --details --since "$SINCE" --until "$UNTIL" $1 |& \
  grep -e "${PROJECT_NAME}" -e "${TEST_UUID}" | \
  egrep '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{8}' -o | \
  grep -v -e "00000000-0000-0000" 
  #can't put sort -u here because parallel threads will produce duplicates later
}
export -f f_get_scaninfo



f_get_more_uuids() {
  #input scan-related UUIDs from first pass, output more scan-related UUIDs by grepping the logs for the first batch of UUIDs (that were only found by project name).
  #GH-APPSEC-maven GH-APPSEC-maven-master    maven/bom     Doc/scan 94bf0757-6fc8-4c97-84fb-11b7b192834b     CL: 60f5d7e0-60b3-4c75-9593-d9108b65f2d7
  #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
  docker container logs --details --since "$SINCE" --until "$UNTIL" $1 |& \
  grep -e "${PATTERN}" | \
  egrep '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{8}' -o | \
  grep -v -e "00000000-0000-0000" 
  #can't put sort -u here because parallel threads will produce duplicates later
}
export -f f_get_more_uuids


f_first_pass() {
docker ps | \
grep -e scan -e jobrunner -e ".*" | \
cut -d' ' -f1 | \
parallel f_get_scaninfo | \
sort -u 
}
export -f f_first_pass



f_second_pass() {
docker ps | \
grep -e scan -e jobrunner -e ".*" | \
cut -d' ' -f1 | \
parallel f_get_more_uuids | \
sort -u 
}
export -f f_second_pass


#
#MAIN
#


export FIRST_UUIDS="$(f_first_pass)"
echo "$FIRST_UUIDS"
#f_second_pass



exit



#REFERENCE

second pass picks up too many UUIDs...or not?
[pjalajas@sup-pjalajas-2 SynopsysScripts]$ bash ./hub/SnpsSigSup_BdGetScanInfo.bash | wc -l
1286

[pjalajas@sup-pjalajas-2 SynopsysScripts]$ bash ./hub/SnpsSigSup_BdGetScanInfo.bash
18e467a8-eda7-440d-8394-3d6ff0ac
60f5d7e0-60b3-4c75-9593-d9108b65
6b458a8b-5d0e-4c59-a360-132893bf
94bf0757-6fc8-4c97-84fb-11b7b192
c6baad86-94e3-41db-9098-798288ac
                                                                                         
[pjalajas@sup-pjalajas-2 SynopsysScripts]$ bash ./hub/SnpsSigSup_BdGetScanInfo.bash
00000000-0000-0000-0001-00000000
00000000-0000-0000-0001-00000000
18e467a8-eda7-440d-8394-3d6ff0ac
18e467a8-eda7-440d-8394-3d6ff0ac
60f5d7e0-60b3-4c75-9593-d9108b65
60f5d7e0-60b3-4c75-9593-d9108b65
6b458a8b-5d0e-4c59-a360-132893bf
6b458a8b-5d0e-4c59-a360-132893bf
6b458a8b-5d0e-4c59-a360-132893bf
6b458a8b-5d0e-4c59-a360-132893bf
6b458a8b-5d0e-4c59-a360-132893bf
6b458a8b-5d0e-4c59-a360-132893bf
94bf0757-6fc8-4c97-84fb-11b7b192
94bf0757-6fc8-4c97-84fb-11b7b192
94bf0757-6fc8-4c97-84fb-11b7b192
94bf0757-6fc8-4c97-84fb-11b7b192
94bf0757-6fc8-4c97-84fb-11b7b192
94bf0757-6fc8-4c97-84fb-11b7b192
c6baad86-94e3-41db-9098-798288ac


pkg mgr scan  scanType=BDIO
2021-01-14 06:29:29,444Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [94bf0757-6fc8-4c97-84fb-11b7b192834b] is now associated with scan "GH-APPSEC-maven-master maven/bom" [94bf0757-6fc8-4c97-84fb-11b7b192834b] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]

 2021-01-14 06:29:32,756Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=94bf0757-6fc8-4c97-84fb-11b7b192834b, codeLocationId=60f5d7e0-60b3-4c75-9593-d9108b65f2d7, scanType=BDIO, scannerVersion=<unspecified>, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master maven/bom, hostName=<unknown host>, ownerEntityKeyToken=LD#94bf0757-6fc8-4c97-84fb-11b7b192834b, baseDir=/, createdOn=2021-01-14T06:29:28.799Z, lastModifiedOn=2021-01-14T06:29:32.726Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=0, numNonDirFiles=0, status=MATCHING, fileSystemSize=0, scanSourceType=LD, scanSourceId=94bf0757-6fc8-4c97-84fb-11b7b192834b, timeLastModified=1610605772726, timeToPersistMs=48, scanTime=1610605768799, bomImportComponentAuditEventUrl=/internal/bom-import/component-audit-events/94bf0757-6fc8-4c97-84fb-11b7b192834b}

 2021-01-14 06:29:32,757Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom

 2021-01-14 06:29:32,772Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom


sig scan  scanType=FS
 2021-01-14 06:29:34,898Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [6b458a8b-5d0e-4c59-a360-132893bf2641] is now associated with scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641] in code location [18e467a8-eda7-440d-8394-3d6ff0aca053]

 2021-01-14 06:29:42,392Z[GMT] [scan-upload-0] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [c6baad86-94e3-41db-9098-798288ace648] corresponds to an existing scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641]

 2021-01-14 06:29:58,915Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=6b458a8b-5d0e-4c59-a360-132893bf2641, codeLocationId=18e467a8-eda7-440d-8394-3d6ff0aca053, scanType=FS, scannerVersion=2020.12.0, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master scan, hostName=sup-pjalajas-hub.dc1.lan, ownerEntityKeyToken=SN#6b458a8b-5d0e-4c59-a360-132893bf2641, baseDir=/home/pjalajas/Documents/dev/hub/test/projects/cust/s1/scotiabank_test/maven, createdOn=2021-01-14T06:29:34.232Z, lastModifiedOn=2021-01-14T06:29:58.818Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=1721, numNonDirFiles=3199, status=MATCHING, fileSystemSize=8489114, scanSourceType=SN, scanSourceId=6b458a8b-5d0e-4c59-a360-132893bf2641, timeLastModified=1610605798818, timeToPersistMs=2866, scanTime=1610605774232}

