#!/usr/bin/bash
#SCRIPT:  ./util/SnpsSigSup_HowTo_BdTrustCert.bash
#AUTHOR:  pjalajas@synopsys.com
#DATE:  2020-12-16
#LICENSE:  SPDX Apache-2.0 
#SUPPORT:  TODO

#NOTE: Would be nice, but probably too hard to make into a script.

: '
Get server cert, add to truststore, force client (Synopsys Detect in this case) to use that truststore


Check server cert

[pjalajas@sup-pjalajas-hub test]$ echo -n | openssl s_client -connect sup-pjalajas-hub.dc1.lan:443 2>&1 | openssl x509 -text | grep -e Subject: -e Issuer: -e DNS
Issuer: C = US, ST = Massachusetts, L = Burlington, O = "Black Duck Software, Inc.", OU = Engineering, CN = blackducksoftware
Subject: C = US, ST = Massachusetts, L = Burlington, O = "Black Duck Software, Inc.", OU = Engineering, CN = hub-webserver
DNS:localhost, DNS:webserver


Get server cert

openssl s_client -host sup-pjalajas-hub.dc1.lan -port 443 -showcerts > cert_chain.crt


Which truststore?

There are very many... 
Run client with -Djavax.net.debug at some level...
[pjalajas@sup-pjalajas-hub test]$ grep -i "trust.\?store.*cert" /home/pjalajas/log/pjdetect.bash_sup-pjalajas-hub.dc1.lan_20201216_134212ESTWedPJ.log
2020-12-16T18:42:27.365248534Z javax.net.ssl|FINE|01|main|2020-12-16 13:42:26.456 EST|Logger.java:765|Inaccessible trust store: /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts
2020-12-16T18:42:27.366650861Z javax.net.ssl|FINE|01|main|2020-12-16 13:42:26.457 EST|Logger.java:765|trustStore is: /etc/pki/java/cacerts

Use jssecacerts if you can. 


Import as trusted into trustkeystore

keytool -import -alias sup-pjalajas-hub.dc1.lan -file cert_chain.crt -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts -storepass changeit -noprompt

Detect brings along it's own truststore, which won't have your server cert in it.  You can probably import your server cert as trusted into the scan.cli jssecacerts, but I wouldn't trust it to survive. 

2020-12-16T19:13:36.977699490Z javax.net.ssl|DEBUG|01|main|2020-12-16 14:13:29.065 EST|TrustStoreManager.java:161|Inaccessible trust store: /home/pjalajas/blackduck/tools/Black_Duck_Scan_Installation/scan.cli-2020.10.0/jre/lib/security/jssecacerts
2020-12-16T19:13:36.979139867Z javax.net.ssl|DEBUG|01|main|2020-12-16 14:13:29.066 EST|TrustStoreManager.java:112|trustStore is: /home/pjalajas/blackduck/tools/Black_Duck_Scan_Installation/scan.cli-2020.10.0/jre/lib/security/cacerts


Add server cert DNS/SAN to /etc/hosts

[pjalajas@sup-pjalajas-hub test]$ grep webserver /etc/hosts
10.1.65.171 webserver hub-webserver sup-pjalajas-hub.dc1.lan


Force client to use your truststore and cert "DNS" name

Add a ton of debugging just in case
JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts" \
bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
--blackduck.url='https://webserver' \

'
