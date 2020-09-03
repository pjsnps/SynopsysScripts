#!/usb/bin/bash
#GetJsJam2.bash
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#DATE:  2020-09-01
#VERSION: 2009030002Z
#CHANGELOG:  pj done?

#PURPOSE:  Retrieve a large number of versions of a large number of open-source projects, for stress-testing Synopsys Black Duck (Hub) or other source code scanners.

#DESCRIPTION:  Note, these are popular (starred, trending), so should have much code-reuse (good for stress testing, maybe good for vuln counts, but haven't seen that yet in testing).  Uses timeout to limit size of single download or number of downloads per project.  Nice to keep these downloads as archives (vs like using git clone). 

#USAGE: First, populate input file with urls, like maybe with:
#for mfilter in stars forks updated ; do wget -O - "https://github.com/topics/javascript?o=desc&s=${mfilter}" |& tr '"<>= ' '\n' |& grep -v -e "/contribute" -e "/issues" -e "/pulls" -e "/stargazers" -e "/topics" -e "/about" -e "/site" -e "/sponsors" |& grep "^\(/[a-zA-Z0-9]\+/[a-zA-Z0-9]\+\)" | head -n 1000 |& sort -u | while read line ; do echo "https://github.com${line}" ; done >> javascript-github-projects.out ; done
#Then edit CONFIGs.
#Then run this script with, like bash GetJsJam2.bash

#TODO:
#Comment on differences between scanning archives, vs expanding them first.  
#LIMIT DOWNLOAD SIZE: If you want to use wget, here is a way to test the size of the file without downloading: wget --spider $URL 2>&1 | awk '/Length/ {print $2}' where $URL is the URL of the file you want to download, of course.  So you can condition your script based on the output. such as: { [ $(wget --spider $URL 2>&1 | awk '/Length/ {print $2}') -lt 20971520 ] && wget $URL; } || echo file to big for limiting the download size to 20 MB.  (the code is ugly, for informational purposes only).

#CONFIG
#set -x
INPUTFILE=javascript-github-projects.out
OUTPUTDIR="/home/pjalajas/dev/hub/test/projects/jsjam2/code" # no trailing slash
SLEEP=10s # no space before unit, limit curl/wget to prevent too-huge downloads.
HEADCOUNT=1000 # number of github projects to process (many gz versions per project may be downloaded)

#MAIN

#Use grep -v to remove huge or otherwise undesired files
#cat javascript-github-projects.out | \
cat "${INPUTFILE}" | \
  grep -v -e "/electron/" | \
  sort -u | \
  sort -R | \
  head -n $HEADCOUNT | \
while read url
do
 
  echo
  echo processing $url # like https://github.com/1j01/jspaint

  mtail=$(echo $url | cut -d/ -f4,5)
  #echo $mtail # like 1j01/jspaint
  #https://github.com/1j01/jspaint


  #first, get the master zip; that covers projects that have no releases
  #https://codeload.github.com/1j01/jspaint/zip/master/jspaint-master.zip
  timeout 10s curl -k -s -C - --create-dirs -o ${OUTPUTDIR}/github.com/${mtail}/zip/master/master.zip "https://codeload.github.com/${mtail}/zip/master" # no trailing slashes, downloads zip

  #second, get a page of releases .zip and .gz file.
  #No need to limit project archives from a single project because of release download page pagination limits it to about 10 recent versions.
  timeout 60s wget --directory-prefix=${OUTPUTDIR} --no-verbose --mirror --no-parent --continue --accept gz "${url}/releases" # can't no-clobber

  echo
  echo sleeping $SLEEP
  echo
  #give it a rest...try to avoid getting blocked
  sleep $SLEEP 

done |& while read line ; do echo "$(date --utc +%Y%m%dT%H:%M:%SZ\ %a) : $line" ; done


exit

#REFERENCE

Status update:
[pjalajas@sup-pjalajas-hub test]$ date ; date --utc ; hostname -f ; pwd ; whoamin ; find projects/jsjam2/code/github.com/ -type f | wc -l
Wed Sep  2 20:01:04 EDT 2020
Thu Sep  3 00:01:04 UTC 2020
sup-pjalajas-hub.dc1.lan
/home/pjalajas/Documents/dev/hub/test
-bash: whoamin: command not found
856
[pjalajas@sup-pjalajas-hub test]$ du -sh projects/jsjam2/code/github.com/ 
21G     projects/jsjam2/code/github.com/
