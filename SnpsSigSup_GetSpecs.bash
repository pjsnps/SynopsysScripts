#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetSpecs.bash
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/, https://www.synopsys.com/software-integrity/support.html
#LICENSE: SPDX Apache-2.0
#VERSION:  2101142337Z
#GREPVCKSUM: TODO 
#CHANGES: systemctl show

#PURPOSE:  To gather server specs for troubleshooting and baselining. Not intended for long-term monitoring and telemetry or gathering our application configs and logs--that's another script:  SnpsSigServerMonitoring.bash. 

#REQUIREMENTS
#TODO
#lspci: in package pcitutils

usage() {  
  cat << USAGEEOF 
    Usage: 
    --help -h display this help
    --debug -d debug mode (set -x)
    Needs lots of work.  A proof of concept.  Suggestions welcome. 
    Edit CONFIGs, then:
    sudo ./SnpsSigSup_GetSpecs.bash |& gzip -9 > /tmp/SnpsSigSup_GetSpecs.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f)_\$(id -un).out.gz 
    or, like:
    sudo ./SnpsSigSup_GetSpecs.bash |& tee /dev/tty |& gzip -9 > ./log/SnpsSigSup_GetSpecs.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f)_\$(id -un).out.gz

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
#For the following, to clean up "df" output, search this script for DFGREPFIXME and manually enter your greps as desired
#mMountPointFilterIn='.*' ;  # passed into grep 
#mMountPointFilterOut=" -e ChangeMe -e docker -e overlay " ;  # passed into grep -v ...

#INITIALIZE

echo
echo New script, lightly tested, lots of bugs and errors will be thrown.  Please send issues and suggestions to pjalajas@synopsys.com, thanks!
echo
echo "date : $(date)" 
echo "date --utc : $(date --utc)"
echo "hostname -f : $(hostname -f)"
#TODO?:  echo $(curl -s http://whatismyip.akamai.com/)
echo "user and their groups running script : $(id -a)"
echo "pwd : $(pwd)"
echo
echo "script name : $0"
#grep [V]ersion $0
echo "script VERSION : $(grep ^\#VERSION $0)"
echo "script md5sum : $(md5sum $0)"
echo "script cksum : $(grep -i -v grepvcksum $0 | cksum)"
echo
echo
echo Running in shell...
#Credit: https://askubuntu.com/a/1022440
#Keep multiple in case of oddities
ps -p "$$" 
sh -c 'ps -p $$ -o ppid=' | xargs ps -o cmd= -p #-bash 
sh -c 'ps -p $$ -o ppid=' | xargs -i readlink -f /proc/\{\}/exe #/bin/bash

echo

#MAIN

