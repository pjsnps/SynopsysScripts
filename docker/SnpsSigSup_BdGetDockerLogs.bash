#!/usr/bin/bash

#USAGE: sudo bash ./SynopsysScripts/docker/SnpsSigSup_BdGetDockerLogs.bash

#failed to parse time: journalctl --all --utc --output=verbose --unit=docker --since=-01:00 |& cat -A |& gzip -9 > /home/pjalajas/log/journalctl--all--utc--output_verbose--unit_docker_$(hostname -f)_$(date --utc +%Y%m%d%H%H%SZ%a).out.gz

#journalctl --all --utc --output=verbose --unit=docker --since=today |& cat -A |& gzip -9 > /tmp/journalctl--all--utc--output_verbose--unit_docker_$(hostname -f)_$(date --utc +%Y%m%d%H%H%SZ%a).out.gz
journalctl --all --utc --output=verbose --unit=docker --since=today |& cat -A | less -inRF # |& gzip -9 > /tmp/journalctl--all--utc--output_verbose--unit_docker_$(hostname -f)_$(date --utc +%Y%m%d%H%H%SZ%a).out.gz

exit
#REFERENCE
:'

       -a, --all
           Show all fields in full, even if they include unprintable characters or are very long.
       PJNOTE:  hence cat -A to clean up unprintables


       -S, --since=, -U, --until=
           Start showing entries on or newer than the specified date, or on or older than the specified date, respectively. Date specifications should be of the format "2012-10-30 18:17:16". If
           the time part is omitted, "00:00:00" is assumed. If only the seconds component is omitted, ":00" is assumed. If the date component is omitted, the current day is assumed. Alternatively
           the strings "yesterday", "today", "tomorrow" are understood, which refer to 00:00:00 of the day before the current day, the current day, or the day after the current day, respectively.
           "now" refers to the current time. Finally, relative times may be specified, prefixed with "-" or "+", referring to times before or after the current time, respectively.


[pjalajas@sup-pjalajas-2 SynopsysScripts]$ sudo journalctl --all --utc --output=verbose --unit=docker |& cat -A |& gzip -9 > ./log/journalctl--all--utc--output_verbose--unit_docker_$(hostname -f)_$(date --utc +%Y%m%d%H%H%SZ%a)_rds_fail.out.gz                
'
