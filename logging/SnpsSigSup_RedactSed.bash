#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-11
#LICENSE : SPDX Apache-2.0
#VERSION: 2104262100Z
#CHANGES: pj add Alert log redactions 

#PURPOSE: Help find needle in gigabyte-log haystack.  Input lines from stdin, outputs varying strings redacted.  Removes datestamps, uuids, etc.  For easier comparison, tabulations, etc. 

#USAGE: date --utc ; hostname -f ; pwd ; cat /tmp/alert-april23.text | grep -i -e error -e fatal -e severe -e fail -e wrong -e invalid -e missing -e Exception: -e "(could|does|can) ?not" -e " a problem " -e "not found" -e "timed out" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-300 | sed -re 's/(customername|cstmrnick)/[customer]/g'                                                                                     

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
        -e 's/2021-04-23 12:00:00.868/[]/g' \
        -e 's/....-..-.. ..:..:..\..../[]/g' \
        -e 's/(blackduck)[0-9]+/\1/g' \
        -e 's/(taskScheduler-)[0-9]+/\1[]/g' \
        -e 's/(n?io-8443-exec-)[0-9]+/\1[]/g' \
        -e 's/(PgConnection@)[0-9a-z]+/\1[]/g' \
        -e 's/(enerContainer-)[0-9]+/\1[]/g' \
        -e 's/(Bearer:? )[0-9a-zA-Z\._-]+/\1[]/g' \
        -e 's/(HikariPool-)[0-9]+/\1[]/g' \

        #keep a blank line above this one
#TODO: [bd.corp.[customer].com/[].28]  
done


exit
#REFERENCE

