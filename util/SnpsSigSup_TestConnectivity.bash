#!/usr/bin/bash
#NAME: SynopsysScripts/util/SnpsSigSup_TestConnectivity.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-12-09
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#SUPPORT: https://community.synopsys.com, https://www.synopsys.com/software-integrity/support.html, Software-integrity-support@synopsys.com
#VERSION: 2012092029Z pj initial

#PURPOSE: To test Synopsys Detect connectivity to Black Duck server, etc 

#NOTES: Sorry it's so messy; it's in heavy use and modification all day every day.  Corrections, suggestions welcome, please!
#NOTES: Takes about 60 seconds to run. Log is about 1 MB compressed.

#USAGE: Edit below, then: time bash SnpsSigSup_TestConnectivity.bash 2>&1 | gzip -9 > /tmp/SnpsSigSup_TestConnectivity.bash_$(hostname -f)_$(date --utc +%F_%TZ_%a).out.gz  ^C

#CONFIG
#export SPRING_APPLICATION_JSON='{"blackduck.url":"https://127.0.0.1:443","blackduck.api.token":"ZTAxYjg2YjYtMDZhOC00M2VmLThmYmUtMzUxOTJlZjZkZDdkOjU3YjA0ZDIwLWMzN2YtNDE3YS04ZTE0LTJiNDM2MjAxM2JjZA=="}'
HOST_URL=https://sup-pjalajas-hub.dc1.lan  # with http protocol, no trailing slash


#MAIN
#lighter option:  -Djavax.net.debug=ssl,handshake 
( \
  JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all " \
  bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
    --blackduck.url=${HOST_URL} \
    --blackduck.username='sysadmin' \
    --blackduck.password='blackduck' \
    --detect.test.connection \
    --blackduck.trust.cert='true' \
    --logging.level.com.synopsys.integration=TRACE 2>&1 ; 
  echo ;
  curl --trace-ascii - -i -vvvv -D- ${HOST_URL} 2>&1 ;
  echo ;
  echo true | openssl s_client -debug -connect $HOST_URL:443 -prexit -status -msg -debug 2>&1 ; \
) 2>&1 | \
while read line 
do
  echo "$(date --utc +%F\ %T.%NZ\ %a) : $line"
done

#One liner exaample, excludes curl, openssl tests:  
#JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all " bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) --blackduck.url='https://sup-pjalajas-hub.dc1.lan' --blackduck.username='sysadmin' --blackduck.password='blackduck' --detect.test.connection --blackduck.trust.cert='false' --logging.level.com.synopsys.integration=TRACE 
