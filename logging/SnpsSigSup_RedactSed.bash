#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-11
#LICENSE : SPDX Apache-2.0
#VERSION: 2103120017Z

#PURPOSE: Inputs lines from stdin, outputs lines with varying content deleted.  Removes datestamps, uuids, etc.  For easier comparison, tabulations, etc. 

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond

while read -r line
do
  echo "$line" | \
    sed -r \
        -e 's/2021-.*\[[0-9a-f].*https-.*exec-[0-9]{1,4}\]/[]/g' \
        -e 's/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/[]/g' \
        -e 's/(hub-[a-z]+_)[A-Za-z0-9]+/\1[]/g' \
        -e 's/HHH[0-9]+/[]/g'
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
