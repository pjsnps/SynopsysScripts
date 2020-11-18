#/usr/bin/bash
#SCRIPT: SnpsSigSup_CheckSslDockerProxy.bash
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/, https://www.synopsys.com/software-integrity/support.html, Software-integrity-support@synopsys.com
#DATE:  2020-11-18
#LICENSE: SPDX Apache-2.0
#VERSION: 2011181833Z

#PURPOSE:  Check SSL connectivity through proxy from inside all active Docker containers.

#USAGE: bash /home/pjalajas/dev/git/SynopsysScripts/util/SnpsSigSup_CheckSslDockerProxy.bash |& tee -a /tmp/SnpsSigSup_CheckSslDockerProxy.bash_$(date --utc +%Y%m%d_%H%MSZ%a).out |& less -inRF                                                                                                                                                                                                

#NOTES:  Proxies can rewrite cert info, so need to check fingerprints.
#NOTES:  Work in progress.  Lightly tested.  Corrections, suggestions welcome, please!

#CONFIG
#Edit mserverlist below. 
#Edit grep CONTAINERS_TO_SKIP to skip some containers. 

#--> Hand enter proxy at "-proxy" below. If mitmproxy, use IP address.  # TODO fixme
#TODO: export mproxy=$(dig +short sup-proxy01.dc1.lan):8080 ; 
#TODO: export mproxyoption=" -proxy ${mproxy} "
#TODO: echo $mproxyoption

export mserverlist=" 
 updates.suite.blackducksoftware.com:443 
 kb.blackducksoftware.com:443 
 www.google.com:443 
" 

#INIT
date ; date --utc
hostname -f
echo

#MAIN

docker ps | \
  grep -v -e "CONTAINER.*NAMES" -e "CONTAINERS_TO_SKIP" -e "logstash" -e "cfssl" | \
  while read mcontainerline ; 
  do \
    mcontainerid=$(echo $mcontainerline | cut -d' ' -f1)  
    echo testing container $(echo $mcontainerline | cut -d' ' -f1-2)
    for mserver in $mserverlist
    do \
     echo testing reaching $mserver from $(echo $mcontainerline | cut -d' ' -f1-2) ; 
       docker container exec -u0 $(docker ps | grep $mcontainerid | cut -d' ' -f1) sh -c \
         ' 
           echo testing without explicit proxy...
           echo -n | openssl s_client -connect '\'$mserver\'' 2>&1 | openssl  x509 -text -fingerprint -sha256 2>&1 | grep -i -e checking -e fingerprint -e issuer: -e owner: -e subject: ; 
           echo testing through explicit proxy...
           echo -n | openssl s_client -proxy 10.1.65.70:8080 -connect '\'$mserver\'' 2>&1 | openssl x509 -text -fingerprint -sha256 2>&1 | grep -i -e checking -e fingerprint -e issuer: -e owner: -e subject: ;
           echo ; 
         ' ; 
          echo ; 
       done ; 
     echo ; echo "===============" ; echo ; 
  done 
     #|& tee /dev/tty >> /tmp/SnpsSigSupport_BDContainerSslCheck_$(date --utc +%Y%m%d_%H%MSZ%a).out 


#REFERENCE
example output:

Wed Nov 18 13:37:30 EST 2020
Wed Nov 18 18:37:30 UTC 2020
sup-pjalajas-2.dc1.lan

testing container daa0f99d6bcb blackducksoftware/blackduck-scan:2020.10.0
testing reaching updates.suite.blackducksoftware.com:443 from daa0f99d6bcb blackducksoftware/blackduck-scan:2020.10.0
testing without explicit proxy...
        Issuer: C = US, O = DigiCert Inc, CN = DigiCert SHA2 Secure Server CA
        Subject: C = US, ST = Massachusetts, L = Burlington, O = "Black Duck Software, Inc.", CN = updates.blackducksoftware.com
SHA256 Fingerprint=E1:A6:4D:30:25:C9:6E:70:28:8A:0C:CA:7A:FC:16:30:72:10:DA:3E:7A:A7:0B:9A:45:0F:02:D1:F6:A4:FA:2C
testing through explicit proxy...
        Issuer: CN = mitmproxy, O = mitmproxy
        Subject: CN = *.blackducksoftware.com, O = "Synopsys, Inc."
SHA256 Fingerprint=24:3A:63:71:41:01:87:5D:78:2F:1F:6D:9C:10:5E:BB:00:ED:DD:AE:9A:90:2B:90:3E:FB:61:37:CD:1D:53:81


testing reaching kb.blackducksoftware.com:443 from daa0f99d6bcb blackducksoftware/blackduck-scan:2020.10.0
testing without explicit proxy...
        Issuer: C = US, O = "Entrust, Inc.", OU = See www.entrust.net/legal-terms, OU = "(c) 2012 Entrust, Inc. - for authorized use only", CN = Entrust Certification Authority - L1K
        Subject: C = US, ST = California, L = Mountain View, O = "Synopsys, Inc.", CN = *.blackducksoftware.com
SHA256 Fingerprint=BE:E2:C4:75:14:A6:89:8B:8B:8C:F3:1C:6C:18:7F:28:26:04:0E:71:9B:75:57:BD:6A:E8:32:3E:72:D1:0F:D4
testing through explicit proxy...
        Issuer: CN = mitmproxy, O = mitmproxy
        Subject: CN = *.blackducksoftware.com, O = "Synopsys, Inc."
SHA256 Fingerprint=E0:CE:5F:CA:72:5F:8F:4C:34:5F:60:3C:72:EB:F1:10:15:4E:92:79:A8:D9:38:BE:88:81:CE:E3:9D:C8:82:63


testing reaching www.google.com:443 from daa0f99d6bcb blackducksoftware/blackduck-scan:2020.10.0
testing without explicit proxy...
        Issuer: C = US, O = Google Trust Services, CN = GTS CA 1O1
        Subject: C = US, ST = California, L = Mountain View, O = Google LLC, CN = www.google.com
SHA256 Fingerprint=D1:9C:90:86:55:89:6F:D0:AD:90:F2:24:45:E6:5A:72:79:E3:79:73:E8:CD:4B:4B:FB:18:D3:9D:8F:D6:02:3F
testing through explicit proxy...
        Issuer: CN = mitmproxy, O = mitmproxy
        Subject: CN = www.google.com, O = Google LLC
SHA256 Fingerprint=6B:65:E6:FA:2D:35:CB:AA:6C:28:05:B9:3A:96:7B:CF:28:70:75:A8:FA:27:8D:58:AC:BB:AA:77:96:E3:1B:3C
