#!/usr/bin/bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-17
#LICENSE: SPDX Apache-2.0
#VERSION: 20210318T0311
#CHANGES: pj add Stated Application to try to catch container restarts. 

#PURPOSE:  Wrapper for several scripts to summarize Synopsys Black Duck server logs. Output log errors counts to screen and file. 

#USAGE: Edit "log" line and "ERROR" line as desired, then: bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_LumberMill.bash 

#NOTES:  Takes about 8 or 9 minutes for all logs over 2 days. 


time (\
  set -x ; 
  date --utc ; 
  hostname -f ; 
  pwd ; 
  whoami ; 
  parallel "\
    cat {} | \
    bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash \
    " ::: \
    ./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-1[56].log | \
    parallel "\
      echo {} | \
      grep -E -e \"(Exception:| ERROR | FATAL | SEVERE | [Tt]imeout | 403 |failed to respond| Broken pipe |Write failed|Caused by:|Started [A-Za-z]+Application in)\" \
      " | \
    bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | \
    sort | uniq -c | sort -k1nr | head -n 1000 | cut -c1-1000 \
  ) |& \
tee /dev/tty | \
gzip -9 >> errors_etc_$(date --utc +%Y%m%d%H%MZ%a)_$(hostname).out.gz # PJHIST LumberMill^C

exit
#REFERENCE
    #./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-1[56].log | \
    #./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | \
    #./blackduck-staging_bds_logs-20210316T233214/hub-jobrunner/app-log/2021-03-16.log | \
