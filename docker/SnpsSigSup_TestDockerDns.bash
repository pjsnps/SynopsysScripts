#/usr/bin/bash
#Testing docker/puppet dns conflice workaround: "10.1.0.5", "10.1.0.6", 

date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a ; 
hostname -f ; 

cat /etc/resolv.conf ; 

#echo
#for mdns in '{}' '{ "dns": ["10.1.0.5", "10.1.0.6", "8.8.8.8"] }'
for mdns in '{}'
do
  #echo
  #echo testing docker dns = $mdns
  #echo "$mdns" > /etc/docker/daemon.json ; 
  #cat /etc/docker/daemon.json
  #echo restarting docker...
  #systemctl restart docker 
  #wait
  #iptables -L | head ; 
  echo -n "$(date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a)" 
  #echo pinging kb from docker container...
  echo $(time bash -c "docker run alpine time ping -c 1 kb.blackducksoftware.com |& cat -A ")
  #date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a 
  #echo
done



exit
#REFERENCE


[pjalajas@sup-pjalajas-hub docker]$ for mservice in docker puppet ; do echo -n "$mservice : " ; sudo systemctl status $mservice | grep Active: ; done
docker :    Active: active (running) since Mon 2020-10-05 16:53:54 EDT; 11min ago
puppet :    Active: active (running) since Tue 2020-09-22 16:46:20 EDT; 1 weeks 6 days ago



Mon Oct  5 20:06:30 UTC 2020
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc ; hostname -f ; sudo systemctl restart docker ; sudo iptables -L | head ; cat /etc/resolv.conf ; cat /etc/docker/daemon.json ; date --utc ; time bash -c "docker run --net=host alp
ine time ping -c 1 kb.blackducksoftware.com |& cat -A "; date --utc                                                                                                                                                                  
Mon Oct  5 20:08:14 UTC 2020
sup-pjalajas-hub.dc1.lan
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere             /* 000 INPUT allowrelated and established */ state RELATED,ESTABLISHED
REJECT     icmp --  anywhere             anywhere             /* 001 reject icmp timestamp requests */ icmp timestamp-request reject-with icmp-port-unreachable
REJECT     icmp --  anywhere             anywhere             /* 002 reject icmp timestamp-reply requests */ icmp timestamp-reply reject-with icmp-port-unreachable
ACCEPT     icmp --  anywhere             anywhere             /* 003 accept all icmp requests */
ACCEPT     all  --  anywhere             anywhere             /* 004 INPUT allow loopback */
ACCEPT     tcp  --  anywhere             anywhere             multiport dports 5666 /* 006 allow nrpe */
ACCEPT     tcp  --  anywhere             anywhere             multiport dports ssh /* 007 allow ssh */
ACCEPT     udp  --  anywhere             anywhere             multiport dports snmp /* 008 allow snmp */
# Generated by NetworkManager
search dc1.lan
nameserver 10.1.0.5
nameserver 10.1.0.6
{ "dns": ["10.1.0.5", "10.1.0.6", "8.8.8.8"] }  
Mon Oct  5 20:08:33 UTC 2020
PING kb.blackducksoftware.com (35.224.73.200): 56 data bytes$
64 bytes from 35.224.73.200: seq=0 ttl=94 time=46.612 ms$
$
--- kb.blackducksoftware.com ping statistics ---$
1 packets transmitted, 1 packets received, 0% packet loss$
round-trip min/avg/max = 46.612/46.612/46.612 ms$
real^I0m 0.04s$
user^I0m 0.00s$
sys^I0m 0.00s$

real    0m0.456s
user    0m0.019s
sys     0m0.028s
Mon Oct  5 20:08:34 UTC 2020
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d %H:%M:%S.%N ; hostname -f ; sudo systemctl restart docker ; sudo iptables -L | head ; cat /etc/resolv.conf ; cat /etc/docker/daemon.json ; date --utc ; time bash -c "doc
ker run --net=host alpine time ping -c 1 kb.blackducksoftware.com |& cat -A "; date --utc  ^C                                                                                                                                        
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d %H:%M:%S.%N 
date: extra operand ‘%H:%M:%S.%N’
Try 'date --help' for more information.
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d\ %H:%M:%S.%N                                                                                                                                                             
2020-10-05 20:10:30.404091419
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a 
2020-10-05 20:10:51.186041750Z Mon
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a 
2020-10-05 20:10:55.003780344Z Mon
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a ; hostname -f ; sudo systemctl restart docker ; sudo iptables -L | head ; cat /etc/resolv.conf ; cat /etc/docker/daemon.json ; date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a  ; time bash -c "docker run alpine time ping -c 1 kb.blackducksoftware.com |& cat -A " ; date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a 
2020-10-05 20:11:36.364925069Z Mon
sup-pjalajas-hub.dc1.lan
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere             /* 000 INPUT allowrelated and established */ state RELATED,ESTABLISHED
REJECT     icmp --  anywhere             anywhere             /* 001 reject icmp timestamp requests */ icmp timestamp-request reject-with icmp-port-unreachable
REJECT     icmp --  anywhere             anywhere             /* 002 reject icmp timestamp-reply requests */ icmp timestamp-reply reject-with icmp-port-unreachable
ACCEPT     icmp --  anywhere             anywhere             /* 003 accept all icmp requests */
ACCEPT     all  --  anywhere             anywhere             /* 004 INPUT allow loopback */
ACCEPT     tcp  --  anywhere             anywhere             multiport dports 5666 /* 006 allow nrpe */
ACCEPT     tcp  --  anywhere             anywhere             multiport dports ssh /* 007 allow ssh */
ACCEPT     udp  --  anywhere             anywhere             multiport dports snmp /* 008 allow snmp */
# Generated by NetworkManager
search dc1.lan
nameserver 10.1.0.5
nameserver 10.1.0.6
{ "dns": ["10.1.0.5", "10.1.0.6", "8.8.8.8"] }  
2020-10-05 20:11:41.223452691Z Mon
PING kb.blackducksoftware.com (35.224.73.200): 56 data bytes$
64 bytes from 35.224.73.200: seq=0 ttl=93 time=45.938 ms$
$
--- kb.blackducksoftware.com ping statistics ---$
1 packets transmitted, 1 packets received, 0% packet loss$
round-trip min/avg/max = 45.938/45.938/45.938 ms$
real^I0m 0.05s$
user^I0m 0.00s$
sys^I0m 0.00s$

real    0m0.444s
user    0m0.015s
sys     0m0.027s
2020-10-05 20:11:41.668468076Z Mon
[pjalajas@sup-pjalajas-hub mt_vacuum]$ date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a ; hostname -f ; sudo systemctl restart docker ; sudo iptables -L | head ; cat /etc/resolv.conf ; echo '{}' > /etc/docker/daemon.json ; date --utc +%Y-%
m-%d\ %H:%M:%S.%NZ\ %a  ; time bash -c "docker run alpine time ping -c 1 kb.blackducksoftware.com |& cat -A " ; date --utc +%Y-%m-%d\ %H:%M:%S.%NZ\ %a ; echo '{ "dns": ["10.1.0.5", "10.1.0.6", "8.8.8.8"] }                        
> ' > ^C
