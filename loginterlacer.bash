#!/usr/bin/env bash

#SCRIPT:     loginterlacer.bash
#AUTHOR:     pjalajas@synopsys.com
#LICENSE:    SPDX Apache-2.0
#CREATED:    2020-08-05          # 
#VERSION:    2008051927Z         # :! date -u +\%y\%m\%d\%H\%MZ
#GREPVCKSUM: ____ # :! grep -v grepvcksum <script> | cksum

#PURPOSE:    To be able to combine several different logs, with diffferent timestamp formats (ugh), sorted by timestamp. 

#USAGE: See REFERENCE section at bottom of this script.
#USAGE: For now, cat your logs and pipe them through this script. 
#USAGE: Edit CONFIGs, then:
#USAGE: bash __ | less -inRF  
#USAGE: Presumes UTC unless proven otherwise. 
#TODO: ____ 

#CONFIG
minsago=50 # how far back to look in logs

#FUNCTIONS

usage() {
echo pipe your log contents into this script
}
help_wanted() {
    [ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]
}

  if help_wanted "$@"; then
    usage
    exit 0
  fi

#INIT
set -o errexit # exit immediately when it encounters a non-zero exit code
set -o nounset # exit if an attempt is made to expand an unset variable
#date ; date --utc ; hostname -f ; pwd ; whoami ; 

#MAIN
#Format 1: 2020/08/05 19:48:10 [INFO] 
#Format 2: 2020-08-05 19:28:59,494Z[GMT] [main] INFO 
while read line
do
  echo "$line" 
done < "${1:-/dev/stdin}" |& \
  grep \
    -e "$(date --utc -d "${minsago} minutes ago" +%y/%m/%d\ %H:%M)" \
    -e "$(date --utc -d "${minsago} minutes ago" +%Y/%m/%d\ %H:%M)" \
    -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" \
    -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" \
    -e "[0-9]{2,4}/[0-9]{2}/[0-9]{2}" \
  |& \
  sed \
    -re 's#([A-Z][a-z]{2} [0-9]{2}, [2020]{4} [0-9]{1,2}(:[0-9]{2}){2} [AP]M)#date -d "\1" +%Y-%m-%dT%H:%M:%S#ge' \
    -e  's#(....)/(..)/(..) (..:..:..)#\1-\2-\3T\4#g' \
    -e  's/(....-..-..) (..:..:..),(...Z....)/\1T\2.\3/g' \
    -e  's/(....-..-..) (..:..:..)/\1T\2/g' \
  |& \
  sort -k1 
exit

#REFERENCE
put notes here

Get all logs from all containers, even Exited ones:
docker ps -a | grep -v -e _Exited | grep -v -e CONTAINER | cut -d\  -f1 | while read mcontainerid ; do docker container logs $mcontainerid 

[pjalajas@sup-pjalajas-hub loginterlacer]$ echo 'docker ps -a | grep -v -e CONTAINER -e "REMOVEMEExited" | cut -d\  -f1 | while read mcontainerid ; do docker container logs $mcontainerid |& tail -n 100000 ; done |& cat ' |& ssh sup-pjalajas-2 |& ./loginterlacer.bash |& tail -n 20
2020-08-06T00:25:40 [INFO] 10.0.4.4:33998 - "POST /api/v1/cfssl/newcert" 200
2020-08-06T00:25:40 [INFO] encoded CSR
2020-08-06T00:25:40 [INFO] signed certificate with serial number 505369692567912129068733055605721174336597316417
2020-08-06T00:25:43 [INFO] 10.0.4.4:53618 - "POST /api/v1/cfssl/info" 200
2020-08-06T00:25:43 [INFO] 10.0.4.4:53620 - "POST /api/v1/cfssl/newcert" 200
2020-08-06T00:25:43 [INFO] encoded CSR
2020-08-06T00:25:43 [INFO] generate received request
2020-08-06T00:25:43 [INFO] generate received request
2020-08-06T00:25:43 [INFO] generating key: rsa-2048
2020-08-06T00:25:43 [INFO] generating key: rsa-2048
2020-08-06T00:25:43 [INFO] received CSR
2020-08-06T00:25:43 [INFO] received CSR
2020-08-06T00:25:43 [INFO] request for CSR
2020-08-06T00:25:43 [INFO] request for CSR
2020-08-06T00:25:43 [INFO] signed certificate with serial number 65236526683108830793957119168151600112393129700
2020-08-06T00:25:44 [INFO] 10.0.4.4:53622 - "POST /api/v1/cfssl/newcert" 200
2020-08-06T00:25:44 [INFO] encoded CSR
2020-08-06T00:25:44 [INFO] signed certificate with serial number 590619964242665288316125365022324421360447051750
2020-08-06T00:25:52 [INFO] 127.0.0.1:47270 - "GET /api/v1/cfssl/scaninfo" 200
2020-08-06T00:25:52 [INFO] setting up scaninfo handler








       -e "$(date --utc -d "${minsago} minutes ago" +%y/%m/%d\ %H:%M)" \
       -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" \
       -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" \
       -e "2020/08/05" \
       -e "2020" \
       -e "interlacerfilterhere" 
