#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-11
#LICENSE : SPDX Apache-2.0
#VERSION: 20210422T0322ZPJ
#CHANGES: pj add new redactions, 2021.2.1 startup all spurious, from docker container logs, no container id, journalctl

#PURPOSE: Inputs lines from stdin, outputs lines with varying content deleted.  Removes datestamps, uuids, etc.  For easier comparison, tabulations, etc. 

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond

#TODO:  May want to leave in the first [0-9a-f] (in first few sed -e below; [4d7f6f0d393a] in example above), which I think is the container id.  There is only around 10 of them, and they should generally be the same for the same log lines.  If true, then may instead want to convert it to human-readable container name. 

#2021-04-22 03:07:37,110Z[GMT] [main] INFO  org.hibernate.engine.jdbc.env.internal.LobCreatorBuilderImpl - []: Disabling contextual LOB creation as createClob() method threw error : java.lang.reflect.InvocationTargetException
#2021-04-22 03:11:03,898Z[GMT] [https-jsse-nio-8443-exec-4] ERROR 
#2021-04-22 03:07:09.467 [warning] <0.326.0>
#2021-04-22 03:08:20.706 [error] <[]> Channel error on connection <[]> ([].38:46634 -> [].19:5671, vhost: 'blackduck', user: 'sysadmin'), channel 1:
#2021-04-22 03:11:37,686Z[GMT] [jobRunner-2] 
#      1 [] WARN  com.blackducksoftware.core.rest.client.RestLoggerInterceptor.KBJSON []: Error 401 UNAUTHORIZED "" POST https://kb.blackducksoftware.com:443/api/feedback request headers=[Accept:"application/json, application/vnd.blackducksoftware.kb.activity-2+json, application/vnd.blackducksoftware.kb.activity-3+json, application/vnd.blackducksoftware.kb.component.details-3+json, application/vnd.blackducksoftware.kb.component.details-4+json, application/vnd.blackducksoftware.kb-feedback-event-1+json, application/vnd.blackducksoftware.kb.summary-1+json, application/vnd.blackducksoftware.kb.vulnerability-6+json, application/vnd.blackducksoftware.kb.summary-2+json, application/vnd.blackducksoftware.kb.vulnerability-5+json, application/vnd.blackducksoftware.kb.snippet-1+json, application/*+json", Content-Type:"application/vnd.blackducksoftware.kb-feedback-event-1+json", Content-Length:"5218", X-BDS-CorrelationID:"1619061887684", Authorization:"[REDACTED]", Cookie:"AUTHORIZATION_BEARER=[REDACTED]"] response headers=[Server:"nginx", Date:"Thu, 22 Apr 2021 03:24:47 GMT", Content-Type:"application/json;charset=ISO-8859-1", Content-Length:"145", Connection:"keep-alive", X-Content-Type-Options:"nosniff", X-XSS-Protection:"1; mode=block", Cache-Control:"no-cache, no-store, max-age=0, must-revalidate", Pragma:"no-cache", Expires:"0", X-Frame-Options:"DENY"] in []ms
# [] WARN  org.flywaydb.core.internal.sqlscript.DefaultSqlScriptExecutor []: DB: column "cvss3_temporal_subscore" of relation "vuln_summary" already exists, skipping (SQL State: 42701 - Error Code: 0)
#ERROR state 42704 means
#SQL State: []P07
#when status=6
#Apr 22 00:09:03 sup-pjalajas-hub.dc1.lan dockerd[113737]: time="2021-04-22T00:09:03.491918894-04:00" 


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

#VOLUME 202121_04220008_rabbitmq-data-volume /var/lib/rabbitmq false DEFAULT nil Mount_VolumeOptions{NoCopy:false,Labels:map[string]string{com.docker.stack.namespace: 202121_04220008,
#Name:202121_04220008_rabbitmq
#blackducksoftware/rabbitmq
#sha256:47aa293c311c4bc618d98a903644085ead40d7a4ce2afaaaf507bb06901bdc78
#ID:o5gxweq9t22386id3kr89wyim,Meta:Meta{Version:Version{Index:405165,},CreatedAt:2021-04-22T04:09:04.475817556Z,UpdatedAt:2021-04-22T04:09:04.542164244Z

        #keep a blank line above this one
