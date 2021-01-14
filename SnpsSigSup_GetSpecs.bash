#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetSpecs.bash
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/, https://www.synopsys.com/software-integrity/support.html
#LICENSE: SPDX Apache-2.0
#VERSION: 2101140006Z
#GREPVCKSUM: TODO 

#PURPOSE:  To gather server specs for troubleshooting and baselining. Not intended for long-term monitoring and telemetry or gathering our application configs and logs--that's another script:  SnpsSigServerMonitoring.bash. 

#REQUIREMENTS
#lspci: in package pcitutils

usage() {  
  cat << USAGEEOF 
    Usage: 
    --help -h display this help
    --debug -d debug mode (set -x)
    Needs lots of work.  A proof of concept.  Suggestions welcome. 
    Edit CONFIGs, then:
    sudo ./SnpsSigSup_GetSpecs.bash |& gzip -9 > /tmp/SnpsSigSup_GetSpecs.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz 
    or, like:
    sudo ./SnpsSigSup_GetSpecs.bash |& tee /dev/tty |& gzip -9 > ./log/SnpsSigSup_GetSpecs.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz

    Takes a minute or so to run.
    Run zgrep "not found" \$(ls -1rt /tmp/SnpsSigSup_GetSpecs.bash*gz | tail -n 1) to find any missing commands you may wish to install.
USAGEEOF
  exit 1
  } 
export -f usage

debug() {
  set -x
}
export -f debug

#bad if [[ "$#" == "--help"  || "$#" == "-h" ]] ; then usage ; exit 0 ; fi 
#bad if [[ "$#" == "--debug" || "$#" == "-d" ]] ; then debug ; fi 

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    usage
    shift #  
    ;;
    -d|--debug)
    set -x
    shift #  
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters



#NOTES:  Generally quite safe, even when run as root.  

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

#INITIALIZE

echo
echo New script, lightly tested, lots of bugs and errors will be thrown.  Please send issues and suggestions to pjalajas@synopsys.com, thanks!
echo
date 
date --utc
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
grep -i -v grepvcksum $0 | cksum
echo

hostname -f
ip -stats -detail addr 
ip -stats -detail link
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
echo -e cpuinfo summary : "\n$(grep -i -e cache -e bogomips -e model\ name /proc/cpuinfo | sort -u)"
echo
#echo -e free -galt : "\n$(free -galt)"
#echo
echo -e free -glt : "\n$(free -glt)"
echo
echo -e MemTotal /proc/meminfo : "\n$(grep MemTotal /proc/meminfo)"
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
echo -e top cpu : "\n$(top -c -b -n 1 -w 512 -o %CPU | head -n 40)"
echo
#no -a?:  echo -e top mem : "\n$(top -c -a -b -n 1 -w 512 | head -n 40)"
echo -e top mem : "\n$(top -c -b -n 1 -w 512 -o %MEM | head -n 40)"
echo
echo -e ps java threads : "\n$(ps -eLf | grep -v grep | grep -c "java.*/opt/blackduck/protexIP/tomcat")"
echo
echo -e oom-killer : "\n$(zgrep -i -e "invoked oom-killer" -e " killed " -e "dockerd.*oom" $(ls -1rt /var/log/messages* | tail -n 2))" | grep -v -e puppet -e ups


#moved to end, grepping all of them
#echo
#echo -e /proc/sys/vm/zone_reclaim_mode : "\n$(cat /proc/sys/vm/zone_reclaim_mode)"
#echo
#echo -e cat /sys/devices/system/cpu/cpuidle/current_driver : "\n$(cat /sys/devices/system/cpu/cpuidle/current_driver)"
#echo
#echo -e cat /proc/sys/kernel/sched_migration_cost : "\n$(cat /proc/sys/kernel/sched_migration_cost)"
#echo
#echo -e cat /proc/sys/kernel/sched_autogroup_enabled : "\n$(cat /proc/sys/kernel/sched_autogroup_enabled)"
#echo
#echo -e cat /sys/kernel/mm/transparent_hugepage/enabled : "\n$(cat /sys/kernel/mm/transparent_hugepage/enabled)"
#echo
#echo -e cat /sys/kernel/mm/transparent_hugepage/defrag : "\n$(cat /sys/kernel/mm/transparent_hugepage/defrag)"
#echo
#echo -e cat /proc/sys/vm/swappiness : "\n$(cat /proc/sys/vm/swappiness)"
#echo
#echo -e cat /sys/block/sda/queue/scheduler : "\n$(cat /sys/block/sda/queue/scheduler)"
#echo
#echo -e cat /sys/block/sda/device/timeout : "\n$(cat /sys/block/sda/device/timeout)"

echo
echo -e peak disk iops, wr_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
echo
echo -e peak disk iops, rd_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f5 | sort -k1nr | head)"
echo
echo -e peak disk iops, await : "\n$(sar -d | tr -s \  | cut -d\  -f9 | sort -k1nr | head)"
echo
echo -e peak net, rxkB/s : "\n$(sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
echo
echo -e peak net, txkB/s : "\n$(sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f7 | sort -k1nr | head)"

echo
echo -e lspci : "\n$(lspci -nn)"
echo
echo -e lscpu : "\n$(lscpu)"
echo
#echo -e lsblk : "\n$(lsblk)"
echo -e lsblk : "\n$(lsblk --fs --topology)"
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
#too much:  echo -e sar -A : "\n$(sar -A)"
#echo
#echo -e dmesg : "\n$(dmesg) | strings"
echo -e dmesg : "\n$(dmesg --decode --show-delta -T)"
echo
echo -e sysctl -a : "\n$(sysctl -a 2>/dev/null)"
echo

echo
env
echo


echo
rpm -qa
echo


grep -e bd -e black -e blck -e protex -e codecenter /etc/passwd
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
#TODO too much info; maybe just do for PIDs of our major components: find /proc -type f | xargs -P$(nproc) grep --max-count=1000 -H ".*" |& cat -A |& cut -c1-1000
#TODO hangs: find /sys  -type f | xargs -P$(nproc) grep --max-count=1000 -H ".*" |& cat -A |& cut -c1-1000 
echo

echo
date
date --utc
echo Done $0.

exit
#REFERENCE
