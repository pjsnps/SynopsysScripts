#!/usr/bin/bash
#~/dev/git/SynopsysScripts/logging/SnpsSigSup_LogHourlyDivider.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 2103102204Z

#PURPOSE: Splits log lines into hourly files for easier processing.

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond

FIRST_HOUR=18
NEXT_HOUR=$(( FIRST_HOUR + 1 ))
echo $FIRST_HOUR, $NEXT_HOUR
#sed -n -e '/BROWN/,/GREEN/p' colours.txt
#sed -n -e '/2021-03-04 18:00:/,/2021-03-04 [0-2][0-9]:/p' $1
#sed -n -e "/2021-03-04 ${FIRST_HOUR}/,/2021-03-04 ${NEXT_HOUR}/p" $1
sed -n -re "/2021-03-04 ${FIRST_HOUR}/,/2021-03-04 (?!${FIRST_HOUR)/p" $1

exit

while read -r line
do
  #does it have a timestamp in the first few space-separated words?
  HOUR=$(echo "$line" | \
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
  echo "$LASTKNOWNTIME :$ESTIMATED: $line"
done

exit
#REFERENCE