example:
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ date --utc ; hostname -f ; pwd ; cat /tmp/alert-april23.text | grep -i -e error -e fatal -e severe -e fail -e wrong -e invalid -e missing -e Exception: -e "(could|does|can) ?not" -e " a problem " -e "not found" -e "timed out" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-300 | sed -re 's/(customername|cstmrnick)/[customer]/g'                                                                                     
Mon Apr 26 21:50:41 UTC 2021
webserver
/home/pjalajas/dev/git/SynopsysScripts
   1958 at org.springframework.scheduling.support.DelegatingErrorHandlingRunnable.run(DelegatingErrorHandlingRunnable.java:54)
   1946 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckApiTokenValidator : Error reading notifications
   1946 []  WARN 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : User permission failed, cannot read notifications from Black Duck.
   1445 Caused by: java.net.UnknownHostException: blackduck.corp.[customer].com
   1445 com.synopsys.integration.exception.IntegrationException: Could not perform the authorization request: blackduck.corp.[customer].com
   1434 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : Could not perform the authorization request: blackduck.corp.[customer].com: System error
    483 Caused by: java.net.UnknownHostException: bd.corp.[customer].com
    483 com.synopsys.integration.exception.IntegrationException: Could not perform the authorization request: bd.corp.[customer].com
    481 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : Could not perform the authorization request: bd.corp.[customer].com: System error
    143 []  WARN 1 --- [taskScheduler-[]] com.zaxxer.hikari.pool.PoolBase          : HikariPool-[] - Failed to validate connection org.postgresql.jdbc.PgConnection@[] (This connection has been closed.). Possibly consider using a shorter maxLifetime value.
     29 []  INFO 1 --- [taskScheduler-[]] c.s.i.a.c.p.l.ProvidersMissingTask       : ### Task::Class[com.synopsys.integration.alert.common.provider.lifecycle.ProvidersMissingTask] Task Finished
     29 []  INFO 1 --- [taskScheduler-[]] c.s.i.a.c.p.l.ProvidersMissingTask       : ### Task::Class[com.synopsys.integration.alert.common.provider.lifecycle.ProvidersMissingTask] Task Started...
     24 Caused by: java.net.UnknownHostException: blackduck.corp.[customer].com: System error
     24 com.synopsys.integration.exception.IntegrationException: Could not perform the authorization request: blackduck.corp.[customer].com: System error
     23 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : Could not perform the authorization request: blackduck.corp.[customer].com
     13 at com.synopsys.integration.blackduck.http.client.cache.CacheableResponse.throwExceptionForError(CacheableResponse.java:146)
     13 at com.synopsys.integration.blackduck.http.client.cache.CachingHttpClient.throwExceptionForError(CachingHttpClient.java:92)
     13 at com.synopsys.integration.blackduck.http.client.DefaultBlackDuckHttpClient.throwExceptionForError(DefaultBlackDuckHttpClient.java:122)
     13 at com.synopsys.integration.rest.response.DefaultResponse.throwExceptionForError(DefaultResponse.java:214)
     13 com.synopsys.integration.rest.exception.IntegrationRestException: There was a problem trying to GET https://bd.corp.[customer].com/api/projects/[]/versions/[]/components/[]/versions/[]?offset=0&limit=100, response was 404 Not Found.
     13 [] DEBUG 1 --- [enerContainer-[]] c.s.i.a.p.b.c.u.AlertBlackDuckService    : There was a problem trying to GET https://bd.corp.[customer].com/api/projects/[]/versions/[]/components/[]/versions/[]?offset=0&limit=100, response was 404 Not Found.
     13 [] ERROR 1 --- [enerContainer-[]] c.s.i.a.p.b.c.u.AlertBlackDuckService    : Could not retrieve the Bom component: There was a problem trying to GET https://bd.corp.[customer].com/api/projects/[]/versions/[]/components/[]/versions/[]?offset=0&limit=100, response was 404 Not Found.
     12 []  WARN 1 --- [nio-8443-exec-[]] com.zaxxer.hikari.pool.PoolBase          : HikariPool-[] - Failed to validate connection org.postgresql.jdbc.PgConnection@[] (This connection has been closed.). Possibly consider using a shorter maxLifetime value.
      5 Caused by: java.net.UnknownHostException: bd.corp.[customer].com: System error
      5 com.synopsys.integration.exception.IntegrationException: Could not perform the authorization request: bd.corp.[customer].com: System error
      5 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : Could not perform the authorization request: bd.corp.[customer].com
      5 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.w.scheduled.PhoneHomeTask        : Automatically trusting server certificates - not recommended for production use.
      4 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.c.u.AlertBlackDuckService    : Could not retrieve the Bom component: Could not perform the authorization request: blackduck.corp.[customer].com
      3 Caused by: java.net.UnknownHostException: [customer].webhook.office.com: System error
      3 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.c.u.AlertBlackDuckService    : Could not retrieve the Project link: Could not perform the authorization request: blackduck.corp.[customer].com
      3 [] TRACE 1 --- [taskScheduler-[]] c.s.i.a.p.b.task.BlackDuckAccumulator    : Header Authorization : Bearer []
      3 [] TRACE 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckApiTokenValidator : Header Authorization : Bearer []
      3 []  WARN 1 --- [io-8443-exec-[]] com.zaxxer.hikari.pool.PoolBase          : HikariPool-[] - Failed to validate connection org.postgresql.jdbc.PgConnection@[] (This connection has been closed.). Possibly consider using a shorter maxLifetime value.
      2 Caused by: com.synopsys.integration.exception.IntegrationException: [customer].webhook.office.com: System error
      2 com.synopsys.integration.alert.common.exception.AlertException: [customer].webhook.office.com: System error
      2 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.task.BlackDuckDataSyncTask   : Could not retrieve the current data from the BlackDuck server: Could not perform the authorization request: blackduck.corp.[customer].com: System error
      2 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.v.BlackDuckValidator         : Could not perform the authorization request: Connect to bd.corp.[customer].com:443 [bd.corp.[customer].com/[].28] failed: Connection timed out (Connection timed out)
      2 keytool error: java.lang.Exception: Alias <blackduck_system> does not exist
      1 Caused by: com.synopsys.integration.alert.common.exception.AlertException: [customer].webhook.office.com: System error
      1 Caused by: java.net.ConnectException: Connection timed out (Connection timed out)
      1 Caused by: org.apache.http.conn.HttpHostConnectException: Connect to bd.corp.[customer].com:443 [bd.corp.[customer].com/[].28] failed: Connection timed out (Connection timed out)
      1 com.synopsys.integration.alert.common.exception.AlertException: Invalid global config settings. API Token is null.
      1 com.synopsys.integration.exception.IntegrationException: Could not perform the authorization request: Connect to bd.corp.[customer].com:443 [bd.corp.[customer].com/[].28] failed: Connection timed out (Connection timed out)
      1 com.synopsys.integration.exception.IntegrationException: [customer].webhook.office.com: System error
      1 [] c.s.i.a.c.p.l.ProviderSchedulingManager  : Something went wrong while attempting to schedule provider tasks
      1 [] c.s.i.a.c.p.l.ProvidersMissingTask       : Scheduling Task::Class[com.synopsys.integration.alert.common.provider.lifecycle.ProvidersMissingTask] with cron : 0 0 0/1 * * *
      1 [] c.s.i.a.c.users.UserSystemValidator      : Default admin user email missing
      1 [] c.s.i.a.c.w.task.StartupScheduledTask    : Task::Class[com.synopsys.integration.alert.common.provider.lifecycle.ProvidersMissingTask] next run:     04/22/2021 04:00 PM UTC
      1 [] ERROR 1 --- [enerContainer-[]] c.s.i.a.channel.msteams.MsTeamsChannel   : Error occurred sending message:
      1 [] ERROR 1 --- [enerContainer-[]] c.s.i.a.channel.msteams.MsTeamsChannel   : There was an error sending the message.
      1 [] ERROR 1 --- [enerContainer-[]] c.s.i.a.channel.util.RestChannelUtility  : Error sending request
      1 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.task.BlackDuckDataSyncTask   : Could not retrieve the current data from the BlackDuck server: Could not perform the authorization request: bd.corp.[customer].com
      1 [] ERROR 1 --- [taskScheduler-[]] c.s.i.a.p.b.task.BlackDuckDataSyncTask   : Could not retrieve the current data from the BlackDuck server: Could not perform the authorization request: blackduck.corp.[customer].com
      1 [] ERROR 1 --- [taskScheduler-[]] .VulnerabilityNotificationMessageBuilder : Could not construct the message: Could not perform the authorization request: blackduck.corp.[customer].com
      1 keytool error: java.lang.Exception: Alias <blackduck_root> does not exist
      1 keytool error: java.lang.Exception: Alias <hub.docker.com> does not exist
      1 keytool error: java.lang.Exception: Alias <hub-root> does not exist
      1 [] o.apache.tomcat.util.net.SSLHostConfig   : The protocol [TLSv1.3] was added to the list of protocols on the SSLHostConfig named [_default_]. Check if a +/- prefix is missing.
      1 WARNING: Proxy certificate file is not found in secret. Skipping Proxy Certificate Import.
