#!/usr/bin/env bash
shopt -s extglob
#set +x

#SCRIPT:     SnpsSigSup_LogProcessor.bash (was SnpsSigLogProcessor.bash, which was SnpsSigLogIdentifier.bash)
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-08-23
#VERSION:    :r ! date -u +\%y\%m\%d\%H\%MZ : 2009121317Z
#GREPVCKSUM: ____ # :! grep -v grepvcksum <script> | cksum
#CHANGELOG: 2009121317Z pj rename, try to make progress

#PURPOSE:    Plan is still evolving, probably different from what is stated herein.  Identify what kind of log we are processing, and process it.  "Process" meaning, rationalize or normalize, to make them more consistent and complete.  To be used in pipeline before loginterlacer.bash; keep loginterlacing.bash just for the interlacing task, not pre-preprocessing which is what this script does..

#USAGE: See REFERENCE section at bottom of this script. Currently works only on logs downloaded from Black Duck (Hub) Administration, System Settings, System Logs; download and extract from that .zip the logs of interest.   Accepts a (optional?) log path/filename in position one.  Need path to hint at log line date format by parsing container name from path.  Outputs formatted hourly log files to ${mdirname}/${mbasename}.H${mhour}.log. Ingesting of separate log files into this scriptcan be multithreaded like with parallel or xargs, but not /within/ processing each ingested log file (else the output lines will be out of order; not fatal, but the output hourly log files will need to be sorted afterwards.)
#USAGE: #mdate=2020-09-02 ; find /home/pjalajas/Downloads/hub-webserver_bds_logs-20200904T011849/hub-jobrunner/app-log -iwholename "*/*/*/${mdate}.log" | grep -e "app-log" -e "access-log" | grep -v "documentation" | xargs -I'{}' -d '\n' -P $(nproc) ./SnpsSigSup_LogProcessor.bash '{}'    

#DISCUSSION:  Need to deal with log files of day X in EDT, but after processing last few records late in day X EDT are in early day Y UTC/Z--which output date-stamped log file (2020-09-02HxxZ.log) should they go into? Guessing, simply just back into the same "wrong" dated file from where it came, but not sure.         
#If container root log level set to ALL, log file as downloaded from Black Duck web ui can be very large. I think that log file, and I think the "docker container logs" output, is from the log4j2.properties console appender, vs the file appender; so, if true, and if we configure that console appender to rotate at a reasonable size, not sure if that web ui download would download all those split rotated logs or just the latest; TODO: test that; else, may need to morph this thing to grab smaller rotated logs from docker container via command line.... Maybe need to split huge logs instead of into hours *-HhhZ.log files, maybe need to split into *-HnnMmZ.log (10-minutely logs) (easy to cat back together as needed).  

#DEVPLAN:  
# Done?:  Prepend last-known timestamp to lines with no timestamp (like java stack traces), with "~", "ca" or "estim" (don't confuse with EST timezone).
# Add remaining 2nd-tier processline cases; start with GC logs; see REF for list.  Add: ability to process logs from docker container logs. 



#TODO:  Create a datetimestamp rationalizer library script.  Input anything that kind of resembles a date, and it will output a reversible datetime stamp.
#TODO: BUG:  [pjalajas@sup-pjalajas-hub SynopsysScripts]$ mdate=2020-08-13 ; find ~/dev/customers/customer/00818946_ToddVulnsNoProjects/ -iwholename "*/*/*/${mdate}.log" | grep -e "app-log" -e "access-log" | grep -v "documentation" | xargs -I'{}' -d '\n' -P $(nproc) ./SnpsSigSup_LogProcessor.bash '{}'
     #  trying shopt -s extglob, failed
#TODO multithread processing of log lines, but sort back into timestamp order when done.  
#TODO: should I break some of these commands into separate "library-like" files and use bash "source <file>" in these script to import them as needed?
#TODO: ____ 

#CONFIG



