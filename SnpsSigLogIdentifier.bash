#!/usr/bin/env bash

#SCRIPT:     SnpsSigLogIdentifier.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-08-23          # 
#VERSION:    2008231430Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: ____ # :! grep -v grepvcksum <script> | cksum

#PURPOSE:    Identify what kind of log we are processing.  To be used in pipeline before loginterlacer.bash; keep loginterlacing.bash just for the interlacing task, not pre-preprocessing.

#USAGE: See REFERENCE section at bottom of this script.
#USAGE: Accepts a log path/filename in position one.  Need path to hint at log line date format. 
#TODO:  Create a datetimestamp rationalizer library script.  Input anything that kind of resembles a date, and it will output a reversible datetime stamp.
#TODO: ____ 

#CONFIG

#FUNCTIONS

printlogdate() { date --utc +%Y-%m-%dT%H:%M:%S.%NZ\ %a ; }

  #case "${1}" in
  #  hub-authentication/app-log)
  #    #[d5c907168077] 2020-08-13 00:00:36,589Z[GMT] [https-jsse-nio-8443-exec-3] INFO  com.blackducksoftware.usermgmt.authentication.provider.UserMgmtUserDetailsService - Loading user: sysadmin
  #    #mworking="$(echo "${2}" | sed -re 's/\] (20[0-9]{2}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]{3}Z\[GMT\]))')"
  #    echo in the processline function...
  #    mworking="$(echo "${2}")"
  #    echo "${mworking}"
  #    return "${mworking}"




processline() {
  #TODO maybe make this function a separate script
  #echo input: "${1}" "${2}"
  mpath="${1}"
  mline="${2}"
  mdirname="${3}"
  mbasename="${4}"
  case $mpath in
    hub-authentication/app-log)
     #mworking="$(echo "${mline}" | sed -re 's/\] (20[0-9]{2}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]{3}Z\[GMT\]))')"
     mworking="$(echo "${mline}" | sed -re 's/(^.* )(20[0-9]{2}-[0-1][0-9]-[0-3][0-9]) ([0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]{3}Z\[GMT\])(.*$)/\2 \3/g')"
       #2020-08-13 00:02:02,771Z[GMT]
     mworking="$(echo "${mworking}" | sed -re 's/Z\[GMT\]/Z/')"
     mworking="$(echo "${mworking}" | tr , . )"
     mhour="$(date --utc +%H -d "${mworking}")"  # for creating new more manageable hourly log files
     mworking="[li:$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ\ %a -d "${mworking}")]"
     #echo "$mhour"
     #echo "${mworking} ${mline}"
     #output like:   [li:2020-08-13T00:00:36.411000000Z Thu] [d5c907168077] 2020-08-13 00:00:36,411Z[GMT] [https-jsse-nio-8443-exec-3] INFO  com.blackducksoftware.usermgmt.authentication.provider.UserMgmtUserDetailsService - Loading user: sysadmin
     #Try to append that to new hourly log file...TODO:  won't be sorted due to xargs, will need to sort -u later before use.
     echo "${mworking} ${mline}" >> ${mdirname}/${mbasename}.H${mhour}.log
    ;;
 esac
}
export -f processline






#INIT
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
mfilepathname="${1}"
#TODO: deal with midnight crossings
#mdateutc="${2}" # UTC
#mtimeutc="${3}" # UTC
#mdebug="${4:-prod}" # DEBUG
#echo "${mlogdirtop} :: ${mdateutc} :: ${mtimeutc} :: ${mdebug}"
  echo "$(printlogdate) :: processing log file $mfilepathname"
  #like:  /home/pjalajas/dev/customers/netapp/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-authentication/app-log/2020-08-13.log
  #if [[ "$mdebug" == "DEBUG" ]] ; then echo "$(head $filepathname)" ; fi
  mlogtype="$(echo $mfilepathname | sed -re 's#^.*(/hub-.*$)#\1#g' | cut -d/ -f2,3)"
  echo "${mlogtype}"
  #mlogfilename="${mfilepathname##*/}"
  mbasename="$(basename $mfilepathname)"
  mdirname="$(dirname $mfilepathname)"
  echo "$(printlogdate) :: processing log file type hub-authentication/app-log..."
        #head -n 10000 | \
  cat "$mfilepathname" | \
        xargs -P10 -I'{}' bash -c "processline ${mlogtype} '{}' $mdirname $mbasename"
  #output like:   [li:2020-08-13T00:00:36.411000000Z Thu] [d5c907168077] 2020-08-13 00:00:36,411Z[GMT] [https-jsse-nio-8443-exec-3] INFO  com.blackducksoftware.usermgmt.authentication.provider.UserMgmtUserDetailsService - Loading user: sysadmin
