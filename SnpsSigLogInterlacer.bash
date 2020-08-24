#!/usr/bin/bash

#SCRIPT:     SnpsSigLogInterlacer.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-08-13          # move from command line hacks to (more) formal script 
#VERSION:    2008162108Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: ____ # :! grep -v grepvcksum <script> | cksum
#CHANGELOG:  2008162108Z add some thoughts 

#PURPOSE:    Intended to allow syncing up Synopsys Black Duck (FKA Hub) logs from Administration, System Settings, System Logs, by timestamp, so you  can see what is happening across all containers at the same point in time. 

#USAGE:  Download System Logs .zip.  Unzip into an empty directory.  Change directory to top of that directory.  find . |& grep filter names/ext | xargs -I'%' cat -A '%' |& <this script> # TODO ___
#USAGE:  Edit CONFIGs below. 
#USAGE:  [pjalajas@sup-pjalajas-hub SynopsysScripts]$ find /home/pjalajas/Documents/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257 -maxdepth 5 -type f |& grep -i -e "\.log$" -e "\.txt$" |& grep -e "2020-08-13" |& xargs -I'%' cat -A '%' |& grep -e "2020-08" -e "2020/08" |& ./SnpsSigLogInterlacer.bash |& less -inRF
#USAGE:  OR: run docker container logs |& TODO__   |& <this script>
#USAGE: ____   

#TESTING: [pjalajas@sup-pjalajas-hub SynopsysScripts]$ for minput in "start 2020-08-13T19:54:11.119Z end" "start #2020-08-13 00:00:01,846Z[GMT] end" "start 2020/08/06 00:03:25 end" "start 13/Aug/2020:00:01:37 +0000 end" "start 2020-08-12T20:01:37Z end" ; do echo "$minput" | tee /dev/tty | ./SnpsSigLogInterlacer.bash ; echo ;  done

#DESCRIPTION:  Searches for date/timestamps (with timezones if present), reformats to standard format, and prepends output line with that reformatted timestamp, keeping the original timestamp in the log line where it was.  
#  Can deal with these timestamp formats so far:
#              13/Aug/2020:00:01:37 +0000
#              2020/08/06 00:03:25
#              2020-08-06 00:00:01,521Z[GMT]
#              2020-08-12T20:01:37Z
#              2020-08-13T19:54:11.119Z
#TODO: ____
#2008141347Z  Hope to deal with timestamps formats like this soon enough:
#     2020-08-14 00:02:46,546  protex logs
#     Apr 4, 2020
#     "13-08-2020 00:00:00"
#      ?:  A /var/cache/nginx/proxy_temp/8/13 = month/day? 
#
#Does not use sed /g, so only processes first timestamp-looking string in each log line. 
#Removes blank lines.
#___

#REQUIRES:   ____
#RECOMMENDED: ____

#TODO: 
#This is harder than it looks. First, create a log identifier script that recognizes our list of log formats.
#Figure out what kind of /our/ log it is (can only handle ours), then process that. For example, a garbage collection log usually needs to have the "seconds since jvm start""timestamp converted to UTC by looking at some starting timestamp somehow.
#Change this to prepend our processed timestamps with "li:" so we can easily track what we created.  If a line doesn't start with "^li:20", we need to calculate and prepend an li: timestamp, preferably from elsewhere in that line, else copy that immediately above, else copy that from somewhere below.  It could be that for those lines with no tiemstatmps at the top of a file are processed last for logical convenience  (start with the first line with a timestamp we understand, prepare our "li:2..." timestamp, repeat for next line; at EOF, start at top of file, if no timestamp, find first "li:2" and copy that found "li:2" to all timestamp-less lines at the top of the file.  
#Create a script that prepends, to lines with no datestamp, the datestamp of the most recent datestamp above (or below if none above), with a "circa" "-ca?" appended to the end of the estimated timestamp. 
#Plan to edit all log4j.properties for consisent date formats and log-line layouts.  
#Plan to create dev containers in my own image. 
#Maybe create a maintenance container for this and other tools. 
#Process each log file separately?  Like gc log may need processing to convert seconds-from-jvm-start to utc. 
#Address timezones...won't be easy, will have to make assumptions. Appened ? to date if no TZ indicated
#Address can't deal with lines without timestamps, like java traces.  Ignore for now.  Maybe can wrap up such lines and append to last prior line with timestamp?(!)
#    research log4j mods to force prepending timestamp to ALL lines. 