#INIT
#set -x
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
mfilepathname="${1}"
#mstarthour="${2:-00}" # ignore log lines before this hour; nice try, but don't /really/ know what time log line is until most processing done already.
#echo "${mfilepathname}"
mlastknowngooddate=''
#TODO: deal with midnight crossings
#mdebug="${___:-prod}" # DEBUG
mlinecounter=0 # for progress indicator



#FUNCTIONS

printlogdate() { date --utc +%Y-%m-%dT%H:%M:%S.%NZ\ %a ; } # For prepending to output from this script (as opposed to the main task of prepending log line timestamps to themselves.)


#MAIN
  #like:  /home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-authentication/app-log/2020-08-13.log
  #if [[ "$mdebug" == "DEBUG" ]] ; then echo "$(head $filepathname)" ; fi
  mlogtype="$(echo $mfilepathname | sed -re 's#^.*(/hub-.*$)#\1#g' | cut -d/ -f2,3)"
  #echo $mlogtype
  mbasename="$(basename $mfilepathname)"
  #echo $mbasename
  mdirname="$(dirname $mfilepathname)"
  #echo $mdirname
  #man head: #-n, --lines=[-]K print the first K lines instead of the first 10; with the leading '-', print all but the last K lines of each file #   K may have a multiplier suffix: b 512, kB 1000, K 1024, MB 1000*1000, M 1024*1024, GB 1000*1000*1000, G 1024*1024*1024, and so on for T, P, E, Z, Y.  #1Y,1ZB too large.  1EB works. 
        #head --lines=1EB | grep -v TESTING | \
        #head --lines=1EB | \
  #TODO: BUG/HACK fix me!: #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ printf \( | xxd -ps #28 #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ printf 0x28 | xxd -r #( #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ printf \) | xxd -ps #29 #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ printf \' | xxd -ps #27
        #can't xargs within a log file:  xargs -P10 -I '{}' -d '\n' bash -c "processline ${mlogtype} '{}' $mdirname $mbasename"
  cat "$mfilepathname" | \
        sed -re "s/\(/0x28/g" | \
        sed -re "s/\)/0x29/g" | \
        sed -re "s/'/0x27/g" | \
        while read mline ; do
          #TODO: would this work?  */app-log)
          #echo LINENO $LINENO
          #echo "${mline}" 
          #echo LINENO $LINENO
          #echo "$(echo "${mline}" | grep -e "	at ")"
          #if [[ "$mline" == *"	at "* ]]; then
            #echo "$mline"
          #fi
          #echo -n \.
          #echo LINENO $LINENO
          
          
          #JOINUP wrap lines not starting with [ to line above ; may be many in a row, may make a very, very long line starting with [
          echo "$mline" | grep "^\[" > /dev/null 2>&1 
          if [[ "$?" == "0" ]] ; then
            #starts with [ so a good line
            mnextline=""
          else
            #bad line, so append to prior good line and its appendages if any
            mnextline="$mline"
            #TODO:  [pjalajas@sup-pjalajas-hub SynopsysScripts]$ cat /home/pjalajas/dev/customers/N001340/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-jobrunner/app-log/2020-08-13.log | grep -C20 "^\s*at " | head -n 200 | sed -z 's/\n[^\[]/____JOINEDUP____/g'
            echo 'WORKING HERE:   need to change this loop to test for line starting with \[ and if does start with \[, process fully \; if doesnt start with \[, then append to prior line and "continue".   OR:   need to decide which is more expensive to process, OR, which/when is best to use the power of parallel.  _____________'  
          fi


            echo 'WORKING HERE:   need to change this loop to test for line starting with \[ and if does start with \[, process fully \; if doesnt start with \[, then append to prior line and "continue".   OR:   need to decide which is more expensive to process, OR, which/when is best to use the power of parallel.  _____________'  


       
          exit






          case $mlogtype in
            hub-authentication/app-log|hub-jobrunner/app-log|hub-registration/app-log|hub-scan/app-log|hub-webapp/app-log)
              #[d5c907168077] 2020-08-13 00:00:36,589Z[GMT] [https-jsse-nio-8443-exec-3] INFO  com.blackducksoftware.usermgmt.authentication.provider.UserMgmtUserDetailsService - Loading user: sysadmin
              #echo LINENO $LINENO
              mworking=''
              mworking="$(echo "${mline}" | sed -re 's/(^.* )(20[0-9]{2}-[0-1][0-9]-[0-3][0-9]) ([0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]{3}Z\[GMT\])(.*$)/\2 \3/g')" # 2020-08-13 00:02:02,771Z[GMT]
              mworking="$(echo "${mworking}" | sed -re 's/Z\[GMT\]/Z/')"
              mworking="$(echo "${mworking}" | tr , . )"
              #echo \$mworking :: \'$mworking\'
            ;;
            hub-registration/access-log|hub-scan/access-log|hub-webapp/access-log|hub-webserver/access-log)
              #[c1571cb1a618] 127.0.0.1 - - [12/Aug/2020:23:59:56 +0000] GET /registration/health-checks/liveness HTTP/1.1 200 25
              #TODO do we need sed /g?  
              #echo LINENO $LINENO
              mworking=''
              mworking="$(echo "${mline}" | sed -re 's#(^.* \[)([0-3][0-9])/([A-Z][a-z]{2})/(20[0-9]{2}):([0-2][0-9]:[0-5][0-9]:[0-5][0-9]) (\+[0-9]{4})(\].*$)#\3 \2, \4 \5 \6#')" # 12/Aug/2020:23:59:56 +0000
            ;;
            *)
              echo ERROR bad case, unknown log type: "$mlogtype"
              #echo "$mline"
            ;;
          esac

          #echo \$mworking=${mworking}, will now test if acceptable input date format #TESTING
          #echo -n "$(echo \$mworking=${mworking}, will now test if acceptable input date format | grep -v 2020)" #TESTING
          #set -o posix ; set | grep -i -e working -e lastknown | cat -A
          #echo \$mlastknowngooddate=$mlastknowngooddate 
          #If date is good, update lastknowngood; if bad, replace bad date with lastknowngood
          #echo LINENO $LINENO 108
          #date --utc +%H -d "${mworking}" # test if mworking is a bad date, a line with no datestamp
          #date --utc +%H -d "${mworking}" >& /dev/null #test if mworking is a bad date, a line with no datestamp
          #date --utc +%H -d "${mworking}" >& /dev/null ; echo -n $? # test if mworking is a bad date, a line with no datestamp
          #date --utc +%H -d "${mworking}" >& /dev/null # test if mworking is a bad date, a line with no datestamp
          #echo LINENO $LINENO 113
          mtest="$(date --utc +%H -d "${mworking}" >& /dev/null ; echo $?)" 
          #echo "$mtest"
          #if [[ "$?" == "0" ]] ; then
          if [[ "$mtest" == "0" ]] ; then
            #echo date is good 
            mlastknowngooddate="${mworking}"
            #echo "GOOD: updated mlastknowngooddate: $mlastknowngooddate"
            mestimated=''
            #echo -n \.
          else
            #echo date is bad, replace with last known good date...  
            #echo "setting mworking to mlastknowngooddate : ${mlastknowngooddate}"
            mworking="${mlastknowngooddate}"
            #echo "LASTKNOWNGOOD: updated \$mworking to $mworking"
            mestimated='~ca'
            #echo -n \x
          fi
    
          #"mworking" date strings should all be good at this point, one way or the other:
          mhour="$(date --utc +%H -d "${mworking}")"  # for creating new more manageable hourly log files with this hour appended to original log filename
          mworking="[li:$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ\ %a -d "${mworking}")${mestimated}]"
          #echo "${mhour} :: ${mworking} :: ${mline}" # TESTING
          #TODO try to make indempotent...
          #TODO append, to the prepend, an abbrev original log filename, like authapp or jrapp, so user can follow up
          #TODO: try to make every 10 minutes? 
          echo "${mworking} ${mline}" >> ${mdirname}/${mbasename}.H${mhour}Z.log # TODO make log filename acceptable as input into date -d, like 2020-08-13T18:00Z.log
          
          #PROGRESS INDICATOR
          #instead, user parallel --bar
          #mminute=$(date --utc +%M -d "${mworking}") # for progress indicator, such as it is
          meveryxlines=100
          #if [[ "$mminute" == "00" ]] ; then echo -n '.' ; fi # poor-man's progress indicator for every 10 minutes of logs lines
          #mlinecounter=$((mlinecounter+1))
          #mmod=$((mlinecounter % $meveryxlines))
          #echo \$mmod:$mmod
          #if [[ "$mmod" == "0" ]] ; then echo -n '.' ; fi
   
        done









