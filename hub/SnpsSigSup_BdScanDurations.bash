#!/usr/bin/bash
#SCRIPT: SynopsysScripts/hub/SnpsSigSup_BdScanDurations.bash
#AUTHOR: pjalajas@synopsys.com
#DATE:  2021-01-07
#LICENSE: SPDX Apache-2.0
#VERSION: 2101072011Z
#pj initial 

#USAGE: Edit CONFIGs, then:
#USAGE: TODO 


isStart=true
grep -e startedAt -e finishedAt /home/pjalajas/dev/customer/hub-26627/scotiabank_test/results_sup-pjalajas-2.dc1.lan_20210107134055ZThu_pjalajas_2020120RC/sup-pjalajas-2_bds_logs-20210107T133201/scansummary/scanjobs-summary.json | head -n 100000 | cut -d: -f2- | tr -d '",' | \
while read line
do
  #echo $line
  if [[ $isStart == "true" ]]
    then #this is the first timestamp   
    #echo this is subtrahend 
    #ref:  subtract subtrahend from the minuend
    subtrahend="$line"
    #echo $subtrahend
    isStart=false
    continue
  else
  #not isStart
  #echo this is minuend
  minuend="$line"
  #echo $minuend
  #date math minuend-subtrahend
  # echo -n "$(($(date +%s -d "${myarray[${minuendindex}]}")-$(date +%s -d "${myarray[${subtrahendindex}]}")))_seconds "
  #DIFF=(`date +%s -d "$minuend"`-`date +%s -d "$subtrahend"`)/86400
  echo -n "$(($(date +%s -d "${minuend}")-$(date +%s -d "${subtrahend}"))) seconds " ; echo
  #echo DIFF=$DIFF
  isStart=true 
  fi
  #TODO finish me
done

exit
#REFERENCE
: '
 2021-01-06T21:29:48.430Z
[pjalajas@sup-pjalajas-2 scotiabank_test]$ grep -e startedAt -e finishedAt results_sup-pjalajas-2.dc1.lan_20210107134055ZThu_pjalajas_2020120RC/sup-pjalajas-2_bds_logs-20210107T133201/scansummary/scanjobs-summary.json | head | cut -d: -f2- | tr -d '",' |^C
'
