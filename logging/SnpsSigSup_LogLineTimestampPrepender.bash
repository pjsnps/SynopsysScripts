#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_GreatPrepender.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 2103110317Z

#PURPOSE: Reads log lines in from pipe. If a line doesn't have a timestamp (like stack staces), this will prepend that line with the last known good timestamp.

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond
#TODO:  Slow...not sure what we can do...  Aggressively filter the input lines to your hour of interest. 

while read -r line
do
  #does it have a timestamp in the first few space-separated words?
  TIMETEST=$(echo "$line" | \
    cut -d\  -f1-4 | \
    grep -Po " 20[0-9]{2}-[01][0-9]-[0-3][0-9] [0-2][0-9](:[0-5][0-9]){2},[0-9]+Z\[GMT\] " | \
    sed -re 's/^ (.*) $/\1/g')
  if [[ "$TIMETEST" > "" ]] ; then
    #if so, then store its timestamp in LASTKNOWNTIME
    LASTKNOWNTIME=$TIMETEST
    ESTIMATED=" "
  else
    #no timestamp, so mark as estimated with ~
    ESTIMATED="~"
  fi
  echo "${LASTKNOWNTIME}${ESTIMATED}: $line"
done

exit
#REFERENCE
