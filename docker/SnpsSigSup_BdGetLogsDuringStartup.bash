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
          echo -n $mcontainername \| $mcontainerid \|\  ; 
          docker container logs $mcontainerid |& tail -n 1 ; 
      done | column -t -s\| -o '  '
      echo  
      #sleep 2s  
    done 
  ;;
  2)
   echo "full logs from all recently Exited containers"
   docker ps -a | grep Exited | head | while read mdockerpsaout ; do mcontainerid=$(echo "$mdockerpsaout" | cut -d' ' -f1) ; echo $mcontainerid ; docker container logs $mcontainerid |& cat ; done
   ;;

esac
