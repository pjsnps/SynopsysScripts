#!/usr/bin/bash
#/home/pjalajas/dev/git/SynopsysScripts/logging/SnpsSigSup_SedDated.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2021-03-10
#LICENSE : SPDX Apache-2.0
#VERSION: 2103110317Z

#PURPOSE: Reads log lines in from pipe within a clock hour. Lines with no timestamp are also output. Pipe these into GreatPrepender.bash.

#NOTES: Designed for Black Duck system logs downloaded from web ui of format like:
#   [4d7f6f0d393a] 2021-03-03 23:59:57,541Z[GMT] [pool-10-thread-43] INFO org.apache.http.impl.execchain.RetryExec - I/O exception (org.apache.http.NoHttpResponseException) caught when processing request to {tls}->http://10.251.20.33:8300->https://kb.blackducksoftware.com:443: The target server failed to respond
#TODO:  Slow...not sure what we can do...  Aggressively filter the input lines to your hour of interest. 

while read -r line
do
  echo "$line" | sed -nre "/2021-03-04 18:0[0-9]/,/2021-03-04 18:10/p" 
done

exit
#REFERENCE
