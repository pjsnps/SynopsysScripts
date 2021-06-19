#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-11
#LICENSE : SPDX Apache-2.0
#VERSION: 2106150152Z
#CHANGES: pj continue add detect logs for package managers

#PURPOSE: A work in progress, under active development; suggestions, corrections welcome!  Help find needle in gigabyte-log haystack.  Input lines from stdin, outputs varying strings redacted.  Removes datestamps, uuids, etc.  For easier comparison, tabulations, etc. See example outputs below under REFERENCE.

#REQUIREMENTS:
# REQ: works with GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)
# REQ: gnu parellel.  Can replace with xargs if desired. 

#USAGE: date --utc ; hostname -f ; pwd ; cat /tmp/alert-april23.text | grep -i -e error -e fatal -e severe -e fail -e wrong -e invalid -e missing -e Exception: -e "(could|does|can) ?not" -e " a problem " -e "not found" -e "timed out" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-300 | sed -re 's/(customername|cstmrnick)/[customer]/gi'                                                                                     
#TODO

#TODO: accumulate fairly long list of strings that indicate error-level issue that may be overlooked because those log lines, for whatever reason, do not contain the string "ERROR".  
#  TODO: grep -i -e"Exception: -e "Caused by" -e error -e fatal -e severe -e fail -e wrong -e invalid -e missing -e "(could|does|can) ?n(o|')t" -e " a problem " -e "not found" -e "timed out" -e time.?out  
#  TODO: learn how to pass grep special characters into grep into gnu parallel.
#TODO:  May want to leave in the first [0-9a-f] (in first few sed -e below; [4d7f6f0d393a] in example above), which I think is the container id.  There is only around 10 of them, and they should generally be the same for the same log lines.  If true, then may instead want to convert it to human-readable container name. 
#TODO:  Refactor,consolidate sed expressions, but maintain readability/supportability. Probably could safely remove half of the first half by improvements learned later as shown in the bottom half. 
#TODO:  Use xargs or gnu parallel on this script for speed? 

#MAIN

