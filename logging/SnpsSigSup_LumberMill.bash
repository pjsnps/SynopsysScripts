#!/usr/bin/bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-17
#LICENSE: SPDX Apache-2.0
#VERSION: 20210318T0211
#CHANGES: pj running with SedDated ".*" ".*" for all 03-16 app-log logs this time.

#PURPOSE:  Wrapper for several scripts to summarize Synopsys Black Duck server logs.

#USAGE: TODO


time (\
  set -x ; 
  date --utc ; 
  hostname -f ; 
  pwd ; 
  whoami ; 
  parallel '\
    cat {} | \
    bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash ".*" ".*" | \
    bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash \
    ' ::: \
    ./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | \
    parallel '\
      echo {} | \
      grep -E -e "(Exception:| ERROR | FATAL | SEVERE | [Tt]imeout | 403 |failed to respond| Broken pipe |Write failed|Caused by:)"\
      ' | \
    bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | \
    sort | uniq -c | sort -k1nr | head -n 1000 | cut -c1-1000 \
  ) |& \
tee /dev/tty | \
gzip -9 >> errors_etc_$(date --utc +%Y%m%d%H%MZ%a)_$(hostname).out.gz # PJHIST LumberMill^C

    #./blackduck-staging_bds_logs-20210316T233214/hub-jobrunner/app-log/2021-03-16.log | \
    #bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-16 " "2021-03-17 " | \
#./blackduck-staging_bds_logs-20210316T233214/hub-jobrunner/app-log/2021-03-16.log
    #./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | \
exit
#REFERENCE
#[pjalajas@sup-pjalajas-hub N00855538_FailedToRespond]$ time (set -x ; date --utc ; hostname -f ; pwd ; whoami ; parallel 'cat {} | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-16 " "2021-03-17 " | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash' ::: ./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | parallel 'echo {} | grep -E -e "(Exception:| ERROR | FATAL | SEVERE | [Tt]imeout | 403 |failed to respond| Broken pipe |Write failed|Caused by:)"' | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | head -n 1000 | cut -c1-1000 ) |& tee /dev/tty | gzip -9 >> errors_etc_$(date --utc +%Y%m%d%H%MZ%a)_$(hostname).out.gz # PJHIST LumberMill^C