#CONFIG
mcut=1000 # max line width before date parsing (if date is after this number, it will not be converted)
#TODO: __ move/add some CONFIGs to command line option line ${1:-1000} or whatever the right way to set a default is

#FUNCTIONS
#none so far

#INIT
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
date ; date --utc ; hostname -f ; pwd ; whoami ; 
echo "TODO___: look for tz in input line; if not found, presume UTC/Z, but append ? after date near bottom"

#MAIN

while read line ; 
do
  #TODO:  to make sed non greedy, so that only the first date in each log line is used, maybe try to find line char pos for each datetime format?  Or awk? 
  echo "input line :: $line"
#  Process in this order (subject to change, but keep this in same order as grep and sed list below for easier comparison):
#              13/Aug/2020:00:01:37 +0000
#              2020/08/06 00:03:25
#              2020-08-06 00:00:01,521Z[GMT]
#              2020-08-12T20:01:37Z
#              2020-08-13T19:54:11.119Z
  mworkingdate="$(echo "$line" |& \
    sed -r \
        -e 's#(^.*)([0-3][0-9])/([A-Z][a-z]{2})/(20[0-9]{2}):([0-2][0-9]:[0-5][0-9]:[0-5][0-9])( \+0000)(.*$)#\3 \2 \4 \5 UTC#' \
        -e 's#(^.*)(20[0-9]{2})/([0-1][0-9])/([0-3][0-9]) ([0-2][0-9]:[0-5][0-9]:[0-5][0-9])(.*$)#\2-\3-\4 \5.000 UTC#' \
        -e 's#(^.*)(20[0-9]{2}-[0-1][0-9]-[0-3][0-9]) ([0-2][0-9]:[0-5][0-9]:[0-5][0-9]),([0-9]{1,9})(Z)(\[GMT\])(.*$)#\2 \3.\4 UTC#' \
        -e 's#(^.*)(20[0-9]{2}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9])(Z)(.*$)#\2 UTC#' \
        -e 's#(^.*)(20[0-9]{2}-[0-1][0-9]-[0-3][0-9])T([0-2][0-9]:[0-5][0-9]:[0-5][0-9]).([0-9]{1,9})(Z)(.*$)#\2 \3.\4 UTC#' \
        -e 's#(^.*)(20[0-9]{2}-[0-1][0-9]-[0-3][0-9]) ([0-2][0-9]:[0-5][0-9]:[0-5][0-9]),([0-9]{1,9})(.*$)#\2 \3.\4 UTC#' \
    )" 
  #TODO: __ append ? if no tz indicated in input
  #mdate="$(echo "${mworkingdate}" | xargs -I'_' date --utc +%Y-%m-%dT%H:%M:%S.%NZ%a -d "_")" # not reversible date format
  mdate="$(echo "${mworkingdate}" | xargs -I'_' date --utc +%Y-%m-%dT%H:%M:%S.%NZ\ %a -d "_")" # reversible date format, can pipe back into date -d if needed
  #echo "$mdate :: $mworkingdate :: $line" #TESTING 
  # working on 2020-08-14 00:02:46,546
  echo "$mdate :: $line" #PRODUCTION
done < <(cat |& \
    grep \
        -e "We can process only these kinds of lines, so far:" \
        -e "[0-3][0-9]/[A-Z][a-z]\{2\}/20[0-9]\{2\}:[0-2][0-9]:[0-5][0-9]:[0-5][0-9] +0000" \
        -e "[0-9]\{4\}/[0-9]\{2\}/[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}" \
        -e "20[0-9]\{2\}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]\{1,9\}Z\[GMT\]" \
        -e "20[0-9]\{2\}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.[0-9]\{1,9\}Z" \
        -e "20[0-9]\{2\}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z" \
        -e "20[0-9]\{2\}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]\{1,9\}" \
    |& \
    cut -c1-$mcut) |& \
sort -k1
#sort -t\: -k1g -k2g -k3g


exit
#REFERENCE
put notes here
        -e ".*" \
        -e 's#(^.*)(20[0-9]{2}-[0-1][0-9]-[0-3][0-9])T([0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.[0-9]\{1,9\})(Z)(.*$)#\2 \3.\4 UTC#' \
    grep \
         -e "[0-3][0-9]/[A-Z][a-z]\{2\}/20[0-9]\{2\}:[0-2][0-9]:[0-5][0-9]:[0-5][0-9] +0000" \
         -e "[0-9]\{4\}/[0-9]\{2\}/[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}" \
         -e "20[0-9]\{2\}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]\{1,9\}Z\[GMT\]" \
    |& \

