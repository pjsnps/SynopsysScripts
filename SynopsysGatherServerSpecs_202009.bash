#!/bin/bash
#SynopsysGatherServerSpecs_202007.bash
#pjalajas@synopsys.com
#License SPDX Apache-2.0
#Version 2008141949Z # pj enable some Protex-specifics, not tested. 
#grepvcksum: 3483071372 9558 

#To gather server specs for troubleshooting and baselining. Not intended for long-term monitoring and telemetry or gathering our application configs and logs--that's another script.
#Generally quite safe, even when run as root.  
#REMOVED: See dd read/write performance testing near bottom.  That is writing and reading testing to each of the larger mounts from df output.  

#USAGE: Needs lots of work.  A proof of concept.  Suggestions welcome. 
#USAGE: Edit CONFIGs, then:
#USAGE: nice time sudo ./SynopsysGatherServerSpecs_202007.bash |& gzip -9 > /tmp/SynopsysGatherServerSpecs_202007.bash_$(date --utc +%Y%m%d%H%M%SZ%a)_$(hostname -f).out.gz 
#USAGE: takes maybe 10 minutes to run.
#USAGE: May need to swap "nice time" to "time nice" or remove nice from command line.
#USAGE: zgrep "not found" $(ls -1rt /tmp/SynopsysGatherServerSpecs.*gz) to find any missing commands you may wish to install.
#  lspci is in pcitutils

#TODO 

#TODO generalize to Hub
#TODO add java, docker, postgresql
#TODO combine with log and config collector script 
#TODO get ulimit -a as user running app of concern (not just as sudo/root).  


#CONFIG

#TODO these first few are broken:
#BDAPPDIR=hub # protexIP #CodeCenter # hub 
BDAPPDIR=protexIP # protexIP #CodeCenter hub 
BDAPPPATH="/opt/blackduck/${BDAPPDIR}"
TOMCATDIR="/opt/blackduck/${BDAPPDIR}/tomcat"
#For the following, search this script for DFGREPFIXME and manually enter your greps as desired
#mMountPointFilterIn='.*' ;  # passed into grep 
#mMountPointFilterOut=" -e ChangeMe -e docker -e overlay " ;  # passed into grep -v ...

#REMOVED dd:
#Filter for dd disk performance test at the end. Filter in or out Mounts as desired. See output of "sudo df" for preview (docker mounts appear in sudo df).. 
#mddtests are passed into dd as bs_count, so 1_2 would run dd with bs=1 count=2. Trying to get latency with 1_1 and throughput with larger numbers.
#mddtests="1_1   1_1   1_100000000   10000_10000   100000000_1" ; 
#mmindiskfree1kblocks=500000 ;  # don't test mounts with free space, in blocks (frequently 1024 bytes/block), less than this
#mfilename=SynopsysDdTest.img ; # any unique name, to avoid clobbering in dd test. Deleted when done testing.  



#INITIALIZE

echo
echo New script, lightly tested, lots of bugs and errors will be thrown.  Please send issues and suggestions to pjalajas@synopsys.com, thanks!
echo
date 
date -u
id -a
pwd

echo
echo Running in shell...
#Credit: https://askubuntu.com/a/1022440
#Keep multiple in case of oddities
ps -p "$$"
sh -c 'ps -p $$ -o ppid=' | xargs ps -o cmd= -p #-bash
sh -c 'ps -p $$ -o ppid=' | xargs -i readlink -f /proc/\{\}/exe #/bin/bash

echo
echo $0
grep [V]ersion $0
md5sum $0
echo

hostname -f
ip addr | grep inet
ip addr 
#echo $(curl -s http://whatismyip.akamai.com/)

echo
#echo \$BDAPPPATH=$BDAPPPATH # /opt/blackduck/protexIP
#echo \$TOMCATDIR=$TOMCATDIR # /opt/blackduck/protexIP/tomcat
#BDUSER=$(grep -m 1 -e "bds.\(protexip\|codecenter\)" -e blckdck /etc/passwd | cut -d\: -f1) # bds-protexip
#echo \$BDUSER=$BDUSER
BDHOME=$(grep -m 1 -e "bds.\(protexip\|codecenter\)" -e blckdck /etc/passwd | cut -d\: -f6) # /var/lib/bds-protexip
echo \$BDHOME=$BDHOME
PGDIR=${BDHOME}/postgresql # /var/lib/bds-protexip/postgresql
echo \$PGDIR=${PGDIR}
echo

