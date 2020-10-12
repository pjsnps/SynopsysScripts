#!/usr/bin/bash



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