grep -v "^\s*$" |&
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ find /home/pjalajas/Documents/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257 -maxdepth 5 -type f |& grep -i -e "\.log$" -e "\.txt$" |& grep -e "2020-08-13" |& xargs -I'%' head -n 100 '%' |& cat -A |& grep -e "2020-08" -e "2020/08" -e "Aug/2020" |& ./SnpsSigLogInterlacer.bash |& head | sed -re 's#(^.*)([0-3][0-9])/([A-Z][a-z]{2})/(20[0-9]{2}):([0-2][0-9]:[0-5][0-9]:[0-5][0-9]) \+0000(.*$)#\3 \2 \4 \5.000Z#' | xargs -I'_' date +%Y-%m-%dT%H:%M:%S.%NZ -d "_" 2> /dev/null
2020-08-13T23:47:29.000000000Z


  cut -c1-${mcut} |& \
  sed -re "s#(^.*)([0-9]{4})/([0-9]{2})/([0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})(.*$)#\2-\3-\4T\5.---? : \1\2/\3/\4 \5\6#" |& \
  sed -re 's#(^.*)([0-9]{2})/([A-Z][a-z]{2})/([0-9]{4}):([0-9]{2}:[0-9]{2}:[0-9]{2} \+0000)(.*$)#\3 \2 \4 \5#' | date +%Y-%m-%dT%H:%M:%SZ -d - 2> /dev/null |& \
  sed -re "s#(^.*)([0-9]{2})/([A-Z][a-z]{2})/([0-9]{r42}):([0-9]{2}:[0-9]{2}:[0-9]{2}) (+0000)(.*$)#\2-\3-\4T\5.---? : \1\2/\3/\4 \5\6#" |& \
  sed -re "s/(^.*)([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}),([0-9]{1,9}Z)(\[GMT\])(.*$)/\2T\3.\4 : \1\2 \3,\4\5\6/" |& \
  sed -re "s/junk/junk/g" 

2020-08-13T00:02:32.689Z : [f6b2263d986c] 2020-08-13 00:02:32689Z[GMT] [scan-upload-1] INFO com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Sta
rting to process the chunk 2165f2a9-ab63-4fc5-8825-4075eb202d2f in mode REPLACE$
2020-08-13T00:02:32....? : [739738e14cc0] 2020/08/13 00:02:32 [warn] 101#101: *591651 a client request body is buffered to a temporary file /var/cache/nginx/client_temp/0000001165, client: 10.255.0.2, server: localhost, request: "POST /api/bom-import HTTP/1.1", host: "blackduck.eng.customer.com"$
2020-08-13T00:02:32.841Z : [f6b2263d986c] 2020-08-13 00:02:32841Z[GMT] [scan-upload-1] INFO com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - AddRemoveEvent: Original CodeLocationId: f5b69908-af86-345d-9181-36711636ae41$


[pjalajas@sup-pjalajas-hub SynopsysScripts]$ ls -1rt |& ./SnpsSigLogInterlacer.bash



 1220  mdate=2020-08-13 ; mtime="18:2" ; find . -type f | grep -i -e "\.log$" -e "\.txt$" | xargs cat | grep -e "${mdate} ${mtime}" -e "08/13" -e "13/08" -e "8/13" -e "13/8" | grep -v -e "ignoreme's here" | sed -re "s/^.*${mdate}/${mdate}/g" -e "s/${mdate}( )(..:..:..),(...Z)/${mdate}T\2.\3/g" | cut -c1-500 | grep -v "^\s*$" | sort | less -inRF # PJHIST log interlacer


dates with slashes: 
pjalajas@pjalajas-5520:/mnt/c/Users/pjalajas/Downloads/blackduck_bds_logs-20200813T201257$ mdate=2020-08-13 ; mtime="18:2" ; find . -type f | grep -i -e "\.log$" -e "\.txt$" | xargs cat | grep -e "08/13" -e "13/08" -e "8/13" -e "13/8" | grep "/13" | grep -v "2020/08/13" # PJHIST log interlacer
A /var/cache/nginx/proxy_temp/8/13