#MAIN

#TODO: torn whether to scrunch the output into single lines (no quotes around $(), or keep the output multi-line (with quotes), like java -version and free -g, etc.
echo -e uname -a : "\n$(uname -a)"
echo
echo -e lsb_release : "\n$(lsb_release -a)"
echo
echo -e cat /etc/release : "\n$(cat /etc/*release* 2>/dev/null | sort -u)"
echo
echo -e id.txt : "\n$(cat ${BDAPPPATH}/id.txt)"
echo
echo -e java version : "\n$(${BDAPPPATH}/lib/jre/bin/java -version 2>&1)"
echo
echo -e java version : "\n$(java -version 2>&1)"
echo
#/opt/blackduck/protexIP/postgresql/bin/psql
echo -e postgresql : "\n$(${BDAPPPATH}/postgresql/bin/psql --version)"
echo
echo -e postgresql : "\n$(psql --version)"
echo
echo -e nproc : "\n$(nproc)"
echo
#echo -e free -galt : "\n$(free -galt)"
#echo
echo -e free -glt : "\n$(free -glt)"
echo
echo -e ulimit -a : "\n$(ulimit -a)" # TODO get same info for our app user (instead of sudo/root)

echo
echo -e ps tc 1: "\n$(ps auxww | grep -v grep | grep -e PID -e java.*${BDAPPPATH})"
echo
echo -e ps tc 2: "\n$(ps auxww | grep -v grep | grep -e PID -e java.*${BDAPPPATH} | tr ' ' '\n' | grep -v "^\s*$")"
echo
echo -e tomcat.start : "\n$(grep -v -e "^\s*#" -e "^\s*$" ${BDAPPPATH}/config/bds-protexIP-tomcat.start)"
echo
echo -e server.xml : "\n$(grep -v -e "^\s*#" -e "^\s*$" ${TOMCATDIR}/conf/server.xml | sed -re 's/(keystorePass=).*? /\1"__REDACTED__" /g')"
echo
echo -e ps pg : "\n$(ps auxww | grep -v grep | grep -e PID -e postmaster -e postgres)"
echo
echo -e pg SHOW ALL : "\n$(${BDAPPPATH}/postgresql/bin/psql -U blackduck -d template1 -c "SHOW ALL")"
echo
echo -e pg stat activity : "\n$(${BDAPPPATH}/postgresql/bin/psql -U blackduck -d template1 -c "SELECT * FROM pg_stat_activity ; ")"
echo
echo -e top cpu : "\n$(top -c -b -n 1 | head -n 40)"
echo
echo -e top mem : "\n$(top -c -a -b -n 1 | head -n 40)"
echo
echo -e ps java threads : "\n$(ps -eLf | grep -v grep | grep -c "java.*/opt/blackduck/protexIP/tomcat")"
echo
echo -e oom-killer : "\n$(zgrep -i -e oom -e kill /var/log/messages*)"

echo
echo -e /proc/sys/vm/zone_reclaim_mode : "\n$(cat /proc/sys/vm/zone_reclaim_mode)"
echo
echo -e cat /sys/devices/system/cpu/cpuidle/current_driver : "\n$(cat /sys/devices/system/cpu/cpuidle/current_driver)"
echo
echo -e cat /proc/sys/kernel/sched_migration_cost : "\n$(cat /proc/sys/kernel/sched_migration_cost)"
echo
echo -e cat /proc/sys/kernel/sched_autogroup_enabled : "\n$(cat /proc/sys/kernel/sched_autogroup_enabled)"
echo
echo -e cat /sys/kernel/mm/transparent_hugepage/enabled : "\n$(cat /sys/kernel/mm/transparent_hugepage/enabled)"
echo
echo -e cat /sys/kernel/mm/transparent_hugepage/defrag : "\n$(cat /sys/kernel/mm/transparent_hugepage/defrag)"
echo
echo -e cat /proc/sys/vm/swappiness : "\n$(cat /proc/sys/vm/swappiness)"
echo
echo -e cat /sys/block/sda/queue/scheduler : "\n$(cat /sys/block/sda/queue/scheduler)"
echo
echo -e cat /sys/block/sda/device/timeout : "\n$(cat /sys/block/sda/device/timeout)"