while read -r line
do
  echo "$line" | \
    sed -r \
        -e 's/2021.*\[GMT\]~: /[sed33] /g' \
        -e 's/2021-.*\[[0-9a-f].*pool-[0-9]*-thread-[0-9]*\]/[sed35]/g' \
        -e 's/2021-.*(\[[0-9a-f])?.*jobRunner-[0-9]*\]/[sed36]/g' \
        -e 's/2021-.*\[[0-9a-f].*BDSBackgroundRenewalWorker\]/[sed37]/g' \
        -e 's/2021-.*\[[0-9a-f].*kb-api-pool-[0-9]+\]/[sed38]/g' \
        -e 's/2021-.*\[[0-9a-f].*jobTaskScheduler-[0-9]+\]/[sed39]/g' \
        -e 's/2021-.*\[[0-9a-f].*main\]/[sed40-date_main]/g' \
        -e 's/2021-.*(\[[0-9a-f])?.*main\]/[sed41-date_main]/g' \
        -e 's/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/[sed42]/g' \
        -e 's/(hub-[a-z]+_)[A-Za-z0-9]+/\1[sed43]/g' \
        -e 's/HHH[0-9]+/[sed44]/g' \
        -e 's/ duration: [0-9]+\.[0-9]+ / duration: [sed45] /g' \
        -e 's/Ljava.lang.String\;\@[0-9a-f]+\]/Ljava.lang.String;@[sed46] /g' \
        -e 's/ duration: [0-9]+\.[0-9]+E-?[0-9]+ / duration: [sed47] /g' \
        -e 's/ [0-9]+ms/ [sed48]ms/g' \
        -e 's/After [0-9]{1,2} ms./After [sed49] ms./g' \
        -e 's/versionBomId=[0-9]+/versionBomId=[sed50]/g' \
        -e 's/(created|updated)At=20[0-9]{2}-[01][0-9]-[0-3][0-9]T[0-2][0-9](:[0-5][0-9]){2}\.[0-9]*Z/\1At=[sed51]/g' \
        -e 's/\[\] *\[\]/[sed52]/g' \
        -e 's/2021.*\[(warning|error)\] /[sed53] [\1]/g' \
        -e 's/\<[0-9]+\.[0-9]+\.[0-9]+\>/[sed54]/g' \
        -e 's/\.[0-9]+\:[0-9]+/[]/g' \
        -e 's/channel [0-9]+/channel []/g' \
        -e 's/Content-Length:"[0-9]+"/Content-Length:"[]"/g' \
        -e 's/X-BDS-CorrelationID:"[0-9]+"/X-BDS-CorrelationID:"[]"/g' \
        -e 's/Date:".* GMT"/Date:"[] GMT"/g' \
        -e 's/SQL ?State: [0-9A-Z]+/SQL State: []/g' \
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
        -e 's/(enerContainer-|scan-upload-|kb-api-pool-)[0-9]+/\1[]/g' \
        -e 's/(Bearer:? )[0-9a-zA-Z\._-]+/\1[]/g' \
        -e 's/(HikariPool-)[0-9]+/\1[]/g' \
        -e 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) +[0-9]+ ..:..:../[date]/g' \
        -e 's/(collectd|containerd)\[[0-9]+\]/\1[]/g' \
        -e 's/((time|update) ?= ?)[0-9]+\.[0-9]{3}/\1[]/g' \
        -e 's/(bdhub-blackduck-scan-|bdhub-blackduck-jobrunner-|bdhub-blackduck-webapp-logstash-|bdhub-blackduck-registration-|bdhub-blackduck-authentication-)[0-9a-z-]+/\1[]/g' \
        -e 's/....-..-.. ..:..:..,.../[date]/g' \
        -e 's/[0-9a-f]{8}-([0-9a-f-]{4}){3}[0-9a-f]{12}/[uuid]/g' \
        -e 's/pool-[0-9]+-thread-[0-9]+/pool-[]-thread-[]/g' \
        -e 's/data: [0-9]+ files, [0-9]+ projects, [0-9]+ components/data: [int] files, [int] projects, [int] components/g' \
        -e 's/parents: [0-9]+, updates: [0-9]+/parents: [int], updates: [int]/g' \
        -e 's/After [0-9]+ ms./After [int] ms./g' \
        -e 's/[0-9]+\.[0-9]+( sec after start)/[float]\1/g' \
        -e 's/(nodeId=)[0-9]+/\1[int]/g' \
        -e 's/(clientPath=).*/\1[path]/g' \
        -e 's/requested=[0-9]+, # processed=[0-9]+, # successes=[0-9]+, # failures=[0-9]+/requested=[int], # processed=[int], # successes=[int], # failures=[int]/g' \
        -e 's/=[0-9]+,?/=[i],/g' \
        -e 's/(update )[0-9]+/\1[i]/g' \
        -e 's/(roots:|time:) [0-9]+/\1 [i]/g' \
        -e 's#(name=|baseDir=).*?,#\1=[path]#g' \
        -e 's/(Name:) .*?\|/\1 [name] |/g' \
        -e 's/notifications: [0-9]+ | Total number of audit events: [0-9]+ | Latest timestamp: [0-9]+ | Latest audit event id: [0-9]+\]/notifications: [i] | Total number of audit events: [i] | Latest timestamp: [i] | Latest audit event id: [i]]/g' \
        -e 's/id: [0-9]+ | Number of events pruned: [0-9]+ in .:..:..\..../id: [i] | Number of events pruned: [i] in [t]/g' \
        -e 's/(ConnectionHolder@)[0-9a-f]+/\1[sed113]/g' \
        -e 's/[0-9]+( bytes data)/[sed114]\1/g' \
        -e 's/(http-outgoing-)[0-9]+/\1[sed115]/g' \
        -e 's/.[0-9]+ - /.[sed116i] - /g' \
        -e 's/(Closing connection )[0-9]+/\1[sed117i]/g' \
        -e 's/(Length: )[0-9]+/\1[sed118i]/g' \
        -e 's/(Sun|Mon|Tue|Wed|Thu|Fri|Sat), [0-9]+/[sed119a], [sed119d]/g' \
        -e 's/[0-9]+ out of [0-9]+ bytes/[sed120i] out of [sed120i] bytes/g' \
        -e 's/("scanTime":)[0-9]+,("timeLastModified":)[0-9]+,/\1[sed121i],\2[sed121i],/g' \
        -e 's/("numDirs":)[0-9]+,/\1[sed119i],/g' \
        -e 's/("numNonDirFiles":)[0-9]+,/\1[sed120i],/g' \
        -e 's/("scanType":"FS","name":)".*?",/\1"[sed121a]",/g' \
        -e 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) +[0-9]+, 20[0-9]{2} .+:..:.. [AaPp]M/[sed122-date]/g' \
        -e 's/20..-..-.. ..:..:.. UTC/[sed123-date]/g' \
        -e 's/-[0-9]+-[0-9]+-[0-9]+-build/[sed124-ver]-build/g' \
        -e 's/SBT-[0-9]+/SBT-[i]/g' \
        -e 's/[0-9]+ of [0-9]+ \([0-9]+%\)/[i] of [i] ([i]%)/g' \
        -e "s/(Executing command .bitbake -g ).*?(. returned a non-zero exit code )[0-9]+/\1[sed127-pkgname]\2[sed127-i]/g" \
        -e "s/(Failed to extract a Code Location while running Bitbake against package .).*?/\1[sed128-pkgname]\'/g" \
        -e 's/(npm ERR.*missing. ).*?(, required by ).*/\1[sed129-pkgname]\2[sed129-pkgname]/g' \
        -e 's#(npm ERR. extraneous: ).*#\1[sed130_pkg_path]#g' \
        -e 's#(npm ERR. invalid: ).*#\1[sed131_pkg_path]#g' \

