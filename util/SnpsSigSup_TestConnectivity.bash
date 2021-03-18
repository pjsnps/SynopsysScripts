#!/usr/bin/bash
#NAME: SynopsysScripts/util/SnpsSigSup_TestConnectivity.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-12-09
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#SUPPORT: https://community.synopsys.com, https://www.synopsys.com/software-integrity/support.html, Software-integrity-support@synopsys.com
#VERSION:  2103151535Z # pj test kb

#PURPOSE: To test, among other things, Synopsys Detect connectivity to Black Duck server, etc 

#NOTES: New script, under development.  Corrections, suggestions welcome, please!
#NOTES: Takes about 60 seconds to run. Log is about 1 MB compressed.
#NOTES: Consider running this on a Synopsys Detect client host, Black Duck host, Black Duck or other container, Jenkins host, Jenkins job shell script, alternate sides of proxies and firewalls, etc.
#NOTES: See https://stackoverflow.com/a/22145195/12399192 for curl, nssdb, certutil, and the link therein to https://wiki.mozilla.org/NSS_Shared_DB_And_LINUX . See in other answer there, "updated curl libcurl and ca-certificates, but forgot nss".

#USAGE: Edit CONFIGs below, then: time bash SnpsSigSup_TestConnectivity.bash 2>&1 | gzip -9 > /tmp/SnpsSigSup_TestConnectivity.bash_$(hostname -f)_$(date --utc +%F_%TZ_%a).out.gz
#USAGE: time bash SynopsysScripts/util/SnpsSigSup_TestConnectivity.bash 2>&1 | less -inRF
#USAGE: Send output file to Synopsys Software Integrity Group Support team for review. 

#TODO
#convert keystore to pem for curl:  https://gist.github.com/Hakky54/049299f0874fd4b870257c6458e0dcbd
#add keystore options to curl, openssl tests. 
#add curl --trace-ascii - https://kb.blackducksoftware.com/api/health |& less -inRF                                                   


#CONFIG
TEST_HOST_PROTOCOL="https" # for detect and curl, like https
TEST_HOST=qa-hub-perf05.dc1.lan  # without protocol, no trailing slash
TEST_HOST=sup-pjalajas-2.dc1.lan  # without protocol, no trailing slash
TEST_HOST=sup-pjalajas-hub.dc1.lan  # without protocol, no trailing slash
TEST_HOST=kb.blackducksoftware.com  # without protocol, no trailing slash
TEST_HOST_PORT=443 # for openssl
#ALERT_TRUST_STORE="-Djavax.net.ssl.trustStore=/opt/blackduck/alert/security/blackduck-alert.truststore"
JAVAX_D=" -Djavax.net.debug=all " # lighter option:  -Djavax.net.debug=ssl,handshake  
JAVAX_D=" -Djavax.net.debug=all -Djavax.net.ssl.trustStore=/opt/blackduck/alert/security/blackduck-alert.truststore " # lighter option:  -Djavax.net.debug=ssl,handshake  
  #See:  https://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#Debug
BLACKDUCK_USERNAME=sysadmin
BLACKDUCK_PASSWORD=blackduck
BLACKDUCK_TRUST_CERTS=true # start with false (more secure), then change to true if needed
BLACKDUCK_TRUST_CERTS=false # start with false (more secure), then change to true if needed
LOGGING_LEVEL_INTEGRATION=TRACE
CURL_INSECURE="" # start with empty string (more secure), then change to "--insecure" if needed
CURL_INSECURE="--insecure" # start with empty string (more secure), then change to "--insecure" if needed
CURL_INSECURE="" # start with empty string (more secure), then change to "--insecure" if needed


#MAIN
( 
  echo Running detect...
  JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} ${JAVAX_D}" \
  bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
    --blackduck.url=${TEST_HOST_PROTOCOL}://${TEST_HOST} \
    --blackduck.username="${BLACKDUCK_USERNAME}" \
    --blackduck.password="${BLACKDUCK_PASSWORD}" \
    --detect.test.connection \
    --blackduck.trust.cert="${BLACKDUCK_TRUST_CERTS}" \
    --logging.level.com.synopsys.integration="${LOGGING_LEVEL_INTEGRATION}" \
    2>&1 ; 

  echo ;
  echo Running curl...
  curl ${CURL_INSECURE} --trace-ascii - -i -D- ${TEST_HOST_PROTOCOL}://${TEST_HOST} | cat ;

  echo ;
  echo Running openssl...
  echo true | openssl s_client -debug -connect ${TEST_HOST}:${TEST_HOST_PORT} -prexit -status -msg -debug 2>&1 ; 
  #VERSION: 2012100102Z # pj add server cert fingerprint to detect transparent proxy
  for DIGEST in "" "-SHA1" "-SHA256" ; do echo -n | openssl s_client -connect sig-repo.synopsys.com:443 2>&1 | openssl x509 ${DIGEST} -fingerprint -noout ; done | sort -u ;
  echo
) 2>&1 | \
while read line 
do
  echo "$(date --utc +%F\ %T.%NZ\ %a) : $line"
done

#One liner example, excludes curl, openssl tests:  
#JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all " bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) --blackduck.url='https://sup-pjalajas-hub.dc1.lan' --blackduck.username='sysadmin' --blackduck.password='blackduck' --detect.test.connection --blackduck.trust.cert='false' --logging.level.com.synopsys.integration=TRACE 

exit

#REFERENCE
: '
{
  "isPostgresqlHealthy": true,
  "isHbaseHealthy": true,
  "isGraphDbHealthy": true,
  "lastCheckedDate": "2021-03-15T15:56:53.079Z",
  "_meta": {
    "href": "/api/health",
    "links": []
  },
  "isHealthy": true
}



    --blackduck.trust.cert="${BLACKDUCK_TRUST_CERTS}" \
'