echo
grep -H ".*" /etc/*release* 2>/dev/null | sort -u | while read line ; do echo "grep .* /etc/*release* : $line" ; done
echo
echo -e "lsb_release : $(lsb_release -a)"
echo
echo -e "uname -a : $(uname -a)"
echo
echo -e "nproc : $(nproc)"
echo
grep -i -e bogomips -e cache -e model\ name /proc/cpuinfo | sort -u | while read line ; do echo "cpuinfo cache bogomips model : $line" ; done

echo
free -glt | while read line ; do echo "free -glt : $line" ; done 

echo
grep MemTotal /proc/meminfo | while read line ; do echo "meminfo MemTotal : $line" ; done

echo
df -hPT | while read line ; do echo "df -hPT : $line" ; done
echo
#echo -e lspci : "\n$(lspci -nn)"
lspci -nn | while read line ; do echo "lspci -nn : $line" ; done

echo
#echo -e lscpu : "\n$(lscpu)"
lscpu | while read line ; do echo "lscpu : $line" ; done
echo
#echo -e lsblk : "\n$(lsblk)"
#echo -e lsblk : "\n$(lsblk --fs --topology)"
lsblk --fs --topology | while read line ; do echo "lsblk fs topo : $line" ; done
echo
#echo -e lsblk rota: "\n$(lsblk -d -o name,rota)"
lsblk -d -o name,rota | while read line ; do echo "lsblk : $line" ; done
echo
#echo -e lshw : "\n$(lshw -short -sanitize 2>/dev/null)"
lshw -short -sanitize 2>/dev/null | while read line ; do echo "lshw short sani : $line" ; done
echo
#echo -e lsmod : "\n$(lsmod)"
lsmod | while read line ; do echo "lsmod : $line" ; done
echo
#echo -e mount : "\n$(mount)"
mount | while read line ; do echo "mount : $line" ; done
echo
#echo -e vmstat -SM 5 3 : "\n$(vmstat -SM 5 3 )"
vmstat -SM 5 3 | while read line ; do echo "vmstat SM 5 3 : $line" ; done
echo
#echo -e iostat -ytNmx 5 1 : "\n$(iostat -ytNmx 5 1)"
iostat -ytNmx 5 1 | while read line ; do echo "iostat ytNmx 5 1 : $line" ; done
echo
#echo -e iostat -ytmx 5 1 : "\n$(iostat -ytmx 5 1)"
iostat -ytmx 5 1 | while read line ; do echo "iostat ytmx 5 1 : $line" ; done



echo
echo
echo
ip -stats -detail addr | while read line ; do echo "ip stats detail addr : $line" ; done
echo
ip -stats -detail link | while read line ; do echo "ip stats detail link : $line" ; done
echo
echo
echo


echo


#TODO: torn whether to scrunch the output into single lines (no quotes around $(), or keep the output multi-line (with quotes), like java -version and free -g, etc.
echo
#echo -e ulimit -a : "\n$(ulimit -a)" # TODO get same info for our app user (instead of sudo/root)
ulimit -a | while read line ; do echo "ulimit -a : $line" ; done  # TODO get same info for our app user (instead of sudo/root)







echo
echo
echo
echo
echo -e "java version : "$(java -version 2>&1)
echo
echo -e "postgresql : $(psql --version)"
echo
echo

docker --version | while read line ; do echo "docker --version : $line" ; done
echo
echo
docker ps -a | while read line ; do echo "docker ps -a : $line" ; done 
echo
echo
docker info | while read line ; do echo "docker info : $line" ; done
echo
echo
docker stats --no-stream | while read line ; do echo "docker stats --no-stream : $line" ; done
echo
echo
echo
echo
echo
#echo -e ps tc 1: "\n$(ps auxww | grep -v grep | grep -e PID -e java.*${BDAPPPATH})"
ps auxww | grep -v grep | grep -e PID -e java | while read line ; do echo "ps java : $line" ; done
echo
echo
#echo -e ps tc 2: "\n$(ps auxww | grep -v grep | grep -e PID -e java.*${BDAPPPATH} | tr ' ' '\n' | grep -v "^\s*$")"


#echo -e ps pg : "\n$(ps auxww | grep -v grep | grep -e PID -e postmaster -e postgres)"
echo
echo
echo
ps auxww | grep -v grep | grep -e PID -e postmaster -e postgres | while read line ; do echo "ps postgres : $line" ; done
echo
echo
echo
#echo -e pg SHOW ALL : "\n$(${BDAPPPATH}/postgresql/bin/psql -U blackduck -d template1 -c "SHOW ALL")"
#echo
#echo -e pg stat activity : "\n$(${BDAPPPATH}/postgresql/bin/psql -U blackduck -d template1 -c "SELECT * FROM pg_stat_activity ; ")"
echo

#echo -e top cpu : "\n$(top -c -b -n 1 -w 512 -o %CPU | head -n 40)"
top -c -b -n 1 -w 512 -o %CPU | head -n 40 | while read line ; do echo "top cpu : $line" ; done
echo
echo
echo
#no -a?:  echo -e top mem : "\n$(top -c -a -b -n 1 -w 512 | head -n 40)"
#echo -e top mem : "\n$(top -c -b -n 1 -w 512 -o %MEM | head -n 40)"
top -c -b -n 1 -w 512 -o %MEM | head -n 40 | while read line ; do echo "top mem : $line" ; done
echo
echo
echo

#if set (not null, non-zero-length), then print
unset TEXT ; TEXT="$(ls -1rt /var/log/messages* | tail -n 2 | while read msgfile ; do zgrep -H -i -e " killed " -e "invoked oom-killer" $msgfile | tail ; done | while read line ; do echo "oom kill : $line" ; done)" ; if [[ -n "$TEXT" ]] ; then echo "oom kill : $TEXT" ; else echo "oom kill : none" ; fi



echo
echo
#echo -e peak disk iops, wr_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
sar -d | tr -s \  | cut -d\  -f6 | sort -k1nr | head | while read line ; do echo "sar peak iops wr_sec : $line" ; done
echo
#echo -e peak disk iops, rd_sec/s : "\n$(sar -d | tr -s \  | cut -d\  -f5 | sort -k1nr | head)"
sar -d | tr -s \  | cut -d\  -f5 | sort -k1nr | head | while read line ; do echo "sar peak iops rd_sec : $line" ; done
echo
#echo -e peak disk iops, await : "\n$(sar -d | tr -s \  | cut -d\  -f9 | sort -k1nr | head)"
sar -d | tr -s \  | cut -d\  -f9 | sort -k1nr | head | while read line ; do echo "sar peak iops await : $line" ; done
echo
#echo -e peak net, rxkB/s : "\n$(sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f6 | sort -k1nr | head)"
sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f6 | sort -k1nr | head | while read line ; do echo "sar peak net rxkB/s : $line" ; done
echo
#echo -e peak net, txkB/s : "\n$(sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f7 | sort -k1nr | head)"
sar -n ALL | grep -v lo | tr -s \  | cut -d\  -f7 | sort -k1nr | head | while read line ; do echo "sar peak net txkB/s : $line" ; done
echo
echo
echo






echo
echo Put longer output after here...
echo
#echo -e netstat -a : "\n$(netstat -a)"
netstat -a | while read line ; do echo "netstat -a : $line" ; done
echo
#too much:  echo -e sar -A : "\n$(sar -A)"
#echo
#echo -e dmesg : "\n$(dmesg) | strings"
#echo -e dmesg : "\n$(dmesg --decode --show-delta -T)"
dmesg --decode --show-delta -T | while read line ; do echo "dmesg decode delta T : $line" ; done
echo
#echo -e sysctl -a : "\n$(sysctl -a 2>/dev/null)"
sysctl -a 2>/dev/null | while read line ; do echo "sysctl -a : $line" ; done
echo
echo
systemctl show --property=Environment docker | while read line ; do echo "systemctl show env docker : $line" ; done
echo
echo
systemctl show | while read line ; do echo "systemctl show all : $line" ; done

echo
echo
env | while read line ; do echo "env : $line" ; done
echo


echo
rpm -qa | while read line ; do echo "rpm -qa : $line" ; done
echo


grep -e bd -e black -e blck -e protex -e codecenter /etc/passwd | while read line ; do echo "passwd : $line" ; done
echo
echo
echo
echo

#journalctl --all --utc --output=verbose --unit=docker --since="$(date -d '1 hour ago' +%Y-%m-%d\ %H:%M:%S)" |& cat -A | while read line ; do echo "journalctl docker last hour : $line" ; done
journalctl --all --utc --unit=docker --since="$(date -d '1 hour ago' +%Y-%m-%d\ %H:%M:%S)" |& cat -A | while read line ; do echo "journalctl docker last hour : $line" ; done

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
echo

bonnie++ -u root |& while read line ; do echo "bonnie++ : $line" ; done
echo
echo
echo
date | while read line ; do echo "date : $line" ; done
date --utc | while read line ; do echo "date --utc : $line" ; done
echo Done $0.

exit
#REFERENCE