#     10 npm ERR! missing: b@file:../b, required by a@[sed54]
#     10 [sed41] --- npm ERR! missing: b@^[sed54], required by a@[sed54]
#     10 [sed41] --- npm ERR! missing: feed@[sed54], required by extraneous-node-modules



        #keep at least one blank line above this one
#TODO: [bd.corp.[customer].com/[].28]  
done


exit
#REFERENCE


example:
Download system log file .zip from Black Duck web ui (or command line?), unzip it, then find app-log files on date of interest, and summarize them:
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ find /tmp/bdhub-rtp02_bds_logs-20210428T195934 | grep app-log.*04-26 | parallel grep -i -e error -e fatal -e fail -e severe -e cannot -e time.?out -e exception: | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c 1-300 
     73 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.scan.bom.api.CodeNodeMatch []: Detected NULL BomEvidenceNode for: CodeNodeMatch{nodeId=[int], clientPath=[path]
     49 at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:92) [tomcat-embed-core-[].jar!/:[]]
     46 com.blackducksoftware.core.validation.ValidationException: Unable to read report contents because it has not finished the report building process.
     42 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=NO_ACTIVITIES_FOUND, kbUpdateTaskType=COMPONENT, # requested=[int], # processed=[int], # successes=[int], # failures=[int], fai
     42 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=NO_ACTIVITIES_FOUND, kbUpdateTaskType=LICENSE, # requested=[int], # processed=[int], # successes=[int], # failures=[int], failu
     37 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=NO_ACTIVITIES_FOUND, kbUpdateTaskType=NVD_VULNERABILITY, # requested=[int], # processed=[int], # successes=[int], # failures=[i
     35 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=NO_ACTIVITIES_FOUND, kbUpdateTaskType=BDSA_VULNERABILITY, # requested=[int], # processed=[int], # successes=[int], # failures=[
     31 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=NO_ACTIVITIES_FOUND, kbUpdateTaskType=COMPONENT_VERSION, # requested=[int], # processed=[int], # successes=[int], # failures=[i
     11 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=SUCCESS, kbUpdateTaskType=COMPONENT_VERSION, # requested=[int], # processed=[int], # successes=[int], # failures=[int], failure
      7 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=SUCCESS, kbUpdateTaskType=BDSA_VULNERABILITY, # requested=[int], # processed=[int], # successes=[int], # failures=[int], failur
      5 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.kb.integration.domain.impl.KbUpdateTaskChain []: Completed a task: ActivityUpdateResults{overallResult=SUCCESS, kbUpdateTaskType=NVD_VULNERABILITY, # requested=[int], # processed=[int], # successes=[int], # failures=[int], failure
      4 [bdhub-blackduck-registration-[]] [date]Z[GMT] [pool-[]-thread-[]] INFO  com.blackducksoftware.common.client.util - Command[[Ljava.lang.String;@[]  threw[java.io.IOException: Cannot run program "lsb_release": error=2, No such file or directory]
      2 at org.postgresql.core.v3.QueryExecutorImpl.receiveErrorResponse(QueryExecutorImpl.java:2497) ~[postgresql-[].jar!/:[]]
      2 [bdhub-blackduck-jobrunner-[]] [date]Z[GMT] [kb-api-pool-[]] INFO  com.blackducksoftware.kb.match.client.KbMatchRestClientRetryPolicy []: Retrying on exception: class org.springframework.web.client.ResourceAccessException. Retry count: 1
      2 Caused by: org.hibernate.exception.SQLGrammarException: could not extract ResultSet
      2 Caused by: org.postgresql.util.PSQLException: ERROR: syntax error at or near ")"
      2 org.springframework.dao.InvalidDataAccessResourceUsageException: could not extract ResultSet; SQL [n/a]; nested exception is org.hibernate.exception.SQLGrammarException: could not extract ResultSet
      1 at reactor.core.publisher.FluxOnErrorResume$ResumeSubscriber.onNext(FluxOnErrorResume.java:73) ~[reactor-core-[].RELEASE.jar:[].RELEASE]
      1 [bdhub-blackduck-jobrunner-[]] [date]Z[GMT] [kb-api-pool-[]] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient []: Exception in getBestMatches(signatureVersion, projectDescriptor). After [int] ms.
      1 [bdhub-blackduck-jobrunner-[]] [] ERROR com.blackducksoftware.core.security.impl.RunAsService []: runasservice
      1 [bdhub-blackduck-jobrunner-[]] [] ERROR com.blackducksoftware.job.core.api.execution.TaskStateNotifier []: Failed JobInstance{ID=[], Status=FAILED, Assigned worker=jobrunner_bdhub-blackduck-jobrunner-[], Scheduled at=[]Z, Error text=Error in job execution: reactor.core.Exceptions$ReactiveExc
      1 [bdhub-blackduck-jobrunner-[]] [] ERROR com.blackducksoftware.scan.bom.job.ScanAutoBomJob []: Scan auto BOM job failed [Scan id: [] | Message: java.lang.RuntimeException: reactor.core.Exceptions$ReactiveException: java.util.concurrent.TimeoutException: Did not observe any item or terminal si
      1 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.scan.siggen.impl.ScannerApi []: ScanId [] updated to status ERROR [float] sec after start (msg: java.lang.RuntimeException: reactor.core.Exceptions$ReactiveException: java.util.concurrent.TimeoutException: Did not observe any item
      1 [bdhub-blackduck-jobrunner-[]] [] INFO  com.blackducksoftware.scan.siggen.impl.ScannerApi []: ScanId [] updated to status ERROR [float] sec after start (msg: reactor.core.Exceptions$ReactiveException: java.util.concurrent.TimeoutException: Did not observe any item or terminal signal within [
      1 [bdhub-blackduck-registration-[]] [date]Z[GMT] [BDSBackgroundRenewalWorker] INFO  com.blackducksoftware.common.client.util - Command[[Ljava.lang.String;@[]  threw[java.io.IOException: Cannot run program "lsb_release": error=2, No such file or directory]
      1 [bdhub-blackduck-scan-[]] [] ERROR org.apache.catalina.core.ContainerBase.[Tomcat].[localhost].[/].[scan-api-mvc] - Servlet.service() for servlet [scan-api-mvc] in context with path [] threw exception
      1 [bdhub-blackduck-webapp-logstash-[]] [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Exception stack trace:
      1 [bdhub-blackduck-webapp-logstash-[]] [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Handling exception for url: 'https://bdhub-rtp02.customer.com/api/projects/[]/versions/[]/source-trees', logRef: 'hub-webapp_[]', locale: 'en_US', msg: could not extract ResultSet; 
      1 [bdhub-blackduck-webapp-logstash-[]] [] ERROR org.hibernate.engine.jdbc.spi.SqlExceptionHelper - ERROR: syntax error at or near ")"
      1 [bdhub-blackduck-webapp-logstash-[]] [] WARN  com.blackducksoftware.core.validation.db.impl.DbConstraintAspect - Handling DB Constraint error: could not extract ResultSet; SQL [n/a]; nested exception is org.hibernate.exception.SQLGrammarException: could not extract ResultSet, args: [[]]
      1 [bdhub-blackduck-webapp-logstash-[]] [] WARN  com.blackducksoftware.core.validation.db.impl.DbConstraintViolationRetriever - Constraint name retrieval results [Name: null | Original class: org.postgresql.util.PSQLException | Message: ERROR: syntax error at or near ")"
      1 [bdhub-blackduck-webapp-logstash-[]] [] WARN  org.hibernate.engine.jdbc.spi.SqlExceptionHelper - SQL Error: 0, SQL State: []
      1 Caused by: java.net.SocketTimeoutException: Read timed out
      1 Caused by: java.util.concurrent.TimeoutException: Did not observe any item or terminal signal within []ms (and no fallback has been configured)
      1 Caused by: reactor.core.Exceptions$ReactiveException: java.util.concurrent.TimeoutException: Did not observe any item or terminal signal within []ms (and no fallback has been configured)
      1 java.lang.NullPointerException: null
      1 java.lang.RuntimeException: reactor.core.Exceptions$ReactiveException: java.util.concurrent.TimeoutException: Did not observe any item or terminal signal within []ms (and no fallback has been configured)
      1 org.springframework.web.client.ResourceAccessException: I/O error on POST request for "https://kb.blackducksoftware.com:443/kbmatch/api/v1/matches/best": Read timed out; nested exception is java.net.SocketTimeoutException: Read timed out
      1 Suppressed: java.lang.Exception: #block terminated with an error








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
