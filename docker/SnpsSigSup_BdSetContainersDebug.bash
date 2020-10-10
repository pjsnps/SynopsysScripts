#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdSetContainersDebug.bash
#DATE: Sat Oct 10 15:15:18 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010101515Z
#GREPVCKSUM: TODO 

#PURPOSE:  Push rootLogger.level=all into all applicable containers log4j2.properties files.  Especially useful for troubleshooting especially odd Black Duck (Hub) docker swarm startup issues.

#NOTES:  Suggestions welcome.  See REFERENCE below for background, ideas.  Indempotent; put in tight while loop to add debug logging to quickly failing containers. 

#USAGE:  Intends to be like a single-purpose linux utiltity.  Edit commands as you wish, of course.  
#USAGE:  Primary use-case:    while true ; do . ./SnpsSigSup_BdSetContainersDebug.bash info all ; done
#Can run on remote server over ssh; ask. 

#TODO: add postgres, logstash, and other containers (they apparently don't use log4j2.properties).

#CONFIG

#TODO: add instruction to copy to SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server; workaround for now: copy this script to remote /tmp then run over ssh


#MAIN

#RUN LOCALLY:
#while true 
  #do docker ps -q | \
  #works:  docker ps -q | xargs -I% docker container exec -u0 % find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties 2> /dev/null
  docker ps -q | \
    xargs -I% \
    docker container exec -u0 % \
    find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties -exec \
      sed -i "s/rootLogger.level=${1}/rootLogger.level=${2}/g" {} \; \
      2> /dev/null 
  docker ps -q | \
    xargs -I% \
    docker container exec -u0 % \
    find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties -exec \
      grep "rootLogger.level" {} \; \
      2> /dev/null
    ## -exec \
    #sed -i "s/rootLogger.level=${1}/rootLogger.level=${2}/g" "%" \;  
    #find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties -exec \
    #grep "rootLogger.level" "%" \;  
#done \
#2> /dev/null

#echo Confirming...
#docker container exec -u0 $(docker ps | grep logstash | cut -d' ' -f1) find /var/lib/logstash/data/debug -type f -exec cat "{}" +

#RUN OVER SSH:
#SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server
#echo "Using this connection: $SSH"
#$SSH docker container exec -u0 ___ TODO





#exit
#REFERENCE
#[pjalajas@sup-pjalajas-hub docker-swarm]$ docker ps -q | xargs -I% docker container exec -u0 % find / -type f -name log4j2.properties # PJHIST
#/opt/blackduck/hub/jobrunner/conf/log4j2.properties
#/opt/blackduck/hub/hub-webapp/conf/log4j2.properties
#/opt/blackduck/hub/hub-scan/conf/log4j2.properties
#/opt/blackduck/hub/hub-registration/conf/log4j2.properties
#/opt/blackduck/hub/hub-authentication/conf/log4j2.properties
#/usr/share/logstash/config/log4j2.properties

#[pjalajas@sup-pjalajas-hub docker]$ . ./SnpsSigSup_BdSetContainersDebug.bash info all 
#rootLogger.level=all
#rootLogger.level=all
#rootLogger.level=all
#rootLogger.level=all
#rootLogger.level=all
#rootLogger.level = ${sys:ls.log.level}
#[pjalajas@sup-pjalajas-hub docker]$ . ./SnpsSigSup_BdSetContainersDebug.bash all info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level = ${sys:ls.log.level}


                                                                                                                          
#[pjalajas@sup-pjalajas-hub docker]$ while true ; do . ./SnpsSigSup_BdSetContainersDebug.bash all info ; done
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level = ${sys:ls.log.level}
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level=info
#rootLogger.level = ${sys:ls.log.level}
                                                                                  
#[pjalajas@sup-pjalajas-hub docker]$ docker ps -q | while read mcid ; do docker ps | grep $mcid ; docker container logs --details $mcid |& grep --color=always TRACE | tail -n 1 ; echo ; done                                                                                                                                                               
#32323a3d1194        blackducksoftware/blackduck-nginx:1.0.23              "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)   80/tcp                         hub_2020_4_1_20201010020514ZSat_webserver.1.pjkkf0q37z6xqiygf9tkglmxv
#43544af589cd        blackducksoftware/blackduck-upload-cache:1.0.13       "/opt/blackduck/hub/…"   11 hours ago        Up 11 hours (healthy)   8086/tcp, 9443/tcp             hub_2020_4_1_20201010020514ZSat_uploadcache.1.n8b3ke7iq7aa97y0acnpvyvo1
#f23ae534fedb        blackducksoftware/blackduck-postgres:1.0.13           "/hub-database.sh po…"   11 hours ago        Up 11 hours (healthy)   5432/tcp                       hub_2020_4_1_20201010020514ZSat_postgres.1.p6ciat5oulwxgnmc0ule4jilv
#1c5481eb4524        blackducksoftware/blackduck-documentation:2020.4.1    "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_documentation.1.uljvnyw4qkv4ydqeoix2c072r
#
#b55c16fe0c42        blackducksoftware/blackduck-jobrunner:2020.4.1        "docker-entrypoint.s…"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_jobrunner.1.bwfb787y7ff6ildz8nbmrsir6
 #2020-10-10 15:54:22,376Z[GMT] [jobTaskScheduler-1] TRACE org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl [] []: Logical connection closed
#
#562af2dbe9e1        blackducksoftware/blackduck-webapp:2020.4.1           "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_webapp.1.n8nz4ec2rwo0r95rguc5obyes
 #2020-10-10 15:54:20,556Z[GMT] [version.bom.engine-0] TRACE org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl - Logical connection closed
#
#ba0f0417bf91        blackducksoftware/blackduck-scan:2020.4.1             "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_scan.1.2nmyfc0fumn5mpnjppwdae13f
 #2020-10-10 15:54:18,248Z[GMT] [Metadata-reload] TRACE org.springframework.security.saml.metadata.MetadataManager - Executing metadata refresh task
#
#2c524a678a86        blackducksoftware/blackduck-registration:2020.4.1     "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_registration.1.3qb78spwkstkl7yi3f3qhwjry
 #2020-10-10 15:54:24,823Z[GMT] [https-jsse-nio-8443-ClientPoller-1] TRACE org.apache.tomcat.util.net.NioEndpoint - timeout completed: keys processed=2; now=1602345264823; nextExpiration=1602345264822; keyCount=0; hasEvents=false; eval=false
#
#4afe18006ad3        blackducksoftware/blackduck-authentication:2020.4.1   "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)                                  hub_2020_4_1_20201010020514ZSat_authentication.1.8bs4z7xukp36z522rqg5yulzq
 #2020-10-10 15:53:58,699Z[GMT] [https-jsse-nio-8443-exec-1] TRACE org.springframework.beans.factory.support.DefaultListableBeanFactory - Returning cached instance of singleton bean 'healthCheckRestServer'
#7bf475bd6bb8        blackducksoftware/blackduck-cfssl:1.0.1               "docker-entrypoint.sh"   11 hours ago        Up 11 hours (healthy)   8888/tcp                       hub_2020_4_1_20201010020514ZSat_cfssl.1.itpwnypz313a1wvjvz1f89ast
#
#809cc900be48        blackducksoftware/blackduck-logstash:1.0.6            "/usr/local/bin/dock…"   11 hours ago        Up 11 hours (healthy)   4560/tcp, 5044/tcp, 9600/tcp   hub_2020_4_1_20201010020514ZSat_logstash.1.njttuhw6vr21m5az6z7aey6g3