echo
echo -e peak disk iops, wr_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
echo
echo -e peak disk iops, rd_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f5 | sort -k1nr | head)"
echo
echo -e peak disk iops, await : "\n$(sar -d | tr -s \  | cut -d\  -f9 | sort -k1nr | head)"
echo
echo -e peak net, rxkB/s : "\n$(sar -n ALL | grep -v lo |  tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
echo
echo -e peak net, txkB/s : "\n$(sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f7 | sort -k1nr | head)"

echo
echo -e lspci : "\n$(lspci -nn)"
echo
echo -e lscpu : "\n$(lscpu)"
echo
echo -e lsblk : "\n$(lsblk)"
echo
echo -e lsblk rota: "\n$(lsblk -d -o name,rota)"
echo
echo -e lshw : "\n$(lshw -short -sanitize 2>/dev/null)"
echo
echo -e lsmod : "\n$(lsmod)"
echo
echo -e mount : "\n$(mount)"
echo
echo -e df -hPT : "\n$(df -hPT)"
echo
echo -e vmstat -SM 5 3 : "\n$(vmstat -SM 5 3 )"
echo
echo -e iostat -ytNmx 5 1 : "\n$(iostat -ytNmx 5 1)"
echo
echo -e iostat -ytmx 5 1 : "\n$(iostat -ytmx 5 1)"
echo
echo Put longer output after here...
echo
echo -e netstat -a : "\n$(netstat -a)"
echo
echo -e sar -A : "\n$(sar -A)"
echo
echo -e dmesg : "\n$(dmesg) | strings"
echo
echo -e sysctl -a : "\n$(sysctl -a 2>/dev/null)"
echo
echo EXPERIMENTAL
echo
echo jstat needs to run as java user, sudo -u root \<this script\>...
#echo -e jstat -class : "\n$(jstat -class $(ps -C java -o pid | grep -v PID) 5 2)"
#echo
#echo -e jstat -jc : "\n$(jstat -gc $(ps -C java -o pid | grep -v PID) 5 2)"
#echo
#echo -e jstat -gccause : "\n$(jstat -gccause $(ps -C java -o pid | grep -v PID) 5 2)"
#echo
#echo -e jstat -gcutil : "\n$(jstat -gcutil $(ps -C java -o pid | grep -v PID) 5 2)"
echo 
df -hPT ; 
echo ; 
#TODO DFGREPFIXME: echo \'${mMountPointFilterIn}\' : \'${mMountPointFilterOut}\'
#    df | grep " ${mMountPointFilterIn} " | grep -v " ${mMountPointFilterOut} " | tr -s ' ' | cut -d ' ' -f4,6 | while read mavail mdisk ; 
#df | grep -e "DFGREPFIXME" -e ".*" | grep -v -e "DFGREPFIXME" -e docker -e overlay | tr -s ' ' | cut -d ' ' -f4,6 | while read mavail mdisk ; 
#do if [[ "$mavail" -gt "${mmindiskfree1kblocks}" && -w $mdisk ]] ; then echo mountpoint : $mdisk ; 
#for mbs_mcount in $mddtests ; 
#do echo $mbs_mcount | tr _ ' ' | while read mbs mcount ; 
#do echo $(echo writing $mbs $mcount ${mdisk}/${mfilename} ; 
#timeout -s SIGINT 10s dd if=/dev/zero of=${mdisk}/${mfilename} bs=$mbs count=$mcount oflag=dsync 2>&1 ) ; 
#echo $(echo checking written file... ; ls -lh ${mdisk}/${mfilename} 2>&1 ; du -h ${mdisk}/${mfilename} 2>&1 ) ; 
#echo $(echo reading $mbs $mcount ${mdisk}/${mfilename}... ; timeout -s SIGINT 10s dd if=$mdisk/$mfilename of=/dev/null bs=$mbs count=$mcount oflag=dsync 2>&1 ) ; 
#echo $(echo removing... ; rm ${mdisk}/${mfilename} 2>&1 ; echo confirming removed... ; ls -al $mdisk/$mfilename 2>&1 ) ; 
#echo ; 
#done ; 
#done ; 
#fi ; 
#done 


echo
date
date -u
echo Done.

exit
#REFERENCE
[pjalajas@imp-px02 db]$ grep -e bd -e black -e blck /etc/passwd
bds-protexip:x:1336:1297::/var/lib/bds-protexip:/bin/bash
bdsroot:x:490:500:Used by OPS for backend SSH access in case of IPA failures or high level administration.:/home/bdsroot:/bin/bash





