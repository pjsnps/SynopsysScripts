#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetLogsInterlaced_v1.bash 
#DATE: Thu Oct 15 18:31:03 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010151831Z
#GREPVCKSUM: TODO 

#PURPOSE: Gets a container logs, interlaced by timestamp. A work in progress...

#USAGE: #1. TBD
#USAGE: #2. TBD

#NOTES: Takes a few seconds to load because of pipes.  Uses cut -c1-2000 to suppress log line length craziness.  

#TODO: put container id and/or name in output line after timestamp.

#CONFIG
#TODO: make this work:  MGREP=' ".*" '
#TODO: make MGREP work...
#  grep ${MGREP} | \
#nowork: MGREP=" -i -e \"10-15 16:.*Binding .*\(_LINKED. to parameter:\|adjustedValue\=\)\" "
#works: MGREP=" -i -e Binding " 
#MGREP=' -i -e "Binding" '



#MAIN
#echo grep:  ${MGREP}
docker ps -q | \
while read mcontainerid ; 
do 
  #docker ps | \ grep $mcontainerid ; 
  docker container logs $mcontainerid |& \
  grep -i -e "10-15 16:.*Binding .*\(_LINKED. to parameter:\|adjustedValue\=\)" | \
    cut -c1-2000 ; 
done |& 
sort --stable --key=1,2 

exit
#REFERENCE

keeping here for possible reference, probably should just delete it:
case $1 in 
  1)
    echo "Ctrl+s to pause, Ctrl+q to resume, hold down Ctrl+c to quit."
    while true ; do 
      docker ps -q | while read mcontainerid ; do
          mcontainername=$(docker ps |& grep $mcontainerid | cut -d- -f2 | cut -d: -f1)
          mcontainerhealth=$(docker ps | grep $mcontainerid | cut -d\( -f2 | cut -d: -f2 | cut -d\) -f1 | tr -d ' ')
          echo -n $mcontainername \| $mcontainerid \|\  $mcontainerhealth \|\  ; 
          docker container logs $mcontainerid |& cat | tail -n 1 ; 
      done | \
      cut -c1-1000 | \
      column -t -s\| -o '  '
      echo  # a little space between loops
      #sleep 2s  
    done 
  ;;
  2)
   echo "Printing full container logs from all recently Exited containers."
   echo "Consider running SnpsSigSup_BdSetContainersDebug.bash in a tight loop in another shell to force some containers into debug mode before they quickly exit."
   docker ps -a | grep Exited | head | while read mdockerpsaout ; do echo $mdockerpsaout ;  mcontainerid=$(echo "$mdockerpsaout" | cut -d' ' -f1) ; echo $mcontainerid ; docker container logs $mcontainerid |& cat ; echo ; done
   ;;

esac


exit
#REFERENCE
[pjalajas@sup-pjalajas-hub hub]$ docker ps -q | while read mcontainerid ; do docker ps | grep $mcontainerid ; docker container logs $mcontainerid |& grep -i -e "10-15 16:.*Binding .*\(_LINKED. to parameter:\|adjustedValue\=\)" ; 
echo ; done |& sort --stable --key=1,2 | less -inRF                                                                                                                                                                                  
2020-10-15 16:30:58,540Z[GMT] [https-jsse-nio-8443-exec-3] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:31:06,330Z[GMT] [https-jsse-nio-8443-exec-3] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [2]
2020-10-15 16:31:30,361Z[GMT] [https-jsse-nio-8443-exec-8] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:42:11,313Z[GMT] [https-jsse-nio-8443-exec-7] TRACE org.hibernate.type.EnumType - Binding [STATICALLY_LINKED] to parameter: [15]
2020-10-15 16:42:18,580Z[GMT] [https-jsse-nio-8443-exec-7] TRACE org.hibernate.type.EnumType - Binding [STATICALLY_LINKED] to parameter: [2]
2020-10-15 16:42:32,695Z[GMT] [https-jsse-nio-8443-exec-5] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [12]
2020-10-15 16:42:40,962Z[GMT] [https-jsse-nio-8443-exec-5] TRACE org.hibernate.type.EnumType - Binding [DYNAMICALLY_LINKED] to parameter: [2]
