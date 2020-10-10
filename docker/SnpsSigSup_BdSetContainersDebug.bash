#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdSetContainersDebug.bash
#DATE: Sat Oct 10 15:15:18 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010101515Z
#GREPVCKSUM: TODO 

#PURPOSE:  Push rootLogger.level=all into all applicable containers log4j2.properties files.  Especially useful for troubleshooting Black Duck (Hub) docker swarm startup issues.

#NOTES:  Suggestions welcome.  See REFERENCE below for background, ideas.  

#USAGE:  Intends to be like a single-purpose linux utiltity.  Edit commands as you wish, of course.  
#TODO: add revert back to info level. 
#SnpsSigSup_BdSetContainersDebug.bash info all
#SnpsSigSup_BdSetContainersDebug.bash all info
#[pjalajas@sup-pjalajas-hub docker]$ . ./SnpsSigSup_BdSetContainersDebug.bash info all 



#CONFIG

#SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server


#MAIN

#RUN LOCALLY:
#while true 
  #do docker ps -q | \
  docker ps -q | \
    xargs -I% docker container exec -u0 % \
    find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties # -exec \
    #sed -i "s/rootLogger.level=${1}/rootLogger.level=${2}/g" "%" \;  
    find /opt/blackduck/hub /usr/share/logstash -maxdepth 3 -type f -name log4j2.properties -exec \
    grep "rootLogger.level" "%" \;  
#done \
#2> /dev/null

echo Confirming...
docker container exec -u0 $(docker ps | grep logstash | cut -d' ' -f1) find /var/lib/logstash/data/debug -type f -exec cat "{}" +

#RUN OVER SSH:
#SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server
#echo "Using this connection: $SSH"
#$SSH docker container exec -u0 ___ TODO





exit
#REFERENCE
[pjalajas@sup-pjalajas-hub docker-swarm]$ docker ps -q | xargs -I% docker container exec -u0 % find / -type f -name log4j2.properties # PJHIST
/opt/blackduck/hub/jobrunner/conf/log4j2.properties
/opt/blackduck/hub/hub-webapp/conf/log4j2.properties
/opt/blackduck/hub/hub-scan/conf/log4j2.properties
/opt/blackduck/hub/hub-registration/conf/log4j2.properties
/opt/blackduck/hub/hub-authentication/conf/log4j2.properties
/usr/share/logstash/config/log4j2.properties