done


exit
#REFERENCE
: '
      1 2021-03-16 23:00:43,427Z[GMT]~: Caused by: org.apache.http.NoHttpResponseException: kb.blackducksoftware.com:443 failed to respond

[pjalajas@sup-pjalajas-hub N00855538_FailedToRespond]$ time (parallel 'cat {} | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-16 " "2021-03-16 " | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash' ::: ./blackduck-staging_bds_logs-20210316T233214/*/app-log/2021-03-16.log | parallel 'echo {} | grep -E -e "(Exception:|ERROR)"' | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-1000 ) # PJHIST LumberMill
     98 [] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient [] []: Exception in getMatches(signatureVersion, nodeSignatures) making Rest Request. After [] ms.
     75 [] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient [] []: Exception in getBestMatches(signatureVersion, projectDescriptor). After [] ms.
     40 [] WARN  com.blackducksoftware.usermgmt.ldap.app.impl.LdapAuthenticator - Unable to authenticate LDAP user [External user name: sysadmin | Message: LdapCallback;null; nested exception is javax.naming.PartialResultException [Root exception is javax.naming.CommunicationException: hq.customer.com:636 [Root exception is java.net.SocketTimeoutException: connect timed out]]; nested exception is org.acegisecurity.ldap.LdapDataAccessException: LdapCallback;null; nested exception is javax.naming.PartialResultException [Root exception is javax.naming.CommunicationException: hq.customer.com:636 [Root exception is java.net.SocketTimeoutException: connect timed out]] | LDAP message: LdapMessage{Code={blackduck.usermgmt.ldap.invalid.credentials}, Argument names=[]}]
     30 [] INFO  com.blackducksoftware.common.client.util - Command[[Ljava.lang.String;@[]  threw[java.io.IOException: Cannot run program "lsb_release": error=2, No such file or directory]
      7 [] INFO  com.blackducksoftware.registration.main.impl.RegistrationContainerApi - Refresh registration operation completed: RegistrationMetadata{Registration id=customer_hub_failover_0013000000DRfJn, Registration state=Invalid, Service status=Registration is in use by another system. Invalid system ID 'registration__4', License usage window date=Wed Nov 11 18:16:22 GMT 2020, Warning license expiration date=Sat Oct 01 23:59:59 GMT 2022, License expiration date=Mon Oct 31 23:59:59 GMT 2022, Registration message list=[RegistrationMessage{Registration message code=REFRESH_REGISTRATION_ERROR, Message=Optional.absent()}], Registration attribute map={PROJECT_RELEASE_LIMIT=RegistrationAttribute{Attribute=PROJECT_RELEASE_LIMIT, Soft value=Optional.absent(), Hard value=Optional.absent()}, CODEBASE_MANAGED_LINES_OF_CODE=RegistrationAttribute{Attribute=CODEBASE_MANAGED_LINES_OF_CODE, Soft value=Optional.absent(), Hard value=Optional.absent()}, CODE_LOCATION_LIMIT=
      7 [] INFO  com.blackducksoftware.registration.main.impl.RegistrationRefresher - Refreshed registration: RegistrationMetadata{Registration id=customer_hub_failover_0013000000DRfJn, Registration state=Invalid, Service status=Registration is in use by another system. Invalid system ID 'registration__4', License usage window date=Wed Nov 11 18:16:22 GMT 2020, Warning license expiration date=Sat Oct 01 23:59:59 GMT 2022, License expiration date=Mon Oct 31 23:59:59 GMT 2022, Registration message list=[RegistrationMessage{Registration message code=REFRESH_REGISTRATION_ERROR, Message=Optional.absent()}], Registration attribute map={PROJECT_RELEASE_LIMIT=RegistrationAttribute{Attribute=PROJECT_RELEASE_LIMIT, Soft value=Optional.absent(), Hard value=Optional.absent()}, CODEBASE_MANAGED_LINES_OF_CODE=RegistrationAttribute{Attribute=CODEBASE_MANAGED_LINES_OF_CODE, Soft value=Optional.absent(), Hard value=Optional.absent()}, CODE_LOCATION_LIMIT=RegistrationAttribute
      4 [] ERROR com.blackducksoftware.core.regupdate.impl.RegistrationApi [] []: Unable to execute remote registration request [Action: check | Registration id: null | URL: https://registration:8443/registration/HubRegistration]: I/O error on POST request for "https://registration:8443/registration/HubRegistration": registration; nested exception is java.net.UnknownHostException: registration
      2 [] ERROR com.blackducksoftware.core.regupdate.impl.RegistrationApi - Unable to execute remote registration request [Action: check | Registration id: null | URL: https://registration:8443/registration/HubRegistration]: I/O error on POST request for "https://registration:8443/registration/HubRegistration": registration; nested exception is java.net.UnknownHostException: registration
      2 [] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient [] []: Exception in getBestMatches(signatureVersion, projectDescriptor). After 150008 ms.
      1 [] ERROR com.blackducksoftware.core.regupdate.impl.RegistrationApi - Unable to execute remote registration request [Action: check | Registration id: null | URL: https://registration:8443/registration/HubRegistration]: I/O error on POST request for "https://registration:8443/registration/HubRegistration": registration: Name does not resolve; nested exception is java.net.UnknownHostException: registration: Name does not resolve
      1 [] ERROR com.blackducksoftware.core.regupdate.impl.RegistrationApi [] []: Unable to execute remote registration request [Action: check | Registration id: null | URL: https://registration:8443/registration/HubRegistration]: I/O error on POST request for "https://registration:8443/registration/HubRegistration": registration: Name does not resolve; nested exception is java.net.UnknownHostException: registration: Name does not resolve
      1 [] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient [] []: Exception in getBestMatches(signatureVersion, projectDescriptor). After 149998 ms.
      1 [] ERROR com.blackducksoftware.kb.match.client.KbMatchRestClient [] []: Exception in getBestMatches(signatureVersion, projectDescriptor). After 150002 ms.
      1 [] ERROR com.kvasar.flexobject.application - Driver class not found[org.postgresql.Driver]

real    7m21.200s
user    10m4.293s
sys     12m27.994s


failed to redact:
kb-api-pool-10,  jobTaskScheduler, main

      1 2021-03-16 13:54:15,968Z[GMT] : [26e268a33a80] 2021-03-16 13:54:15,968Z[GMT] [BDSBackgroundRenewalWorker] INFO  com.blackducksoftware.common.client.util - Command[[Ljava.lang.String;@4b5669f3] threw[java.io.IOException: Cannot run program "lsb_release": error=2, No such file or directory]



[pjalajas@sup-pjalajas-hub N00854173_2020120Performance]$ time (parallel 'cat {} | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash "2021-03-04 20:" "2021-03-04 21:" | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash' ::: ./blackduck_bds_logs-20210309T023325.zip.expanded/standard/*/app-log/2021-03-04.log | parallel 'echo {} | grep -E -e "(NullP|ERROR)"' | bash /home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_RedactSed.bash | sort | uniq -c | sort -k1nr | cut -c1-500 ) # PJHIST LumberMill
     33 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Exception stack trace:
     32 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Handling exception for url: 'https://blackduck.eng.customer.com/api/projects/[]/versions/[]/bom-status', logRef: 'hub-webapp_[]', locale: 'en_US', msg: at index 2
      1 [] ERROR com.blackducksoftware.core.rest.server.RestExceptionViewConverter - Handling exception for url: 'https://blackduck.eng.customer.com/api/projects/[]/versions/[]/components/[]/versions/[]', logRef: 'hub-webapp_[]', locale: 'en_US', msg: Batch update returned unexpected row count from update [0]; actual row count: 0; expected: 1
      1 [] ERROR com.blackducksoftware.core.security.impl.RunAsService - runasservice
      1 [] ERROR org.hibernate.engine.jdbc.batch.internal.BatchingBatch - []: Exception executing batch [org.hibernate.StaleStateException: Batch update returned unexpected row count from update [0]; actual row count: 0; expected: 1], SQL: delete from ST.component_adjustment where id=?

real    6m45.166s
user    9m12.352s
sys     11m46.227s
'
