#!/usr/bin/bash
#SCRIPT: ./hub/SnpsSigSup_BdGrepLogs.bash
#DATE: Fri Jan 15 04:16:24 UTC 2021
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2101160304Z
#GREPVCKSUM: TODO 
#CHANGELOG:  minor cleanup before committing

#PURPOSE: Input lists of search term strings, output matching Synopsys Black Duck (Hub) container log records scans (scan, jobrunner, etc).  
#A work in progress, works for me; suggestions welcome.

#USAGE: Edit CONFIGs, and f_getContainerIDs container grep, then: bash ./hub/SnpsSigSup_BdGrepLogs.bash |& less -inRF

#NOTE: Lines need all same date stamp format for sorting.  Lines with no datestamp are not included...yet (working on it).   

#
#CONFIG
#

  #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
  #Unknown-2021-01-13T04:50:09.873343Z[GMT]   https://sup-pjalajas-2.dc1.lan/api/codelocations/b0a2079d-fa89-4b0f-a147-7a30c666a619
  #2021-01-14 01:49:48 ERROR [main] --- Detect run failed: It was not possible to verify the code locations were added to the BOM within the timeout (1200s) provided.
export CUT_CHARS=2000 # to keep crazy long lines from flooding the output, used in echo $line | cut -c1-$CUT_CHARS
export SINCE="2021-01-12T06:50:00"  # local time (not UTC) Date range of interest in docker container logs
export UNTIL="2021-01-15T07:50:00"

#see "mstrings=" below for how these are echo'd together separated by newline.
export TEST_UUID="b0a2079d-fa89-4b0f-a147-7a30c666a619"
export MY_UUIDS=""  # line sep list
#export PROJECT_NAME="GH-APPSEC-maven"
export PROJECT_NAME="Unknown-2021-01-13"
export PROJECT_NAME="GH-APPSEC-maven\nUnknown-2021-01-13"





#
#FUNCTIONS
#

f_stringsToPattern() {
  #input stack of strings, output greppable (-E) PATTERN like "(string1|string2...)"
  mstrings="$(echo -e "${TEST_UUID}\n${MY_UUIDS}\n${PROJECT_NAME}")"
  mpipedstrings="$(echo -n $mstrings | tr ' \n' '|')" # need -n in echo to prevent trailing pipe
  export PATTERN="($mpipedstrings)"
}
export -f f_stringsToPattern


f_grepLogs() {
  #grep a single container log for PATTERN
  echo
  #lost in sorting:  echo grepping logs from container ID $1 from $SINCE$(date +%Z) until $UNTIL$(date +%Z) for "$PATTERN"
  #docker container logs --details --since "2021-01-15T06:50:00" --until "2021-01-15T07:50:00" $1 |& \
  docker container logs --details --since "$SINCE" --until "$UNTIL" $1 |& \
    grep -E -e "${PATTERN}" | \
    while read line ; do
      echo "$(echo "$line" | cut -c1-$CUT_CHARS) :: LOG FROM $1 $(docker ps | grep $1 | cut -d\/ -f2 | cut -d\: -f1 | sed -re 's/blackduck-//g')"
    done
  #can't put sort -u here because parallel threads will produce duplicates later
  echo
}
export -f f_grepLogs


f_getContainerIDs() {
#use ps instead of ps -q so can filter by container name 
docker ps | \
grep -e scan -e jobrunner -e ".*" | \
grep -v CONTAINER | \
cut -d' ' -f1
}
export -f f_getContainerIDs




#
#MAIN
#


f_stringsToPattern # input CONFIG strings, output $PATTERN for grepping logs
echo -e "grepping container logs from $SINCE$(date +%z\(%Z\)) until $UNTIL$(date +%z\(%Z\)) for\n$PATTERN"
echo
# grep container ID logs in parallel for PATTERN during SINCE to UNTIL
f_getContainerIDs | parallel f_grepLogs | \
  sort -u # presume all lines start with same date format; TODO deal with lines with no timestamps


exit
#
#REFERENCE
#


#GH-APPSEC-maven GH-APPSEC-maven-master    maven/bom     Doc/scan 94bf0757-6fc8-4c97-84fb-11b7b192834b     CL: 60f5d7e0-60b3-4c75-9593-d9108b65f2d7
    #docker container logs --details --since "2021-01-14T01:00:00" --until "2021-01-14T02:00:00" $1 |& \
    #2021-01-15 06:50:03,428Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [6e0db4a5-8c6a-493a-936e-f721a693b30e] is now associated with scan "GH-APPSEC-maven-master maven/bom" [6e0db4a5-8c6a-493a-936e-f721a693b30e] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]
    #2021-01-15 07:49:46,388Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [42b86674-d2a0-4fbb-97f9-cdd5a3117965] is now associated with scan "GH-APPSEC-maven-master maven/bom" [42b86674-d2a0-4fbb-97f9-cdd5a3117965] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]


