#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 2105120223Z
#CHANGE: pj working on: ~: 2021-05-07 20:14:35,242Z[GMT] [scan-upload-0] ERROR com.blackducksoftware.scan.siggen.impl.BlackDuckInputOutputService - Failed saving document data for document null

#PURPOSE: Reads log lines in from pipe. If a line doesn't have a timestamp (like stack staces), this will prepend that line with the last known good timestamp.

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond
#TODO:  Slow...not sure what we can do...  Aggressively filter the input lines to your hour of interest. 


while read -r line
do
  #does it have a timestamp in the first few space-separated words?
  #  delete singleleading and trailing space
  #  TIMETEST='2021-05-07 20:14:35,242Z[GMT] [scan-upload-0] ERROR'

  TIMETEST=$(echo "$line" | \
    cut -d\  -f1-4 | \
    grep -Po "20[0-9]{2}-[01][0-9]-[0-3][0-9] [0-2][0-9](:[0-5][0-9]){2},[0-9]+Z\[GMT\]" # | \
  )
    #sed -re 's/^\s?(.*)\s?$/\1/g'


    #
    #echo TIMETEST=\'$TIMETEST\'
  if [[ "$TIMETEST" > "" ]] ; then
    #if so, then store its timestamp in LASTKNOWNTIME
    LASTKNOWNTIME=$TIMETEST
    ESTIMATED=" "
    #echo \$LASTKNOWNTIME=\'$LASTKNOWNTIME\'
    #echo \$ESTIMATED=\'$ESTIMATED\'
  else
    #no timestamp, so mark as estimated with ~
    ESTIMATED="~"
    #echo \$ESTIMATED=\'$ESTIMATED\'
  fi
  echo "${LASTKNOWNTIME}${ESTIMATED}: $line"
done

exit
#REFERENCE
: '
[pjalajas@sup-pjalajas-hub N00854173_2020120Performance]$ time (parallel 'cat {} | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-04 20:" "2021-03-04 21:" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash' ::: ./blackduck_bds_logs-20210309T023325.zip.expanded/standard/*/app-log/2021-03-04.log | parallel 'echo {} | grep -E -e "(NullP|ERROR)"' | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-500 ) # PJHIST LumberMill
     33 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Exception stack trace:
     32 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Handling exception for url: 'https://blackduck.eng.netapp.com/api/projects/[]/versions/[]/bom-status', logRef: 'hub-webapp_[]', locale: 'en_US', msg: at index 2
      1 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Handling exception for url: 'https://blackduck.eng.netapp.com/api/projects/[]/versions/[]/components/[]/versions/[]', logRef: 'hub-webapp_[]', locale: 'en_US', msg: Batch update returned unexpected row count from update [0]; actual row count: 0; expected: 1
      1 [] ERROR com.blackducksoftware.core.security.impl.RunAsService - runasservice
      1 [] ERROR org.hibernate.engine.jdbc.batch.internal.BatchingBatch - []: Exception executing batch [org.hibernate.StaleStateException: Batch update returned unexpected row count from update [0]; actual row count: 0; expected: 1], SQL: delete from ST.component_adjustment where id=?

real    6m45.166s
user    9m12.352s
sys     11m46.227s
'
