#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-11
#LICENSE : SPDX Apache-2.0
#VERSION: 2104221633Z
#CHANGES: pj fix journalctl redaction, #node.id=0zhy68d65ar4sck68fbafgj0d service.id=zvw6kqnjtv03pnd2brhhcqawg task.id=est94zjlqxq79ve7xu7683jjs,  node 0zhy68d65ar4sck68fbafgj0d" error="could not find network allocator state for network ujr5rcujwwuf5b7wqh17ahdo1", container=112d7b02e976c0632fa6bcd4d4f41cea6727a2fe840daaa1385399f587972855, and a few others, including stack names.

#PURPOSE: Inputs lines from stdin, outputs lines with varying content deleted.  Removes datestamps, uuids, etc.  For easier comparison, tabulations, etc. 

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond

#TODO:  May want to leave in the first [0-9a-f] (in first few sed -e below; [4d7f6f0d393a] in example above), which I think is the container id.  There is only around 10 of them, and they should generally be the same for the same log lines.  If true, then may instead want to convert it to human-readable container name. 

while read -r line
do
  echo "$line" | \
    sed -r \
        -e 's/2021.*\[GMT\]~: /[] /g' \
        -e 's/2021-.*(\[[0-9a-f])?.*https-.*exec-[0-9]{1,4}\]/[]/g' \
        -e 's/2021-.*\[[0-9a-f].*pool-[0-9]*-thread-[0-9]*\]/[]/g' \
        -e 's/2021-.*(\[[0-9a-f])?.*jobRunner-[0-9]*\]/[]/g' \
        -e 's/2021-.*\[[0-9a-f].*BDSBackgroundRenewalWorker\]/[]/g' \
        -e 's/2021-.*\[[0-9a-f].*kb-api-pool-[0-9]+\]/[]/g' \
        -e 's/2021-.*\[[0-9a-f].*jobTaskScheduler-[0-9]+\]/[]/g' \
        -e 's/2021-.*\[[0-9a-f].*main\]/[]/g' \
        -e 's/2021-.*(\[[0-9a-f])?.*main\]/[]/g' \
        -e 's/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/[]/g' \
        -e 's/(hub-[a-z]+_)[A-Za-z0-9]+/\1[]/g' \
        -e 's/HHH[0-9]+/[]/g' \
        -e 's/ duration: [0-9]+\.[0-9]+ / duration: [] /g' \
        -e 's/Ljava.lang.String\;\@[0-9a-f]+\]/Ljava.lang.String;@[] /g' \
        -e 's/ duration: [0-9]+\.[0-9]+E-?[0-9]+ / duration: [] /g' \
        -e 's/ [0-9]+ms/ []ms/g' \
        -e 's/After [0-9]{1,2} ms./After [] ms./g' \
        -e 's/versionBomId=[0-9]+/versionBomId=[]/g' \
        -e 's/(created|updated)At=20[0-9]{2}-[01][0-9]-[0-3][0-9]T[0-2][0-9](:[0-5][0-9]){2}\.[0-9]*Z/\1At=[]/g' \
        -e 's/\[\] *\[\]/[]/g' \
        -e 's/2021.*\[(warning|error)\] /[] [\1]/g' \
        -e 's/\<[0-9]+\.[0-9]+\.[0-9]+\>/[]/g' \
        -e 's/\.[0-9]+\:[0-9]+/[]/g' \
        -e 's/channel [0-9]+/channel []/g' \
        -e 's/Content-Length:"[0-9]+"/Content-Length:"[]"/g' \
        -e 's/X-BDS-CorrelationID:"[0-9]+"/X-BDS-CorrelationID:"[]"/g' \
        -e 's/Date:".* GMT"/Date:"[] GMT"/g' \
        -e 's/SQL State: [0-9A-Z]+/SQL State: []/g' \
        -e 's/Error Code: [0-9]+/Error Code: []/g' \
        -e 's/ERROR state [0-9]+ means/ERROR state [] means/g' \
        -e 's/when status=[0-9]+/when status=[]/g' \
        -e 's/^.*dockerd\[[0-9]+]: time="....-..-..T..:..:..\.[0-9]+-..:.."/dockerd[] time=[]/g' \
        -e 's/network .*_default not found/network []_default not found/g' \
        -e 's/ID:[0-9a-z]{25}/ID:[]/g' \
        -e 's/Index:[0-9]+/Index:[]/g' \
        -e 's/sha256:[a-f0-9]+/sha256:[]/g' \
        -e 's/....-..-..T..:..:..\.[0-9]+Z/[]Z/g' \
        -e 's#blackducksoftware/[a-z\-]+#blackducksoftware/[]#g' \
        -e 's/Name:[a-z0-9_-]+/Name:[]/g' \
        -e 's/VOLUME [a-z0-9_-]+-data-/VOLUME []-data-/g' \
        -e 's/namespace: [a-z0-9_-]+/namespace: []/g' \
        -e 's/\.id=[0-9a-z]+/.id=[]/g' \
        -e 's/(node|network) [0-9a-z]{25}/\1 []/g' \
        -e 's/(container=)[0-9a-f]{64}/\1[]/g' \
        -e 's/(_default id )[0-9a-z]{25}/\1[]/g' \
        -e 's/[0-9a-z]{64}/[]/g' \
        -e 's/[0-9a-z]{25}/[]/g' \
        -e 's/(unknown network )[0-9a-zA-Z_-]+(_default id)/\1[]\2/g' \
        -e 's/(No such container: )[0-9a-zA-Z_-]+_/\1[]_/g' \
        -e 's/(network )[0-9a-zA-Z_-]+(_default remove failed)/\1[]\2/g' \

        #keep a blank line above this one
done


exit
#REFERENCE
