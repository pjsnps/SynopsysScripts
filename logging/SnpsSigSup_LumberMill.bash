#!/usr/bin/bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-17
#LICENSE: SPDX Apache-2.0
#SUPPORT: https://www.synopsys.com/software-integrity/support.html, https://community.synopsys.com/s/, Software-integrity-support@synopsys.com
#VERSION: 20210322T1623
#CHANGES: pj purpose 

#PURPOSE:  Wrapper for several scripts to summarize Synopsys Black Duck server logs. "summary" option outputs log errors counts to screen and file. 

#REQUIRES:  
#SnpsSigSup_GreatPrepender.bash
#SnpsSigSup_RedactSed.bas
#gnu parallel 
#Works with GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu) 
 
#USAGE: Edit "bash", "log", "ERROR", "sort" lines as desired, then: bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_LumberMill.bash [summary]

#TODO: parameterize grep expressions, .log line

#NOTES:  Takes about 8 or 9 minutes for all logs over 2 days. "summary" option redacts varying strings (dates, thread IDs, etc), then eutputs a list of the counts of each grep matching line, sort by decreasing counts via "sort | uniq -c | sort -k1nr".

#CONFIG
SCRIPT_DIR="/home/pjalajas/dev/git/SynopsysScripts/logging" # no trailing slash

#FUNCTIONS
f_summary() {
  if [[ "$1" == "summary" ]] ; then
    bash $SCRIPT_DIR/SnpsSigSup_RedactSed.bash | \
    sort | uniq -c | sort -k1nr | head -n 1000 | cut -c1-1000 | \
    parallel "\
      echo {} | \
      grep -E -e \
        \"( ERROR |Exception:| FATAL | SEVERE | [Tt]imeout | 403 |failed to respond| Broken pipe |Write failed|Caused by:|Started [A-Za-z]+Application in)\" \
      "  
  else
    cat
  fi
}
export -f f_summary


#MAIN

time (\
  set -x ; 
  date --utc ; 
  hostname -f ; 
  pwd ; 
  whoami ; 
  parallel "\
    cat {} | \
    bash $SCRIPT_DIR/SnpsSigSup_GreatPrepender.bash \
    " ::: \
    ./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-1[56].log | \
    f_summary $1 \
  ) |& \
tee /dev/tty |& \
gzip -9 >> errors_etc_$(date --utc +%Y%m%d%H%MZ%a)_$(hostname).out.gz 

exit
#REFERENCE
    #./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-1[56].log | \
    #./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | \
    #./blackduck-staging_bds_logs-20210316T233214/hub-jobrunner/app-log/2021-03-16.log | \
