#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdScanProjVerLoad.bash
#AUTHOR: pjalajas@synopsys.com
#DATE:  2020-11-14
#LICENSE: SPDX Apache-2.0
#VERSION: 2011150315Z
#SUPPORT: https://community.synopsys.com/, https://www.synopsys.com/software-integrity/support.html, Software-integrity-support@synopsys.com

#PURPOSE:  Scan same source tree (sig scan and pkg mgr scan), in an assortments of 25 identical projects, split evenly among 5 bundles, each bundle having the project with 1, 3, 10, 30, and 100 versions of the project.  Should show level of deterioration of scanning as version count for the single project increases from 1 up through 3, 10, 30 and 100, but also show range of scan performance across the 5 copies of the project with 1 version, up through the 5 copies of the project with 100 versions.

#USAGE: SnpsSigSup_BdScanProjVerLoad.bash [project_name]

#CONFIG

msleep=0s # increase substantially (15m?) if scans are crashing server

#Take source dir from command line first param $1 or from DETECTSOURCEPATH set immediately above.

DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164" # small project for testing

DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea" # expanded, 6.7 GB, 21 versions, 497,293 files       [pjalajas@sup-pjalajas-hub test]$ du -sh /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ 6.7G    /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -maxdepth 1 -type d -iname "*.exp" | wc -l 21 [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -type f | wc -l 497293

#Replace with command line source path if present...
DETECTSOURCEPATHMOD="${1:-${DETECTSOURCEPATH}}" # if source path set in $1 in command line then use that, else use the one above (command line option takes precedence).

echo Printing some of source tree info... 
echo -n "src du -sh: "
du -sh $DETECTSOURCEPATHMOD
echo -n "src dir top level count: "
find "$DETECTSOURCEPATHMOD" -maxdepth 1 -type d | wc -l
echo -n "file count: "
find "$DETECTSOURCEPATHMOD" -type f | wc -l
echo "some random files in top few levels of src dir (width cut): "
find "${DETECTSOURCEPATHMOD}" -maxdepth 5 | sort -R | cut -c1-1000 | head -n 50


#MAIN

for bundle in 1 2 3 4 5 
do
  for version_count in 1 3 10 30 100 
  do
   scan_count=1
   echo before scan_count: $scan_count
   while [[ "$scan_count" != "$((version_count+1))" ]] 
   do
     echo -e bundle: $bundle"\t"goal versions this bundle: $version_count"\t"actual scans this bundle: $scan_count
     echo scan here...

       bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
         --blackduck.url='https://sup-pjalajas-2.dc1.lan' \
         --blackduck.trust.cert='true' \
         --blackduck.username='sysadmin' \
         --blackduck.password='blackduck' \
         --detect.cleanup='false' \
         --detect.project.name="PN_$(echo "${DETECTSOURCEPATHMOD}" | tr / '\n' | tail -n 1)_${bundle}_${version_count}" \
         --detect.project.version.name="PVN_${bundle}_${version_count}_${scan_count}" \
         --detect.source.path="${DETECTSOURCEPATHMOD}" \
         --detect.project.version.notes="$(echo "${DETECTSOURCEPATHMOD}")\ $(date --utc +%m%d%H%M%SZ)\ pjalajas@synopsys.com" \
         --blackduck.offline.mode='false' \
         --detect.blackduck.signature.scanner.dry.run='false' \
         --detect.detector.search.depth=200 \
         --detect.detector.search.continue=true \


     scan_count=$((scan_count+1)) # off by 1 at end, oh well
     echo sleeping $msleep ...
     sleep $msleep
   done 
   #scan done, increment counter
   echo after scan_count: $scan_count
   echo
  done 
done



exit
#REFERNCE
:'
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/" # expanded, 6.7 GB, 21 versions, 497,293 files       [pjalajas@sup-pjalajas-hub test]$ du -sh /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ 6.7G    /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -maxdepth 1 -type d -iname "*.exp" | wc -l 21 [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -type f | wc -l 497293
#Take source dir from command line first param $1 or from DETECTSOURCEPATH set immediately above.
DETECTSOURCEPATHMOD="${1:-${DETECTSOURCEPATH}}" # if source path set in $1 in command line then use that, else use the one above (command line option takes precedence).
echo Printing some of source tree to compare apples... 
find "${DETECTSOURCEPATHMOD}" | cut -c1-1000 | head -n 100

#EXPAND: 
#TODO:  this doesn't work yet, path names getting mangled by gnu parallel? 
#OPTION:  run Recursive Expander because PkgMgr scans do not open archives. 
#RECURSIVEEXPANDCMD="/home/pjalajas/dev/git/SynopsysScripts/util/SnpsSigSup_RecursiveExpander.bash"
#if [[ "$2" == "expand" ]] ; then 
  #echo
  #echo Running $RECURSIVEEXPANDCMD...
  #bash ${RECURSIVEEXPANDCMD} "${DETECTSOURCEPATHMOD}" && wait # wait for all multi-threaded expansions to finish
  #echo
  #echo Printing some of source tree after expanding... 
  #find "${DETECTSOURCEPATHMOD}" | cut -c1-1000 | head -n 100 
  #echo
  #echo Done running $RECURSIVEEXPANDCMD.
  #echo
#fi



#MAIN COMMAND, but EDIT _many_ of these options as needed for your testing.  See messy bone yard below for command line switches.

bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
    --blackduck.url='https://sup-pjalajas-hub.dc1.lan' \
    --blackduck.trust.cert='true' \
    --blackduck.username='sysadmin' \
    --blackduck.password='blackduck' \
    --detect.cleanup='false' \
\
    --detect.project.name="PN_$(echo "${DETECTSOURCEPATHMOD}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.project.version.name='PVN_$(date --utc +%m%d%H%M%SZ)' \
\
    --detect.source.path="${DETECTSOURCEPATHMOD}" \
\
    --detect.project.version.notes="$(echo "${DETECTSOURCEPATHMOD}")\ $(date --utc +%m%d%H%M%SZ)\ pjalajas@synopsys.com" \
\
    --blackduck.offline.mode='false' \
    --detect.blackduck.signature.scanner.dry.run='false' \
\
    --detect.detector.search.depth=200 \
    --detect.detector.search.continue=true \
\




'
