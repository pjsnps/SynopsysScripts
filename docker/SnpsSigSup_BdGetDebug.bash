#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetDebug.bash
#DATE: Sat Oct 10 14:25:25 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010101510Z
#GREPVCKSUM: 1487597899 3217

#PURPOSE:  Download the Synopsys Black Duck (Hub) web ui debug page(s) (<server>/ui/debug) from the docker swarm stack logstash container /var/lib/logstash/data/debug directory.

#NOTES:  Data will be current as of the last time the debug page(s) were refreshed in the web ui, I think.  To obtain current data with this script, simply navigate to and reresh the /ui/debug page, I think.   See REFERENCE below for ideas.  Ignore this warning: "Pseudo-terminal will not be allocated because stdin is not a terminal." (TODO)  Suggestions welcome. 

#USAGE:  Intends to be like a single-purpose linux utiltity to download "everything", so append pipe filters as you wish.  Edit commands as you wish, of course.  Probably best to redirect output to a file to send to Support team.  Comment/uncomment the RUN LOCALLY or RUN OVER SSH options.


#CONFIG

#SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server


#MAIN

#RUN LOCALLY:
docker container exec -u0 $(docker ps | grep logstash | cut -d' ' -f1) find /var/lib/logstash/data/debug -type f -exec cat "{}" +

#RUN OVER SSH:
SSH="ssh -t sup-pjalajas-2"  # to pull from remote Black Duck server
echo "Using this connection: $SSH"
$SSH docker container exec -u0 \$\(docker ps \| grep logstash \| cut -d\' \' -f1\) find /var/lib/logstash/data/debug -type f -exec cat "\{\}" \+





exit
#REFERENCE

#[pjalajas@sup-pjalajas-hub docker]$ cat SnpsSigSup_BdGetDebug.bash | bash | wc
#Pseudo-terminal will not be allocated because stdin is not a terminal.
#   6182  155449 2438526

#[pjalajas@sup-pjalajas-hub synopsysctl]$ ssh -t sup-pjalajas-2 docker container exec -u0 \$\(docker ps \| grep logstash \| cut -d\' \' -f1\) find /var/lib/logstash/data/debug -type f -exec cat \{\} \+ | cat | dos2unix | grep --color=always -e ".*" | less -inRF
#[pjalajas@sup-pjalajas-hub synopsysctl]$ ssh -t sup-pjalajas-2 docker container exec -u0 \$\(docker ps \| grep logstash \| cut -d\' \' -f1\) find /var/lib/logstash/data/debug -type f -exec cat \{\} \+ | cat | dos2unix | grep --color=always -e ".*" | wc
#Connection to sup-pjalajas-2 closed
   #6182  166073 2541937

#To get just the Current Queries to see if your Black Duck scan is still running:
#grep -Pzo '_name.*\n.*_description'    -z/--null-data Treat input and output data as sequences of lines.
#[pjalajas@sup-pjalajas-hub docker]$ cat SnpsSigSup_BdGetDebug.bash | bash | grep -Pzo '(?s)Current Queries.*?\n\n'
#To remove trailing spacies from queries output:
#[pjalajas@sup-pjalajas-hub docker]$ cat SnpsSigSup_BdGetDebug.bash | bash | grep -Pzo '(?s)Current Queries.*?\n\n' | sed -re 's/ *$//' | cat -A | less -inRF


#[pjalajas@sup-pjalajas-hub docker]$ bash --rpm-requires SnpsSigSup_BdGetDebug.bash | sort -u
#executable(bash)
#executable(cat)
#executable(Connection)
#executable(dos2unix)
#executable(grep)
#executable(less)
#executable([pjalajas@sup-pjalajas-hub)
#executable(Pseudo-terminal)
#executable(wc)