[pjalajas@sup-pjalajas-2 docker-swarm]$ echo Aug 05, 2020 7:04:21 PM | sed -re 's#([A-Z][a-z]{2} [0-9]{2}, [2020]{4} [0-9]{1,2}(:[0-9]{2}){2} [AP]M)#date -d "\1" +%Y-%m-%dT%H:%M:%S#ge'
2020-08-05T19:04:21


d
]$ docker ps -a | grep -v -e _Exited | grep -v -e CONTAINER | cut -d\  -f1 | while read mcontainerid ; do docker container logs $mcontainerid ; done | head
Sending Logstash's logs to /usr/share/logstash/logs which is now configured via log4j2.properties
[2020-07-24T20:07:55,748][INFO ][logstash.modules.scaffold] Initializing module {:module_name=>"fb_apache", :directory=>"/usr/share/logstash/modules/fb_apache/configuration"}
[2020-07-24T20:07:55,751][INFO ][logstash.modules.scaffold] Initializing module {:module_name=>"netflow", :directory=>"/usr/share/logstash/modules/netflow/configuration"}
[2020-07-24T20:07:55,961][INFO ][logstash.modules.scaffold] Initializing module {:module_name=>"arcsight", :directory=>"/usr/share/logstash/vendor/bundle/jruby/1.9/gems/x-pack-5.6.8-java/modules/arcsight/configuration"}
[2020-07-24T20:07:55,968][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.queue", :path=>"/usr/share/logstash/data/queue"}
[2020-07-24T20:07:55,969][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.dead_letter_queue", :path=>"/usr/share/logstash/data/dead_letter_queue"}
[2020-07-24T20:07:55,988][INFO ][logstash.agent           ] No persistent UUID file found. Generating new UUID {:uuid=>"bf70df24-6dd0-4fe3-9481-b0c4bc94b506", :path=>"/usr/share/logstash/data/uuid"}
[2020-07-24T20:07:56,294][INFO ][logstash.pipeline        ] Starting pipeline {"id"=>"main", "pipeline.workers"=>8, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>5, "pipeline.max_inflight"=>1000}
[2020-07-24T20:07:56,702][INFO ][logstash.inputs.beats    ] Beats inputs: Starting input listener {:address=>"0.0.0.0:5044"}
[2020-07-24T20:07:56,736][WARN ][logstash.inputs.log4j    ] This plugin is deprecated. Please use filebeat instead to collect logs from log4j applications.


[pjalajas@sup-pjalajas-2 docker-swarm]$ echo Aug 05, 2020 7:04:21 PM | sed -re 's#([A-Z][a-z]{2} [0-9]{2}, [2020]{4} [0-9]{1,2}(:[0-9]{2}){2} [AP]M)#date -d "\1" +%Y-%m-%dT%H:%M:%S#ge' # PJHIST loginterlacer                                                                                                                                             
2020-08-05T19:04:21
[pjalajas@sup-pjalajas-2 docker-swarm]$ minsago=5 ; docker ps -a | grep -v -e _Exited | grep -v -e CONTAINER | cut -d\  -f1 | while read mcontainerid ; do docker container logs $mcontainerid |& grep -A999999999 -e "$(date --utc -d "${minsago} minutes ago" +%y/%m/%d\ %H:%M)" -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" ; done |& grep -v -e "ignoreme's here" |& sed -re 's#(....)/(..)/(..) (..:..:..)#\1-\2-\3T\4#g' |& sed -re 's/(....-..-
..) (..:..:..),(...Z....)/\1T\2.\3/g' |& sed -re 's/(....-..-..) (..:..:..)/\1T\2/g' |& grep -v -e "\.\.\..* more" -e "^\s*$" |& sort -t\. -k1 |& less -inRF                  
[pjalajas@sup-pjalajas-2 docker-swarm]$ minsago=5 ; docker ps -a | grep -v -e _Exited | grep -v -e CONTAINER | cut -d\  -f1 | while read mcontainerid ; do docker container logs $mcontainerid |& grep -A999999999 -e "$(date --utc -d "${minsago} minutes ago" +%y/%m/%d\ %H:%M)" -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" -e "$(date --utc -d "${minsago} minutes ago" +%Y-%m-%d\ %H:%M)" ; done |& grep -v -e "ignoreme's here" |& sed -re 's#(....)/(..)/(..) (..:..:..)#\1-\2-\3T\4#g' |& sed -re 's/(....-..-..) (..:..:..),(...Z....)/\1T\2.\3/g' |& sed -re 's/(....-..-..) (..:..:..)/\1T\2/g' |& grep -v -e "\.\.\..* more" -e "^\s*$" |& sort -t\. -k1 |& less -inRF
