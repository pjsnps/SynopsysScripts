#!/usr/bin/bash
#SnpsSigServerMonitoring.bash
#DATE: 2019-06-06, 2020-08-27
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#VERSION:  2009031441Z
#CHANGELOG: pj clean up netstat, added ss
#GREPVCKSUM:  # grep -v grepvcksum SnpsSigServerMonitoring.bash | cksum 

#PURPOSE:  A work in progress! Corrections, suggestions welcome. 
#PURPOSE:  Intended to try to capture system state when a server crashes, etc.

#USAGE: mkdir -p log ; while true ; do sudo ./SnpsSigServerMonitoring.bash |& tee /dev/tty |& gzip -9 >> ./log/SnpsSigServerMonitoring.bash_$(hostname -f)_$(date +%Y%m%d).out.gz ; sleep 15s ; done
#USAGE: sudo ./SnpsSigServerMonitoring.bash |& tee -a ./log/SnpsSigServerMonitoring.bash_$(hostname -f)_$(date +%Y%m%d).out
#USAGE: sudo ./SnpsSigServerMonitoring.bash |& grep "^1L:" |& tee -a log/SnpsSigServerMonitoring.bash_$(hostname -f)_$(hostname -f)_$(date +%Y%m%d).out

#REQUIREMENTS: (yum provides "*/<cmd name>")
#iotop (sudo yum install iotop)
#iostat (sudo yum install systat)

#TODO: Add requirements to run this script, to above.  Extra credit: add how to install them if not obvious by its name.
#TODO: Make docker tests options. Put docker command in if block. Would fix some errors. 
#TODO: For output greppability, continue adding COMMAND string in these:  |& while read line ; do echo "$($LOGDATECMD) : COMMAND : $line" ; done   
#TODO: Send some output errors to /dev/null.
#DONE: A single loop is a few minutes, too long, miss detail near crash; so, find and disable the slowest tasks herein, if possible.
#TODO: Many in-container tests are dumb, they just report the os info.  Can probably remove some useless, redundant.  Move some of these to a one-time server checker, like SynopsysGatherServerSpecs_202007.bash.  (not too urgent, just some wasted bytes, I think)
#TODO: Low priority: change netstat to ss. 
#TODO: Your improvement here. 

#NOTES:
#Tries to create "one-liners" for some consistently-structured  multi-line output, for "easier" grepping and parsing.  Grep for "^1L:" for those if you wish.
#This is really overkill in lots of ways, but trying to do it all in one shot.  Suggestions welcome.
#Tries to prepend _every_ line with a good timestamp, for greppability.  

#INIT

LOGDATECMD='date --utc +%Y-%m-%dT%H:%M:%S.%NZ' # reversible back into date -d if needed
#TODO: make this work:  PREPEND=' |& while read line ; do echo "$($LOGDATECMD) : $line" ; done'
#echo PREPEND=\'$PREPEND\'

#MAIN
echo
echo $($LOGDATECMD):1L : Start 
echo
echo $($LOGDATECMD):1L : $(date +%Y-%m-%dT%H:%M:%S.%N%Z\ %a) : $(hostname -f) : $(whoami) : $(pwd) 
echo
echo
echo $($LOGDATECMD):1L : memory:
echo
for mfreeopt in "-g" ; do
  # default free in KiB, in top output below, so no need here
  #free $mfreeopt $(echo $PREPEND)
  free $mfreeopt |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  echo $($LOGDATECMD):1L : free $mfreeopt : $(free $mfreeopt)
  echo
done
echo $($LOGDATECMD):1L : memory usage : $(free | awk 'NR == 2 {print $3/$2*100 "%"}') ::  swap usage : $(free | awk 'NR == 3 {print $3/$2*100 "%"}')
echo
echo $($LOGDATECMD):1L : top:
echo
for mtopsort in %CPU %MEM ; do
  #max width 512:
  top -n1 -b -c -w 512 -o"${mtopsort}" | head -n 20 |& while read line ; do echo "$($LOGDATECMD) : $line" ; done 
  echo
