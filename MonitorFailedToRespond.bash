#!/bin/bash
#NAME: MonitorFailedToRespond.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-02-04
#LICENSE: SPDX Apache-2.0
#VERSION: 2002042020Z

#GOAL:  Try to detect root cause of this error: Error in job execution: org.springframework.web.client.ResourceAccessException: I/O error on POST request for "https://kb.blackducksoftware.com:443/kbmatch/api/v1/matches/best": kb.blackducksoftware.com:443 failed to respond; nested exception is org.apache.http.NoHttpResponseException: kb.blackducksoftware.com:443 failed to respond

#USAGE: Confirm unix line terms, not windows ^M. cat -A <script>. Check cksum, hash.  
#USAGE: Run this on host, not in container.
#USAGE: Example: sudo ./MonitorFailedToRespond.bash |& while read line ; do echo "$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ) : $line" ; done |& tee -a /dev/tty | gzip -9 > /tmp/MonitorFailedToRespond.bash.$(date --utc +%Y%m%d_%H%M%S%Z%a).log.gz
#USAGE: View output with like: zless $(ls -1rt /tmp/MonitorFailedToRespond.bash.*.log.gz | tail -n 1)

#TODO:  
#debug org.springframework.web.client.ResourceAccessException?
#add jobrunner container
#make functions; generalize tests into loops with commands as vars
#does increasing timeout leave too many stale unused connections? use keepalives, retries, maxwaits instead? See man wget for examples, possible tests. 
#get container id once...

#CONFIG
msleep=5s # with units
mcontainer=jobrunner # to grep from docker ps

#INIT

#MAIN

echo monitoring host ulimit 
ulimit -a #TODO can do in container? 

while true ; do

echo
date
date --utc
hostname -f
pwd
whoami
echo ${0} ${1} ${2} ${3}
echo ${@}
echo
echo container : $mcontainer

for mcmd in uptime nproc "free -m" "df -hPT" ; do
  echo
  echo monitoring host $mcmd
  $mcmd
  echo
  echo host $mcmd : $($mcmd)
  echo
done

echo monitoring ifconfig
echo
echo host ifconfig
ifconfig
echo
echo host ifconfig one line
echo host ifconfig : $(ifconfig)
echo
echo container ifconfig
docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) ifconfig 
echo
echo container ifconfig one line
docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) sh -c 'echo container ifconfig : $(ifconfig)'
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
  echo host vmstat $mopt
  vmstat --$mopt --wide
  echo
  echo host vmstat --$mopt one line
  echo host vmstat --$mopt : $(vmstat --$mopt --wide)
  echo
  #no vmstat in busybox
    #echo container vmstat
    #docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) vmstat --$mopt --wide 
    #echo
    #echo container vmstat one line
    #docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) sh -c 'echo container vmstat --$mopt : $(vmstat --$mopt --wide)'
    #echo
done

echo
mcmd=netstat
#$ sudo docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) netstat -h
#netstat: unrecognized option: h
#BusyBox v1.29.3 (2019-01-24 07:45:07 UTC) multi-call binary.
#Usage: netstat [-ral] [-tuwx] [-enWp]
#Display networking information
#
        #-r      Routing table
        #-a      All sockets
        #-l      Listening sockets
                #Else: connected sockets
        #-t      TCP sockets
        #-u      UDP sockets
        #-w      Raw sockets
        #-x      Unix sockets
                #Else: all socket types
        #-e      Other/more information
        #-n      Don't resolve names
        #-W      Wide display
        #-p      Show PID/program name for sockets
echo monitoring $mcmd
echo
#for mopt in statistics
#for mopt in statistics aeW
#do 
  echo host $mcmd -$mopt
  $mcmd --statistics
  echo
  echo host $mcmd --statistics one line
  echo host $mcmd --statistics : $($mcmd --statistics)
  echo 
  echo host netstat --timers
  $mcmd --timers
  echo
  echo container $mcmd
  docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) $mcmd -aeW  
  echo
  echo container cat /proc/net/tcp wc -l
  docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) cat /proc/net/tcp | wc -l
  echo
  echo container cat /proc/net/tcp 
  docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) cat /proc/net/tcp 
  
  #echo
  #echo container $mcmd one line
  # varied content, so may not be useful as a one-liner anyway
  #BUG: docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) sh -c "echo container $mcmd -$mopt : $($mcmd -$mopt)"
  echo