grep logs from container ID 7daec71212bb for (b0a2079d-fa89-4b0f-a147-7a30c666a619|GH-APPSEC-maven|Unknown-2021-01-13)
 2021-01-15 11:50:02,787Z[GMT] [scan-upload-1] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [d7ca49af-50c0-4d72-9c77-60d1a31254f3] corresponds to an existing scan "GH-APPSEC-maven-master scan" [d6d81f4d-9f80-4a05-91ce-daeb8d7cd446]
grep logs from container ID cbccd56963a1 for (b0a2079d-fa89-4b0f-a147-7a30c666a619|GH-APPSEC-maven|Unknown-2021-01-13)
 2021-01-15 12:49:45,423Z[GMT] [scan-upload-1] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [71dc7639-869c-417c-acec-48f8fc1b9d67] is now associated with scan "GH-APPSEC-maven-master maven/bom" [71dc7639-869c-417c-acec-48f8fc1b9d67] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]
 2021-01-15 12:49:51,177Z[GMT] [scan-upload-1] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [f8e42b35-bc16-428a-b068-6f494ec89142] is now associated with scan "GH-APPSEC-maven-master scan" [f8e42b35-bc16-428a-b068-6f494ec89142] in code location [18e467a8-eda7-440d-8394-3d6ff0aca053]
 2021-01-15 12:49:58,875Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [7c475a47-d086-4821-b49a-d2c560fa9b43] corresponds to an existing scan "GH-APPSEC-maven-master scan" [f8e42b35-bc16-428a-b068-6f494ec89142]


pkg mgr scan  scanType=BDIO
2021-01-14 06:29:29,444Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [94bf0757-6fc8-4c97-84fb-11b7b192834b] is now associated with scan "GH-APPSEC-maven-master maven/bom" [94bf0757-6fc8-4c97-84fb-11b7b192834b] in code location [60f5d7e0-60b3-4c75-9593-d9108b65f2d7]

 2021-01-14 06:29:32,756Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=94bf0757-6fc8-4c97-84fb-11b7b192834b, codeLocationId=60f5d7e0-60b3-4c75-9593-d9108b65f2d7, scanType=BDIO, scannerVersion=<unspecified>, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master maven/bom, hostName=<unknown host>, ownerEntityKeyToken=LD#94bf0757-6fc8-4c97-84fb-11b7b192834b, baseDir=/, createdOn=2021-01-14T06:29:28.799Z, lastModifiedOn=2021-01-14T06:29:32.726Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=0, numNonDirFiles=0, status=MATCHING, fileSystemSize=0, scanSourceType=LD, scanSourceId=94bf0757-6fc8-4c97-84fb-11b7b192834b, timeLastModified=1610605772726, timeToPersistMs=48, scanTime=1610605768799, bomImportComponentAuditEventUrl=/internal/bom-import/component-audit-events/94bf0757-6fc8-4c97-84fb-11b7b192834b}

 2021-01-14 06:29:32,757Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom

 2021-01-14 06:29:32,772Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.PureConcurrentMatchAlgorithm [] []: Calling match service for sig version: 7.0.0 using CE: GH-APPSEC-maven-master maven/bom


sig scan  scanType=FS
 2021-01-14 06:29:34,898Z[GMT] [scan-upload-2] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [6b458a8b-5d0e-4c59-a360-132893bf2641] is now associated with scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641] in code location [18e467a8-eda7-440d-8394-3d6ff0aca053]

 2021-01-14 06:29:42,392Z[GMT] [scan-upload-0] INFO  com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Document [c6baad86-94e3-41db-9098-798288ace648] corresponds to an existing scan "GH-APPSEC-maven-master scan" [6b458a8b-5d0e-4c59-a360-132893bf2641]

 2021-01-14 06:29:58,915Z[GMT] [jobRunner-2] INFO  com.blackducksoftware.scan.scanmatch.impl.ScanMatchApi [] []: Scan found for scan match process: Scan{id=6b458a8b-5d0e-4c59-a360-132893bf2641, codeLocationId=18e467a8-eda7-440d-8394-3d6ff0aca053, scanType=FS, scannerVersion=2020.12.0, serverVersion=2020.12.0, signatureVersion=7.0.0, name=GH-APPSEC-maven-master scan, hostName=sup-pjalajas-hub.dc1.lan, ownerEntityKeyToken=SN#6b458a8b-5d0e-4c59-a360-132893bf2641, baseDir=/home/pjalajas/Documents/dev/hub/test/projects/cust/s1/scotiabank_test/maven, createdOn=2021-01-14T06:29:34.232Z, lastModifiedOn=2021-01-14T06:29:58.818Z, timeToScan=0, createdByUserId=00000000-0000-0000-0001-000000000001, matchCount=0, matchDataPresent=true, numDirs=1721, numNonDirFiles=3199, status=MATCHING, fileSystemSize=8489114, scanSourceType=SN, scanSourceId=6b458a8b-5d0e-4c59-a360-132893bf2641, timeLastModified=1610605798818, timeToPersistMs=2866, scanTime=1610605774232}