exit
#
#REFERENCE
put notes here
How is this thing going to work?
Thoughts:
For now, for processing only Black Duck (Hub) system log zip bundle.
Use log path to identify log type. See list below. 
Even pull some of the date-containing records from the .txt and .json files.  But don't try to prepend estimated datestamps to those lines without them, because that isn't logical for those files.

What is the log file and log line processing flow?  
Point command line at top of log file bundle dir tree. 
Enter a date and time with timezone of interest.  Maybe a small range of dates and times. Use date in log filename. Easiest to do just like grep -C context before and/or after, for log files inclusion and log lines.
Script finds log files in that _date_ range.
Script prepends log lines with marker (like "li:") and then well-structured reversible (can pipe into "date -d") utc datetimestamp.
Script prepends those log lines with no timestamp and estimated timestamp copied from the last explicitly logged timestamp. Intended primarily for java stack traces. 
Script filters log lines using prepended timestamps.  To improve performance, minimize load piped into loginterlacer.





[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash ./SnpsSigLogIdentifier.bash ~/dev/customers/*/00818946_ToddVulnsNoProjects/ 2020-08-13 18:00
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/ :: 2020-08-13 :: 18:00
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-authentication/app-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-authentication/gc-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-documentation/access-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-jobrunner/app-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-jobrunner/gc-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-registration/access-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-registration/app-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-registration/gc-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-scan/access-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-scan/app-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-scan/gc-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-upload-cache/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-webapp/access-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-webapp/app-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-webapp/gc-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-webserver/access-log/2020-08-13.log
/home/pjalajas/dev/customers/customer/00818946_ToddVulnsNoProjects/blackduck_bds_logs-20200813T201257/hub-webserver/nginx-errors/2020-08-13.log







[pjalajas@sup-pjalajas-hub loginterlacer]$ find /home/pjalajas/dev/customers/*/00818946_ToddVulnsNoProjects | cut -d\/  -f9,10 | grep / | sort -u                                            
debug/jobinfo-2020-08-13T20_12_57.195Z.txt
debug/reginfo-2020-08-13T20_12_57.195Z.txt
debug/scaninfo-2020-08-13T20_12_57.195Z.txt
debug/scanpurgejob-2020-08-13T20_12_57.195Z.txt
debug/sysinfo-2020-08-13T20_12_57.195Z.txt
hub-authentication/app-log
hub-authentication/gc-log
hub-documentation/access-log
hub-documentation/app-log
hub-documentation/tomcat-access-log
hub-jobrunner/app-log
hub-jobrunner/gc-log
hub-registration/access-log
hub-registration/app-log
hub-registration/gc-log
hub-registration/tomcat-access-log
hub-scan/access-log
hub-scan/app-log
hub-scan/gc-log
hub-scan/tomcat-access-log
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
hub-webapp/access-log
hub-webapp/app-log
hub-webapp/gc-log
hub-webapp/tomcat-access-log
hub-webserver/access-log
hub-webserver/nginx-errors
scansummary/codelocationscan-summary.json
scansummary/codelocation-summary.json
scansummary/scan-job-series-daily.json
scansummary/scan-job-series-hourly.json
scansummary/scanjobs-summary.json
scansummary/scan-series-daily.json
scansummary/scan-series-hourly.json