#done

echo
echo monitoring strace network
echo
echo host strace
timeout 5 strace -e trace=network nc kb.blackducksoftware.com 443
#TODO: can do in container? 
echo

echo
#for mcmd in ping traceroute
#do
  #for mopt in kb.blackducksoftware.com
  #do
    echo
    echo monitoring ping kb.blackducksoftware.com
    echo host ping kb.blackducksoftware.com 
    timeout 5 ping kb.blackducksoftware.com
    echo
    #TODO: timeout 5 ping6 kb.blackducksoftware.com
    #echo
    echo container ping kb.blackducksoftware.com 
    #BUG HANGS: timeout 5 docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) ping kb.blackducksoftware.com
    docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 ping kb.blackducksoftware.com
    #BUG HANGS: timeout 5 docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) ping6 kb.blackducksoftware.com
    echo


    echo
    echo monitoring traceroute kb.blackducksoftware.com
    echo host tracepath kb.blackducksoftware.com 
    timeout 30 tracepath kb.blackducksoftware.com
    echo
    #timeout 10 tracepath6 kb.blackducksoftware.com
    #echo
    echo
    echo container traceroute kb.blackducksoftware.com 
    docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 30 traceroute kb.blackducksoftware.com
    echo
    #docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 traceroute6 kb.blackducksoftware.com
    #echo
  #done
#done

echo monitoring openssl
for mopt in kb.blackducksoftware.com
do
  # echo -n | openssl s_client -connect kb.blackducksoftware.com:443 2>&1 | openssl x509 -text | grep -e Subject: -e Issuer: -e DNS
  #    Issuer: C=US, O=DigiCert Inc, CN=DigiCert SHA2 Secure Server CA
  #    Subject: C=US, ST=Massachusetts, L=Burlington, O=Black Duck Software, Inc., OU=IT, CN=*.blackducksoftware.com
  #            DNS:*.blackducksoftware.com, DNS:blackducksoftware.com
  echo monitoring host openssl $mopt
  time (echo -n | openssl s_client -connect $mopt:443 2>&1 | openssl x509 -text | grep -e Subject: -e Issuer: -e DNS)
  #no ssl in busybox: echo monitoring containeopenssl $mopt
    #timeout 5 docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) traceroute6 kb.blackducksoftware.com
  echo
  echo monitoring container wget $mopt
    #timeout 5 docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) "wget --spider -S https://kb.blackducksoftware.com 2>&1"
  docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 wget --spider -S https://kb.blackducksoftware.com 
  echo
  echo monitoring container wget $mopt/api/authenticate
  #405 Method Not Allowed is ok
  time (docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) timeout -t 5 wget --spider -S https://kb.blackducksoftware.com/api/authenticate)
done

  echo
  echo monitoring host count open files 
  #slow: echo $(lsof 2>/dev/null | wc -l)
  sysctl fs.file-nr
  echo
  echo systctl fs.file-nr : $(sysctl fs.file-nr)
  echo
  echo monitoring container count open files 
  #docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) echo $(lsof 2>/dev/null | wc -l)
  docker container exec -u 0 -it $(sudo docker ps | grep $mcontainer | cut -d\  -f1) sysctl fs.file-nr 
  echo

  echo
  echo TODO tcpdump? cloudfront ok? 
	#sudo tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net 10.1.65.171/24'
	#tcpdump: non-network bits set in "10.1.65.171/24"
	#[pjalajas@sup-pjalajas-hub ~]$ sudo tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net 10.1.65.0/24'
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
  echo sleeping $msleep
  sleep $msleep
done 

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