done
echo $($LOGDATECMD):1L : top %MEM : $(top -n1 -b -o%MEM | head -n 5) # just the 5 header rows
echo
echo iostat:
echo
echo $($LOGDATECMD) : iostat :
iostat |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo $($LOGDATECMD) : iostat -y :
echo
iostat -y |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo $($LOGDATECMD):1L : iostat -y : $(iostat -y) 
echo
iotop -b -n1 -d5 | head -n 8 |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo iotop:
echo
echo $($LOGDATECMD):1L : iotop : $(iotop -b -n1 -d5 | head -n 2)
echo
echo $($LOGDATECMD) : postgres ps : 
echo
ps auxww | grep -v grep | grep -e PID -e postgres | grep -v -e "idle$" -e "process\s*$" | cut -c1-1000 |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo $($LOGDATECMD) : java ps : 
echo
ps auxww | grep -v grep | grep -e PID -e java | cut -c1-1000 |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo $($LOGDATECMD) : java Xmx TODO:FIXME : 
echo
ps auxww | grep -v grep | grep -Po "\-Xmx.*? " | cut -c1-1000 |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo



#TODO: put all docker tests here and wrap with an "is this a docker host" test
echo
echo $($LOGDATECMD) : monitoring docker 
echo
echo $($LOGDATECMD) : docker ps -a $(docker ps -a)
echo
docker ps -a |& while read line ; do echo "$($LOGDATECMD) : docker ps -a : $line" ; done 
echo
echo $($LOGDATECMD):1L : docker ps wc : $(docker ps | wc -l)
echo
echo $($LOGDATECMD) : docker log errors : TODO:  take too long, manually enable if desired...
#TODO: print container info only if Errors are present. 
#mcontainerlist="nginx solr registration jobrunner webapp logstash zookeeper scan authentication postgres cfssl upload blackduck-upload-cache documentation"
mcontainerlist="$(docker ps -q)"
#for mcontainer in $mcontainerlist ; do docker logs $(docker ps | grep $mcontainer | cut -d\  -f1) 2>&1 | grep -e "^$(date --utc +%Y-%m-%d\ %H:%M)" -e "^$(date --utc +%Y-%m-%dT%H:%M)" | grep -e ERROR -e FAIL -e FATAL -e SEVER | grep -v -e "Attempting to fail orphaned jobs" | tail -n 5 ; done |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
#TODO:  busy containers with ALL/TRACE logging take 10-15 minutes for each of these two docker log steps...kill for now...
#for mcontainer in $mcontainerlist ; do docker ps | grep $mcontainer ; docker container logs $mcontainer |& grep -e "^$(date --utc +%Y-%m-%d\ %H:%M)" -e "^$(date --utc +%Y-%m-%dT%H:%M)" | grep -e ERROR -e FAIL -e FATAL -e SEVER | grep -v -e "Attempting to fail orphaned jobs" | tail -n 5 ; done |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo
echo $($LOGDATECMD) : docker logs tail : TODO:  take too long, manually enable if desired...
#for mcontainer in $mcontainerlist ; do docker ps | grep $mcontainer ; docker container logs $mcontainer |& grep -e "^$(date --utc +%Y-%m-%d\ %H:%M)" -e "^$(date --utc +%Y-%m-%dT%H:$M)" | tail -n 3 ; done |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
echo

echo monitoring vmstat
# Options:
 #-a, --active           active/inactive memory
 #-f, --forks            number of forks since boot
 #-m, --slabs            slabinfo
 #-n, --one-header       do not redisplay header
 #-s, --stats            event counter statistics
 #-d, --disk             disk statistics
 #-D, --disk-sum         summarize disk statistics
 #-p, --partition <dev>  partition specific statistics
 #-S, --unit <char>      define display unit
 #-w, --wide             wide output
 #-t, --timestamp        show timestamp
echo
for mopt in active forks slabs stats disk disk-sum 
do
  echo $($LOGDATECMD) : echo host vmstat $mopt
  vmstat --$mopt --wide |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  echo $($LOGDATECMD) : host vmstat --$mopt one line
  echo $($LOGDATECMD):1L : host vmstat --$mopt : $(vmstat --$mopt --wide)
  echo
  #no vmstat in busybox
    #echo container vmstat
    #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) vmstat --$mopt --wide 
    #echo
    #echo container vmstat one line
    #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) sh -c 'echo container vmstat --$mopt : $(vmstat --$mopt --wide)'
    #echo
done

