#!/dev/null
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 20210318T0238
#CHANGES: pj actually, don't use this script, little benefit to filter by timestamp, hard to do perfectly.  

#PURPOSE: Reads log lines in from pipe. Outputs lines between lines with datestamps matching sed regex expressions in command line position $1 and $2. Lines, between those line, with no timestamp are also output.  For piping into SnpsSigSup_GreatPrepender.bash.

#USAGE: <list of Synopsys Black Duck system log file lines> | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash  
#USAGE: cat ./blackduck_bds_logs-20210309T023325.zip.expanded/standard/*/app-log/2021-03-04.log | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-04 20:" "2021-03-04 21:" 
#USAGE: time (parallel 'cat {} | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-04 20:" "2021-03-04 21:" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash' ::: ./blackduck_bds_logs-20210309T023325.zip.expanded/standard/*/app-log/2021-03-04.log | parallel 'echo {} | grep -E -e "(NullP|ERROR)"' | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-500 ) # PJHIST LumberMill

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond
#TODO:  Slow... Add more gnu parallel; add gnu parallel servers; tighten up regex; aggressively filter the input lines to hour or minute of interest. 
#TODO:  Deal with when $1 or $2 doesn't exactly match an actual timestamp. Opposing pressures: the more precise your $1 and $2 timestamps (12:15 being more precise than 12:) , then all this processing should be faster, BUT, the more likely one or both timestamps are not found...then what happens?  

while read -r line
do
  #echo "$line" | sed -nre "/2021-03-04 18:0[0-9]/,/2021-03-04 18:10/p" 
  echo "$line" | sed -nre "/$1/,/$2/p" 
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
