#!/bin/bash
#Monitoring.bash
#DATE: 2019-06-06
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#VERSION: 20190606

#USAGE: [pjalajas@sup-pjalajas-hub performance]$ sudo ./Monitoring.bash | tee -a log/Monitoring.bash_$(date +%Y%m%d).out
#USAGE: [pjalajas@sup-pjalajas-hub performance]$ while true ; do sudo ./Monitoring.bash | tee -a log/Monitoring.bash_$(date +%Y%m%d).out ; sleep 15s ; done
#USAGE: [pjalajas@sup-pjalajas-hub performance]$ while true ; do sudo ./Monitoring.bash | tee /dev/tty | gzip -9 >> log/Monitoring.bash_$(date +%Y%m%d).out.gz ; sleep 15s ; done



LOGDATECMD='date --utc +%Y%m%d_%H%M%S%Z%a'
echo
echo $($LOGDATECMD) : Start 
#echo
#uptime
echo
echo $($LOGDATECMD) : uptime : $(uptime)
echo
free -g
echo
echo $($LOGDATECMD) : free -g : $(free -g)
echo
#echo $($LOGDATECMD) : top : $(top -n1 -b | head -n 5)
top -n1 -b | head -n 10
echo
echo $($LOGDATECMD) : top : $(top -n1 -b | head -n 5)
echo
echo $($LOGDATECMD) : iostat :
iostat | cut -c1-150
echo
echo $($LOGDATECMD) : iostat -y :
echo
iostat -y | cut -c1-150
echo
echo $($LOGDATECMD) : iostat TODO:FIXME: $(iostat | cut -c1-150)
echo
echo $($LOGDATECMD) : iostat -y : $(iostat -y | cut -c1-150)
echo
iotop -b -n1 -d5 | head -n 8 | cut -c1-150
echo
echo $($LOGDATECMD) : iotop : $(iotop -b -n1 -d5 | head -n 2)
echo
echo $($LOGDATECMD) : postgres ps : 
echo
ps auxww | grep -v grep | grep postgres | cut -c 1-200 | grep -v -e "idle$" -e "process\s*$"
echo
echo $($LOGDATECMD) : docker ps wc : $(sudo docker ps | wc -l)
echo
#sudo docker ps   -- get this below now
#echo
echo $($LOGDATECMD) : java ps : 
echo
ps auxww | grep -v grep | grep java | cut -c 1-200 
echo
top -n1 -b | head -n 20
echo
echo $($LOGDATECMD) : java Xmx TODO:FIXME : 
echo
ps auxww | grep -v grep | grep -Po "\-Xmx.*? "  #TODO get command fragment
echo
echo $($LOGDATECMD) : docker log errors : 
for mimage in nginx solr registration jobrunner webapp logstash zookeeper scan authentication postgres cfssl upload documentation ; do sudo docker logs $(sudo docker ps | grep $mimage | cut -d\  -f1) 2>&1 | grep "^$(date --utc +%Y-%m-%d\ %H)" | grep -i -e ERROR -e FAIL -e FATAL -e SEVER -e WARN | grep -v -e "Attempting to fail orphaned jobs" | tail -n 5 ; done
echo
echo $($LOGDATECMD) : docker logs : 
for mimage in nginx solr registration jobrunner webapp logstash zookeeper scan authentication postgres cfssl upload documentation ; do sudo docker ps | grep $mimage ; sudo docker logs $(sudo docker ps | grep $mimage | cut -d\  -f1) 2>&1 | grep "^$(date --utc +%Y-%m-%d\ %H:%M)" | tail -n 3 ; done
echo
echo $($LOGDATECMD) : Done 
echo