exit
#REFERENCE
put notes here
How is this thing going to work?
Thoughts:
For now, for processing only Black Duck (Hub) system log zip bundle.
Use log path to identify log type. See list below. 
TODO: Even pull some of the date-containing records from the .txt and .json files.  But don't try to prepend estimated datestamps to those lines without them, because that isn't logical for those files.

What is the log file and log line processing flow?  
Point command line at top of log file bundle dir tree. 
Enter a date and time with timezone of interest.  Maybe a small range of dates and times. Use date in log filename. Easiest to do just like grep -C context before and/or after, for log files inclusion and log lines.
Script finds log files in that _date_ range.
Script prepends log lines with marker (like "li:") and then well-structured reversible (can pipe into "date -d") utc datetimestamp.
Script prepends those log lines with no timestamp and estimated timestamp copied from the last explicitly logged timestamp, lastknowngood. Intended primarily for java stack traces. 
Script filters log lines using prepended timestamps, to improve performance, to minimize load piped into loginterlacer.


[pjalajas@sup-pjalajas-hub loginterlacer]$ find /home/pjalajas/dev/customers/*/00818946_ToddVulnsNoProjects | cut -d\/  -f9,10 | grep / | sort -u
debug/jobinfo-2020-08-13T20_12_57.195Z.txt
debug/reginfo-2020-08-13T20_12_57.195Z.txt
debug/scaninfo-2020-08-13T20_12_57.195Z.txt
debug/scanpurgejob-2020-08-13T20_12_57.195Z.txt
debug/sysinfo-2020-08-13T20_12_57.195Z.txt
hub-authentication/app-log # done 08-23
hub-authentication/gc-log 
hub-documentation/access-log # never?
hub-documentation/app-log  # never?
hub-documentation/tomcat-access-log # never?
hub-jobrunner/app-log # done 08-24
hub-jobrunner/gc-log  
hub-registration/access-log # done 08-24
hub-registration/app-log # done 08-24
hub-registration/gc-log
hub-registration/tomcat-access-log # empty dir 
hub-scan/access-log # done 08-24
hub-scan/app-log # done 08-24
hub-scan/gc-log
hub-scan/tomcat-access-log # later? empty?
hub-solr/server-log
hub-upload-cache/2020-07-31.log
hub-upload-cache/2020-08-01.log
hub-upload-cache/2020-08-02.log
hub-upload-cache/2020-08-03.log
hub-upload-cache/2020-08-04.log
hub-upload-cache/2020-08-05.log
hub-upload-cache/2020-08-06.log
hub-upload-cache/2020-08-07.log
hub-upload-cache/2020-08-08.log
hub-upload-cache/2020-08-11.log
hub-upload-cache/2020-08-12.log
hub-upload-cache/2020-08-13.log
hub-webapp/access-log # done 08-24
hub-webapp/app-log #  done 08-24
hub-webapp/gc-log
hub-webapp/tomcat-access-log # later? empty dir? 
hub-webserver/access-log # done 08-24
hub-webserver/nginx-errors
scansummary/codelocationscan-summary.json
scansummary/codelocation-summary.json
scansummary/scan-job-series-daily.json
scansummary/scan-job-series-hourly.json
scansummary/scanjobs-summary.json
scansummary/scan-series-daily.json
scansummary/scan-series-hourly.json
