#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetLogsDuringStartup.bash 
#DATE: Mon Oct 12 20:53:19 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010122053Z
#GREPVCKSUM: TODO 

#PURPOSE: Provides different ways to view container logs 

#SnpsSigSup_BdGetLogsDuringStartup.bash 2 | less -inRF

#USAGE: #1. Quick tail -n 1 of each active container.       bash SnpsSigSup_BdGetLogsDuringStartup.bash 1 | less -inRF
#USAGE: #2. Full logs of most recent 10 Exited containers.  bash SnpsSigSup_BdGetLogsDuringStartup.bash 2 | less -inRF

#TODO protect numbers 
#TODO: put container name in output line instead of containerid.  

case $1 in 
  1)
    echo "Ctrl+s to pause, Ctrl+q to resume, hold down Ctrl+c to quit."
    while true ; do 
      docker ps -q | while read mcontainerid ; do
          mcontainername=$(docker ps |& grep $mcontainerid | cut -d- -f2 | cut -d: -f1)
          mcontainerhealth=$(docker ps | grep $mcontainerid | cut -d\( -f2 | cut -d: -f2 | cut -d\) -f1 | tr -d ' ')
          echo -n $mcontainername \| $mcontainerid \|\  $mcontainerhealth \|\  ; 
          docker container logs $mcontainerid |& cat | tail -n 1 ; 
      done | column -t -s\| -o '  '
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