echo $($LOGDATECMD) : host /proc/net : 
  find /proc/net/ -type f | xargs grep -H ".*"  | wc -l |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  find /proc/net/ -type f | xargs grep -H ".*"  |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
echo

echo $($LOGDATECMD) : host lsof dockerd : 
  lsof -p $(pgrep dockerd) 2> /dev/null | wc -l |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  lsof -p $(pgrep dockerd) 2> /dev/null |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
echo

echo $($LOGDATECMD) : host netfilter : 
  /sbin/sysctl -a | grep -i nf_conntrack
  echo
  find /sys/module/nf_conntrack -type f | xargs grep -H ".*"  # TODO: probably should move this and others to a one-time SynopsysGatherServerSpecs_202007.bash
echo


echo
echo $($LOGDATECMD) : monitoring netstat
echo

  echo $($LOGDATECMD) : host $mcmd -$mopt
  netstat --statistics |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  echo $($LOGDATECMD) : host netstat --statistics one line
  echo
  echo $($LOGDATECMD) : host netstat --statistics : $(netstat --statistics)
  echo 
  echo $($LOGDATECMD) : host netstat --timers
  echo
  netstat --timers |& while read line ; do echo "$($LOGDATECMD) : host netstat --timers : $line" ; done



  echo
  echo $($LOGDATECMD) : container netstat 
  echo
  for mcontainerid in $(docker ps -q) ; do
    #echo \$mcontainerid = $mcontainerid
    docker ps | grep $mcontainerid |& while read line ; do echo "$($LOGDATECMD) : container netstat -aeW : $line" ; done
    echo
    echo $($LOGDATECMD) : container netstat -aeW
    echo
    docker container exec -u 0 $mcontainerid sh -c 'netstat -aeW' |& while read line ; do echo "$($LOGDATECMD) : container netstat -aeW : $line" ; done
    echo
    #echo $($LOGDATECMD) : container cat /proc/net wc
    #echo
    #TODO: make sense?:  docker container exec -u 0 $mcontainerid sh -c 'find /proc/net -type f | xargs -I"%" grep -H ".*" "%" | wc -l' |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
    #echo
    echo $($LOGDATECMD) : container cat /proc/net content
    echo
    docker container exec -u 0 $mcontainerid sh -c 'find /proc/net -type f | xargs -I"%" grep -H ".*" "%" '|& while read line ; do echo "$($LOGDATECMD) : container cat /proc/net content : $line" ; done
    echo
  done

  echo

echo $($LOGDATECMD) : monitoring ss 
  echo
  ss -s |& while read line ; do echo "$($LOGDATECMD) : ss -s : $line" ; done
  echo
  ss -o |& while read line ; do echo "$($LOGDATECMD) : ss -o : $line" ; done
echo


echo
echo $($LOGDATECMD) : monitoring strace network
echo
echo $($LOGDATECMD) : host strace
timeout 5s strace -e trace=network nc kb.blackducksoftware.com 443 |& while read line ; do echo "$($LOGDATECMD) : strace network : $line" ; done
#TODO: can do in container? 
echo

echo
#for mcmd in ping traceroute
#do
  #for mopt in kb.blackducksoftware.com
  #do
    echo
    echo $($LOGDATECMD) : monitoring ping kb.blackducksoftware.com
    echo $($LOGDATECMD) : host ping kb.blackducksoftware.com 
    timeout 5s ping kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : host ping kb.blackducksoftware.com : $line" ; done
    echo
    #TODO: timeout 5 ping6 kb.blackducksoftware.com
    #echo
    echo $($LOGDATECMD) : container ping kb.blackducksoftware.com 
    #BUG HANGS: timeout 5 docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) ping kb.blackducksoftware.com
    for mcontainerid in $(docker ps -q) ; do
      docker ps | grep $mcontainerid |& while read line ; do echo "$($LOGDATECMD) : $mcontainerid ping kb.blackducksoftware.com : $line" ; done
      #ERROR: nginx, logstash only...?
      #2020-08-29T20:42:39.413317073Z : BusyBox v1.30.1 (2019-10-26 11:23:07 UTC) multi-call binary.
      #2020-08-29T20:42:39.416523953Z : Usage: timeout [-s SIG] SECS PROG ARGS
      #docker container exec -u 0 -it $mcontainerid timeout -t 5 ping kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
      timeout 5s docker container exec -u 0 -it $mcontainerid ping kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $mcontainerid ping kb.blackducksoftware.com : $line" ; done
    done
    #BUG HANGS: timeout 5 docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) ping6 kb.blackducksoftware.com
    echo


    echo
    echo $($LOGDATECMD) : monitoring traceroute kb.blackducksoftware.com
    echo $($LOGDATECMD) : host tracepath kb.blackducksoftware.com 
    timeout 5s tracepath kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
    echo
    #timeout 10 tracepath6 kb.blackducksoftware.com
    #echo
    echo
    echo $($LOGDATECMD) : container traceroute kb.blackducksoftware.com 
    for mcontainerid in $(docker ps -q) ; do
      docker ps | grep $mcontainerid |& while read line ; do echo "$($LOGDATECMD) : $line"
      #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 30 traceroute kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
      timeout 5s docker container exec -u 0 -it $mcontainerid traceroute kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
      echo
      #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 traceroute6 kb.blackducksoftware.com
    done
    #echo
  #done
