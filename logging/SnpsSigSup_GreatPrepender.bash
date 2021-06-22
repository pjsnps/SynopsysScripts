#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 2106222338Z
#CHANGE: pj rm echos 

#PURPOSE: Reads log lines in from pipe. If a line doesn't have a timestamp (like stack staces), this will prepend that line with the last known good timestamp.

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond
#TODO:  Slow...not sure what we can do...  Aggressively filter the input lines to your hour of interest. 


while read -r line
do
  #does it have a timestamp in the first few space-separated words?
  #  delete singleleading and trailing space
  #  TIMETEST='2021-05-07 20:14:35,242Z[GMT] [scan-upload-0] ERROR'
  #    try to add:  [22/Jun/2021:05:49:55 +0000]
  #echo \'$line\'

  #TIMETEST=$(echo "$line" | \
  #  cut -d\  -f1-4 | \
  #  grep -Po "20[0-9]{2}-[01][0-9]-[0-3][0-9] [0-2][0-9](:[0-5][0-9]){2},[0-9]+Z\[GMT\]" # | \
  #)
  TIMETEST=$(echo "$line" | cut -d\  -f1-4 | grep -Po "20[0-9]{2}-[01][0-9]-[0-3][0-9] [0-2][0-9](:[0-5][0-9]){2},[0-9]+Z\[GMT\]")
  #echo 29:TIMETEST=\'$TIMETEST\'
  #date: invalid date ‘2021-06-22 05:50:03,099Z[GMT]’
  TIMETEST=$(echo $TIMETEST | sed -re 's/ /T/' -e 's/,/./' -e 's/\[GMT\]//') 2>/dev/null
  #echo 31:TIMETEST=\'$TIMETEST\'
    #sed -re 's/^\s?(.*)\s?$/\1/g'
  if [[ "$TIMETEST" == "" ]] ; then
    #wasn't YYYY-MM-DD HH:MM:SS,SSSZ[GMT]   # yeah, it has Z and GMT...
    #try test if 22/Jun/2021:05:49:55 +0000   format...
    #    '[ade2d032d2ac] 10.60.16.242 - - [22/Jun/2021:05:50:02 +0000] "GET ' log line format
  TIMETEST=$(echo "$line" | \
    cut -d\  -f5-6 | \
    grep -Po '[0-3]?[0-9]/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/20[0-9]{2}:[0-2][0-9]:[0-5][0-9]:[0-5][0-9] \+0000' # | \
  )
    #echo 37:TIMETEST=\'$TIMETEST\'
    #grep -Po '22/Jun/2021:05:49:55 \+0000' # | \
    #grep -Po "\[[0-3][0-9]/(Jan|Feb|Jun)/20[0-9]{2}:[0-5][0-9]:[0-5][0-9] \+[0-9]{4}\]" # | \
    #grep -Po "\[[0-3][0-9]/(Jan|Feb|Jun)/20[0-9]{2}:[0-5][0-9]:[0-5][0-9] \+[0-9]{4}\]" # | \
    #[pjalajas@sup-pjalajas-hub N00862113]$ TIMETEST='22/Jun/2021:05:12:34 +0000' ; date -d "$(echo $TIMETEST|tr '/' '-' | sed -re 's#(20[0-9]{2}):#\1 #')"                                     Tue Jun 22 01:12:34 EDT 2021
    #[pjalajas@sup-pjalajas-hub N00862113]$ TIMETEST='22/Jun/2021:05:12:34 +0000' ; date --utc -d "$(echo $TIMETEST|tr '/' '-' | sed -re 's#(20[0-9]{2}):#\1 #')"                               Tue Jun 22 05:12:34 UTC 2021
    #[pjalajas@sup-pjalajas-hub N00862113]$ TIMETEST='22/Jun/2021:05:12:34 +0930' ; date --utc -d "$(echo $TIMETEST|tr '/' '-' | sed -re 's#(20[0-9]{2}):#\1 #')"                               Mon Jun 21 19:42:34 UTC 2021
    TIMETEST="$(  date --utc -d "  $(echo $TIMETEST|tr '/' '-' | sed -re 's#(20[0-9]{2}):#\1 #')"   )"
    #echo 45:TIMETEST=\'$TIMETEST\'
  fi


    #
  #  echo 45:TIMETEST=\'$TIMETEST\'
  if [[ "$TIMETEST" > "" ]] ; then
    #sanityize it:
    #[pjalajas@sup-pjalajas-hub N00862113]$ date -d"2021-06-22T05:50:02.000000000Z"
    #Tue Jun 22 01:50:02 EDT 2021
    TIMETEST="$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ -d"$TIMETEST")"
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