#done

echo $($LOGDATECMD) : monitoring openssl
for mopt in kb.blackducksoftware.com
do
  # echo -n | openssl s_client -connect kb.blackducksoftware.com:443 2>&1 | openssl x509 -text | grep -e Subject: -e Issuer: -e DNS
  #    Issuer: C=US, O=DigiCert Inc, CN=DigiCert SHA2 Secure Server CA
  #    Subject: C=US, ST=Massachusetts, L=Burlington, O=Black Duck Software, Inc., OU=IT, CN=*.blackducksoftware.com
  #            DNS:*.blackducksoftware.com, DNS:blackducksoftware.com
  echo $($LOGDATECMD) : monitoring host openssl $mopt
  time (echo -n | openssl s_client -connect $mopt:443 2>&1 | openssl x509 -text | grep -e Subject: -e Issuer: -e DNS) |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  #no ssl in busybox: echo monitoring containeopenssl $mopt
    #timeout 5 docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) traceroute6 kb.blackducksoftware.com
  echo
  echo $($LOGDATECMD) : monitoring container wget $mopt
    #timeout 5 docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) "wget --spider -S https://kb.blackducksoftware.com 2>&1"
  #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 wget --spider -S https://kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
    for mcontainerid in $(docker ps -q) ; do
      docker ps | grep $mcontainerid |& while read line ; do echo "$($LOGDATECMD) : $line"
      timeout 5s docker container exec -u 0 -it $mcontainerid wget --spider -S https://kb.blackducksoftware.com |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
      echo
    done
  echo $($LOGDATECMD) : monitoring container wget $mopt/api/authenticate
  #405 Method Not Allowed is ok
  #time (docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 wget --spider -S https://kb.blackducksoftware.com/api/authenticate) |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
    for mcontainerid in $(docker ps -q) ; do
      docker ps | grep $mcontainerid |& while read line ; do echo "$($LOGDATECMD) : $line"
      time (timeout 5s docker container exec -u 0 -it $mcontainerid wget --spider -S https://kb.blackducksoftware.com/api/authenticate) |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
    done
done

  echo
  echo $($LOGDATECMD) : monitoring host count open files 
  #slow: echo $(lsof 2>/dev/null | wc -l)
  sysctl fs.file-nr |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  echo
  echo $($LOGDATECMD) : systctl fs.file-nr : $(sysctl fs.file-nr)
  echo
  echo $($LOGDATECMD) : monitoring container count open files 
  #docker container exec -u 0 -it $(docker ps | grep $mcontainer | cut -d\  -f1) echo $(lsof 2>/dev/null | wc -l)
  for mcontainerid in $(docker ps -q) ; do
    docker ps | grep $mcontainerid  |& while read line ; do echo "$($LOGDATECMD) : $line"
    docker container exec -u 0 -it $mcontainerid sysctl fs.file-nr |& while read line ; do echo "$($LOGDATECMD) : $line" ; done
  done 
  echo

  echo
  echo $($LOGDATECMD) : TODO tcpdump? cloudfront ok? 
	#tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net 10.1.65.171/24'
	#tcpdump: non-network bits set in "10.1.65.171/24"
	#[pjalajas@sup-pjalajas-hub ~]$ tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net 10.1.65.0/24'
	#tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
	#listening on docker_gwbridge, link-type EN10MB (Ethernet), capture size 262144 bytes
	#23:15:04.464432 IP 172.18.0.5.56520 > kb.blackducksoftware.com.https: Flags [S], seq 1459481313, win 29200, options [mss 1460,sackOK,TS val 2815570037 ecr 0,nop,wscale 7], length 0
	#23:15:04.501202 IP kb.blackducksoftware.com.https > 172.18.0.5.56520: Flags [S.], seq 2131628224, ack 1459481314, win 43648, options [mss 1420,sackOK,TS val 1805783344 ecr 2815570037,nop,wscale 11], length 0
	#23:15:04.642558 IP kb.blackducksoftware.com.https > 172.18.0.5.56520: Flags [F.], seq 3998, ack 685, win 22, options [nop,nop,TS val 1805783486 ecr 2815570178], length 0
	#23:15:04.643573 IP 172.18.0.5.56520 > kb.blackducksoftware.com.https: Flags [F.], seq 716, ack 3999, win 306, options [nop,nop,TS val 2815570216 ecr 1805783485], length 0
	#23:15:04.730989 IP 172.18.0.5.36226 > server-13-35-78-111.bos50.r.cloudfront.net.https: Flags [S], seq 4144255938, win 29200, options [mss 1460,sackOK,TS val 2815570303 ecr 0,nop,wscale 7], length 0
	#23:15:04.733064 IP server-13-35-78-111.bos50.r.cloudfront.net.https > 172.18.0.5.36226: Flags [S.], seq 4188275936, ack 4144255939, win 28960, options [mss 1460,sackOK,TS val 2520440005 ecr 2815570303,nop,wscale 8], length 0
	#23:15:04.770695 IP 172.18.0.5.36226 > server-13-35-78-111.bos50.r.cloudfront.net.https: Flags [F.], seq 687, ack 5323, win 342, options [nop,nop,TS val 2815570343 ecr 2520440009], length 0
	#23:15:04.772371 IP server-13-35-78-111.bos50.r.cloudfront.net.https > 172.18.0.5.36226: Flags [F.], seq 31961, ack 687, win 118, options [nop,nop,TS val 2520440009 ecr 2815570338], length 0
	#23:15:05.061778 IP 172.18.0.5.56524 > kb.blackducksoftware.com.https: Flags [S], seq 1597547063, win 29200, options [mss 1460,sackOK,TS val 2815570634 ecr 0,nop,wscale 7], length 0
	#23:15:05.098674 IP kb.blackducksoftware.com.https > 172.18.0.5.56524: Flags [S.], seq 45536690, ack 1597547064, win 43648, options [mss 1420,sackOK,TS val 1781015594 ecr 2815570634,nop,wscale 11], length 0
	#23:15:05.253545 IP kb.blackducksoftware.com.https > 172.18.0.5.56524: Flags [FP.], seq 4176:4207, ack 701, win 23, options [nop,nop,TS val 1781015748 ecr 2815570773], length 31
	#23:15:05.254390 IP 172.18.0.5.56524 > kb.blackducksoftware.com.https: Flags [F.], seq 732, ack 4208, win 306, options [nop,nop,TS val 2815570826 ecr 1781015748], length 0
  echo

echo $($LOGDATECMD):1L : Done 

exit
#REFERENCE

#https://serverfault.com/a/885773
#      tcpdump [ -AbdDefhHIJKlLnNOpqStuUvxX# ] [ -B buffer_size ]
               #[ -c count ]
               #[ -C file_size ] [ -G rotate_seconds ] [ -F file ]
               #[ -i interface ] [ -j tstamp_type ] [ -m module ] [ -M secret ]
               #[ --number ] [ -Q|-P in|out|inout ]
               #[ -r file ] [ -V file ] [ -s snaplen ] [ -T type ] [ -w file ]
               #[ -W filecount ]
               #[ -E spi@ipaddr algo:secret,...  ]
               #[ -y datalinktype ] [ -z postrotate-command ] [ -Z user ]
               #[ --time-stamp-precision=tstamp_precision ]
               #[ --immediate-mode ] [ --version ]
               #[ expression ]


busybox:
Currently defined functions:
        [, [[, acpid, add-shell, addgroup, adduser, adjtimex, arch, arp,
        arping, ash, awk, base64, basename, bbconfig, beep, blkdiscard, blkid,
        blockdev, brctl, bunzip2, bzcat, bzip2, cal, cat, chgrp, chmod, chown,
        chpasswd, chroot, chvt, cksum, clear, cmp, comm, conspy, cp, cpio,
        crond, crontab, cryptpw, cut, date, dc, dd, deallocvt, delgroup,
        deluser, depmod, df, diff, dirname, dmesg, dnsdomainname, dos2unix, du,
        dumpkmap, dumpleases, echo, ed, egrep, eject, env, ether-wake, expand,
        expr, factor, fallocate, false, fatattr, fbset, fbsplash, fdflush,
        fdformat, fdisk, fgrep, find, findfs, flock, fold, free, fsck, fstrim,
        fsync, fuser, getopt, getty, grep, groups, gunzip, gzip, halt, hd,
        hdparm, head, hexdump, hostid, hostname, hwclock, id, ifconfig, ifdown,
        ifenslave, ifup, init, inotifyd, insmod, install, ionice, iostat, ip,
        ipaddr, ipcalc, ipcrm, ipcs, iplink, ipneigh, iproute, iprule,
        iptunnel, kbd_mode, kill, killall, killall5, klogd, less, link,
        linux32, linux64, ln, loadfont, loadkmap, logger, login, logread,
        losetup, ls, lsmod, lsof, lspci, lsusb, lzcat, lzma, lzop, lzopcat,
        makemime, md5sum, mdev, mesg, microcom, mkdir, mkdosfs, mkfifo,
        mkfs.vfat, mknod, mkpasswd, mkswap, mktemp, modinfo, modprobe, more,
        mount, mountpoint, mpstat, mv, nameif, nanddump, nandwrite, nbd-client,
        nc, netstat, nice, nl, nmeter, nohup, nologin, nproc, nsenter,
        nslookup, ntpd, od, openvt, partprobe, passwd, paste, patch, pgrep,
        pidof, ping, ping6, pipe_progress, pkill, pmap, poweroff, powertop,
        printenv, printf, ps, pscan, pstree, pwd, pwdx, raidautorun, rdate,
        rdev, readahead, readlink, readprofile, realpath, reboot, reformime,
        remove-shell, renice, reset, resize, rev, rfkill, rm, rmdir, rmmod,
        route, run-parts, sed, sendmail, seq, setconsole, setfont, setkeycodes,
        setlogcons, setpriv, setserial, setsid, sh, sha1sum, sha256sum,
        sha3sum, sha512sum, showkey, shred, shuf, slattach, sleep, smemcap,
        sort, split, stat, strings, stty, su, sum, swapoff, swapon,
        switch_root, sync, sysctl, syslogd, tac, tail, tar, tee, test, time,
        timeout, top, touch, tr, traceroute, traceroute6, true, truncate, tty,
        ttysize, tunctl, udhcpc, udhcpc6, umount, uname, unexpand, uniq,
        unix2dos, unlink, unlzma, unlzop, unshare, unxz, unzip, uptime, usleep,
        uudecode, uuencode, vconfig, vi, vlock, volname, watch, watchdog, wc,
        wget, which, whoami, whois, xargs, xxd, xzcat, yes, zcat

tcpdump cheatsheet:
-i any : Listen on all interfaces just to see if you’re seeing any traffic.
-i eth0 : Listen on the eth0 interface.
-D : Show the list of available interfaces
-n : Don’t resolve hostnames.
-nn : Don’t resolve hostnames or port names.
-q : Be less verbose (more quiet) with your output.
-t : Give human-readable timestamp output.
-tttt : Give maximally human-readable timestamp output.
-X : Show the packet’s contents in both hex and ASCII.
-XX : Same as -X, but also shows the ethernet header.
-v, -vv, -vvv : Increase the amount of packet information you get back.
-c : Only get x number of packets and then stop.
-s : Define the size of the capture in bytes. Use -s0 to get everything, unless you are intentionally capturing less.
-S : Print absolute sequence numbers.
-e : Get the ethernet header as well.
-q : Show less protocol information.
-E : Decrypt IPSEC traffic by providing an encryption key.


