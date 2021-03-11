#!/usr/bin/bash
#NAME: pjdetect.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2019-09-19, 2020-11-14
#LICENSE: SPDX Apache-2.0
#VERSION: 2012101922Z pj customer n huge docker, offline, split
#SUPPORT: TODO

#PURPOSE: To make test scanning with Detect easier. 

#NOTES: Sorry it's so messy; it's in heavy use and modification all day every day.  
#NOTES: Corrections, suggestions welcome, please!

#USAGE: Edit lots below, then:

#USAGE: basic:  bash pjdetect.bash <source dir> <expand>

#USAGE: /home/pjalajas/Documents/dev/hub/test/pjdetect.bash |& while read line ; do echo "$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ) $line" ; done |& tee -a /home/pjalajas/log/pjdetect.bash_$(hostname)_$(date +%Y%m%d_%H%M%S%Z%a)PJ.log
#USAGE: sudo for docker local tar scan:  sudo /home/pjalajas/Documents/dev/customers/customer/pjdetect.bash |& tee -a /home/pjalajas/log/pjdetect.bash_$(hostname)_$(date +%Y%m%d_%H%M%S%Z%a)PJ.log

#USAGE: DOES NOT WORK YET:  to scan large number of dirs with new SnpsSigSup_RecursiveExpander.bash:  find pkgmgrs/github.com/ -maxdepth 3 -type d | sort -R | head -n 1 | while read mprojdir ; do echo ; date ; date --utc ; echo scanning "${mprojdir}" with detect ; time /home/pjalajas/Documents/dev/hub/test/pjdetect.bash "${mprojdir}" expand |& while read line ; do echo "$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ) $line" ; done ; echo done scanning "$mprojdir" with detect ; date ; date --utc ; echo ; echo sleeping 10s ; sleep 10s ; done |& tee -a /home/pjalajas/log/pjdetect.bash_$(hostname)_$(date +%Y%m%d_%H%M%S%Z%a)PJ.log 

#CONFIG

#export SPRING_APPLICATION_JSON='{"blackduck.url":"https://127.0.0.1:443","blackduck.api.token":"ZTAxYjg2YjYtMDZhOC00M2VmLThmYmUtMzUxOTJlZjZkZDdkOjU3YjA0ZDIwLWMzN2YtNDE3YS04ZTE0LTJiNDM2MjAxM2JjZA=="}'

#WARNING: may need to escape spaces in some properties. 
#TODO: echo Contents of ignore file:

#NOTES:

#Ignores are complicated, and somewhat broken:
# Madhu 2020-04-27 slack
#SEE: https://jira-sig.internal.synopsys.com/browse/HUB-23741
  #Not sure about relative paths for <path> below (may be from command line dir, or from java home, or other; test to confirm), but absolute paths for <path> are definitely OK. 
  #Not sure about trailing slashes for <path>. 
  #This works:  export JAVA_TOOL_OPTIONS=" -Duser.home=<path> " # ignore file has to be located here: <user.home>/.config/blackduck/ignore (but user.home can be anywhere, but applies to all of Synopsys Detect java)
  #This works:  export XDG_CONFIG_HOME=<path> # ignore file has to be located here: $XDG_CONFIG_HOME/blackduck/ignore 
  #This works:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=<path>/<file> " # ignore file can be anywhere, any name
  #This works: --detect.blackduck.signature.scanner.arguments="\ --exclude-from=<path>/<file>\ "  # ignore file can be anywhere, any name
#Lines in ignore file must have path from source root down to ignored directory, may have multiple subdirs, and must be wrapped in '/': CLI_Output.txt:DEBUG: Adding exclude pattern: '/ignoreme/tobeignored/'
#1. blackduck.scan.excludesFile = <any path>/ignore
#2. XDG_CONFIG_HOME = <some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#3. user.home = <some path> and $user.home/.config/blackduck/ignore
#If any of the above is true, it should work
#fail: export XDG_CONFIG_HOME=/home/pjalajas/.config
#fail: export user.home=/home/pjalajas
#need to pass to scan.scli?
#WORKS (still a code and doc bug):  export  JAVA_TOOL_OPTIONS=" -Duser.home=/home/pjalajas/ " # ignore file $user.home/.config/blackduck/ignore, full source path to ignored dir, full wrap in '/', sigscan only
#does not work:  export XDG_CONFIG_HOME=/home/pjalajas  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#WORKS:  export XDG_CONFIG_HOME=/home/pjalajas/.config/  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#WORKS:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=/home/pjalajas/.config/blackduck/ignore " 
#fail?:  export XDG_CONFIG_HOME=/home/pjalajas/.config/  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#works?:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=/home/pjalajas/.config/blackduck/ignore " 
unset XDG_CONFIG_HOME
unset JAVA_TOOL_OPTIONS


#export DETECT_LATEST_RELEASE_VERSION=4.4.1
#export DETECT_LATEST_RELEASE_VERSION=6.0.0
#export DETECT_LATEST_RELEASE_VERSION=5.4.0
#export DETECT_LATEST_RELEASE_VERSION=5.6.2
#export DETECT_LATEST_RELEASE_VERSION=6.1.0
#export DETECT_LATEST_RELEASE_VERSION=6.2.0
#export DETECT_LATEST_RELEASE_VERSION=6.3.0  # 2020.4.1
#Detect compatibility chart:  https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/177799187/Black+Duck+Release+Compatibility
unset DETECT_LATEST_RELEASE_VERSION

#phone home phonehome; In a network where access to outside servers is limited, this mechanism may fail, and those failures may be visible in the log. This is a harmless failure; Synopsys Detect will continue to function normally.
#To disable this mechanism, set the environment variable SYNOPSYS_SKIP_PHONE_HOME to true.
export SYNOPSYS_SKIP_PHONE_HOME=true
export DETECT_SKIP_PHONE_HOME=true   # one of these is old


#env # do later, after other settings are set
date
date --utc
hostname -f 
echo $HOME  # in env?
pwd  # in env?
#whoami # in env output
#ip addr
#ip link
vmstat -w
#netstat -s
####cat /proc/net/snmp



#SOURCE PATH SELECTION:

DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/pyriscope"   # customer problem/test project
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/plaban"   # pip requirements.txt file only
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/acegisecurity-1.0.7"  # customer 4 vs 5 report api 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/conda-bunda/hunspell-1.6.1-0"   # customer conda 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/steelstruts"   # huge
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/boost-asio-examples" # clang c/c++ .c .h
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/zlib-1.2.11" # clang c/c++ .c .h customer 788092
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/seamonkey"   # kind of an internal reference/ 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/monkeyfist"  # kind of an internal reference, du -sh: 5.6G 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/moab"  # huge, jars only, see also jsjam for huge javascript project #7900 jars:  --detect.source.path='/home/pjalajas/Documents/dev/hub/test/projects/moab' \
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/customer/pyyaml"  # pip3 install --target ./target PyYAML-3.12-cp35-cp35m-linux_x86_64.whl
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164"   # small, fast, good for testing exclusions
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/customer/customer_bootstrap_sortable"  # 
#[pjalajas@sup-pjalajas-hub customer_bootstrap_sortable]$ npm install /home/pjalajas/Documents/dev/hub/test/projects/customer/customer_bootstrap_sortable
DETECTSOURCEPATH="/home/pjalajas/node_modules/bootstrap-sortable/"  # ??? 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/customer/pyyaml"  # pip3 install --target ./target PyYAML-3.12-cp35-cp35m-linux_x86_64.whl
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/tomtiger"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/zlib-1.2.11"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/jsjam_source_20200527PJ.tar.gz"  #  WORKS
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/monkeyfist_source_20200527PJ.tar.gz"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bindmounts"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/multiexpanded/steelstruts"  # server killer, Qu'est-ce que c'est
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions" # small, exclusions test
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/jsjam"  # huge javascript project compilation, use buildless=true for now...
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/conda-bunda"   # customer conda 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/synopsys-detect"   # customer conda 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164"   # small, fast, good for testing exclusions
DETECTSOURCEPATH="/home/pjalajas/dev/hub/test/projects/cust/n/00816607"
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/moab"  # huge, jars only, see also jsjam for huge javascript project #7900 jars:  --detect.source.path='/home/pjalajas/Documents/dev/hub/test/projects/moab' \
#parallel du -sh "{}" ::: ls projects/multiexpanded/* | sort -k1hr | head
#27G     projects/multiexpanded/tomtiger27
#9.9G    projects/multiexpanded/tomtiger10
#8.8G    projects/multiexpanded/moab_jars9
#8.1G    projects/multiexpanded/steelstruts
#8.1G    projects/multiexpanded/steelstruts8
#8.0G    projects/multiexpanded/tomtiger8
#5.6G    projects/multiexpanded/monkeyfist5
#5.1G    projects/multiexpanded/steelstruts5
#5.1G    projects/multiexpanded/tomtiger5
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/multiexpanded/tomtiger5" 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/" # expanded, 6.7 GB, 21 versions, 497,293 files       [pjalajas@sup-pjalajas-hub test]$ du -sh /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ 6.7G    /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -maxdepth 1 -type d -iname "*.exp" | wc -l 21 [pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/Documents/dev/hub/test/pkgmgrs/github.com/GIT/go-gitea/gitea/ -type f | wc -l 497293
#Take source dir from command line first param $1 or from DETECTSOURCEPATH set immediately above.
DETECTSOURCEPATH="/home/pjalajas/dev/hub/test/projects/cust/n/00825119/fluentd-kubernetes-daemonset_v1.11.5-debian-cloudwatch-1.0.tar" # sig scans, but not docker scan     --detect.docker.image
DETECTSOURCEPATH="/home/pjalajas/dev/hub/test/projects/cust/n/00825119"
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/zlib-1.2.11" # clang c/c++ .c .h customer 788092
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/cust/h1/consul-master"
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164"   # small, fast, good for testing exclusions

DETECTSOURCEPATHMOD="${1:-${DETECTSOURCEPATH}}" # if source path set in $1 in command line then use that, else use the last one set above (command line option takes precedence).
echo Printing some of source tree to compare apples... 
find "${DETECTSOURCEPATHMOD}" | cut -c1-1000 | head -n 100 



#EXPAND: 
#TODO:  this doesn't work yet, path names getting mangled by gnu parallel? 
#OPTION:  run Recursive Expander because PkgMgr scans do not open archives. 
#RECURSIVEEXPANDCMD="/home/pjalajas/dev/git/SynopsysScripts/util/SnpsSigSup_RecursiveExpander.bash"
#if [[ "$2" == "expand" ]] ; then 
  #echo
  #echo Running $RECURSIVEEXPANDCMD...
  #bash ${RECURSIVEEXPANDCMD} "${DETECTSOURCEPATHMOD}" && wait # wait for all multi-threaded expansions to finish
  #echo
  #echo Printing some of source tree after expanding... 
  #find "${DETECTSOURCEPATHMOD}" | cut -c1-1000 | head -n 100 
  #echo
  #echo Done running $RECURSIVEEXPANDCMD.
  #echo
#fi



#MAIN COMMAND, but EDIT _many_ of these options as needed for your testing.  See messy bone yard below for command line switches.
#https://access.redhat.com/solutions/973783   
#unset DETECTSOURCEPATH
#unset DETECTSOURCEPATHMOD
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all " \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=ssl,handshake " \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=ssl:handshake:verbose:keymanager:trustmanager -Djava.security.debug=access:stack " \
echo
#export PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:~/.local/bin:~/bin:/opt/gradle/gradle-6.7.1/bin"
#export JAVA_HOME=/home/pjalajas/Documents/dev/ssl/apache-hc/httpcomponents-client-4.3.5/examples/org/apache/http/examples/client/jdk-11.0.2
#export PATH=/home/pjalajas/Documents/dev/ssl/apache-hc/httpcomponents-client-4.3.5/examples/org/apache/http/examples/client/jdk-11.0.2/bin:$PATH ; 
echo
echo PATH:
echo $PATH
echo 
echo which java:
which java ; 
echo
echo java -version
#echo "java version : $(java -version)"
java -version
echo
#keytool -list -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts -storepass changeit
#echo
env
echo
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djdk.security.allowNonCaAnchor=true -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts" \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djdk.security.allowNonCaAnchor=true -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts" \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djdk.security.allowNonCaAnchor=true -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts_root_webserver_socat" \
#ROOT cert only:
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djdk.security.allowNonCaAnchor=true -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts_nginx_root_only" \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all -Djava.security.debug=all -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts_nginx_root_only" \
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.debug=all "
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djava.security.debug=all "
#JAVA_TOOL_OPTIONS=" ${JAVA_TOOL_OPTIONS} -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts_root_webserver_socat " 
unset JAVA_TOOL_OPTIONS
echo JAVA_TOOL_OPTIONS
echo "$JAVA_TOOL_OPTIONS"
echo
    #--detect.project.name="PN_$(echo "${DETECTSOURCEPATHMOD}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    #--detect.project.version.name='PVN_$(date --utc +%m%d%H%M%SZ)' \
    #--detect.project.version.notes="$(date --utc +%m%d%H%M%SZ)\ pjalajas@synopsys.com" \
PN="PN_$(echo "${DETECTSOURCEPATHMOD}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%S.%NZ)"
PVN="PVN_${PN}"
    #--blackduck.url='https://webserver' \
JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS" bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
    --blackduck.url='https://sup-pjalajas-2.dc1.lan' \
    --blackduck.trust.cert='true' \
    --blackduck.username='sysadmin' \
    --blackduck.password='blackduck' \
\
    --detect.source.path="${DETECTSOURCEPATHMOD}" \
    --detect.project.name="${PN}" \
    --detect.project.version.name="${PVN}" \
    --detect.project.version.notes="${PN}\ ${PVN}\ pjalajas@synopsys.com" \
\
    --detect.included.detector.types=ALL \
    --detect.tools=ALL \
    --logging.level.com.synopsys.integration=INFO \
    --detect.detector.search.depth=200 \
\
\


exit # NOTE: keep at least one blank line above this exit command.  

#REFERENCE
: '
    --blackduck.url='https://sup-pjalajas-2.dc1.lan' \
    --detect.included.detector.types=GO_MOD \
    --detect.tools=DETECTOR \
    --detect.detector.buildless=false \
    --detect.detector.search.depth=15 \
    --logging.level.com.synopsys.integration=TRACE \
    --detect.diagnostic.extended \
    --detect.blackduck.signature.scanner.dry.run='false' \
    --detect.cleanup='false' \
    --detect.diagnostic \
    --blackduck.url='https://hub-webserver' \    <-- not in hub server cert SAN DNS, so it fails
    --detect.tools.excluded=SIGNATURE_SCAN \
    --blackduck.url='https://webserver' \        <--- this works, as long as nginx root.crt is in truststore used by Detect
    --detect.diagnostic \
https://github.com/blackducksoftware/synopsys-detect/blob/8a9f5da4ca1d43182f46e2a90449e34b82681b51/src/main/resources/application.properties

https://github.com/blackducksoftware/synopsys-detect/search?p=1&q=%22logging.level%22

Norman Ng Pete Jalajas  Though it's not obvious (or simple), log message formatting (including date format) is actually under user control. Detect uses Spring Boot logging, which means you can control log message format by setting (on the Detect command line, for example) Spring Boot properties like logging.pattern.console. More specifically, Detect uses Spring Boot's default Logback setup, which in turn uses java's SimpleDateFormat date format specifiers.

If you need details, these doc sets apply (because these are the libraries involved in Detect logging):
https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-logging
http://logback.qos.ch/manual/layouts.html
https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html

If you want to change the date format:
1. Read https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html to figure out the date format you want.
2. When running Detect, set the logging.pattern.console property.

Detect's default value for logging.pattern.console is:

%d{yyyy-MM-dd HH:mm:ss} ${LOG_LEVEL_PATTERN:%-6p}[%thread] %clr(---){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:%wEx}
If you simply wanted to add the timezone, you could add "z" to the date format, resulting in:

%d{yyyy-MM-dd HH:mm:ss z} ${LOG_LEVEL_PATTERN:%-6p}[%thread] %clr(---){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:%wEx}
This is a little easier to do if you run the Detect .jar directly:

java -jar synopsys-detect-6.7.0.jar --logging.pattern.console='%d{yyyy-MM-dd HH:mm:ss z} ${LOG_LEVEL_PATTERN:%-6p}[%thread] %clr(---){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:%wEx}'
Quoting/Escaping is complicated by the scripts. To do the same thing using the bash script:

./detect.sh --logging.pattern.console=\"%d{yyyy-MM-dd HH:mm:ss z} \\\${LOG_LEVEL_PATTERN:%-6p}[%thread] %clr\(---\){faint} %m%n\\\${LOG_EXCEPTION_CONVERSION_WORD:%wEx}\"
All that said, I think the request to add timezone to the default is worth considering, so we'll triage this at the next triage meeting. I think we should also consider adding info like the above to the Detect doc.

'



: '
    --detect.diagnostic \   # boolean, so =true is not required
    --detect.project.version.notes="$(echo "${DETECTSOURCEPATHMOD}")\ $(date --utc +%m%d%H%M%SZ)\ pjalajas@synopsys.com" \
    --blackduck.offline.mode='false' \
    --logging.level.detect='TRACE' \
    --detect.detector.search.continue=true \
    --detect.detector.search.depth=200 \
    --detect.source.path="${DETECTSOURCEPATHMOD}" \
\
    --detect.docker.image="fluent/fluentd-kubernetes-daemonset:v1.11.5-debian-cloudwatch-1.0" \
    --detect.project.name="PN_$(echo "${DETECTSOURCEPATHMOD}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.project.version.name='PVN_$(date --utc +%m%d%H%M%SZ)' \
    --detect.tools.excluded=SIGNATURE_SCAN \
pj_clone PVN_1106161352Z
    --detect.project.name="005752ZTue" \
    --detect.project.version.name='PVN_1106161352Z' \
    --detect.project.version.name='1.0' \
    --detect.project.name="PN_$(echo "${DETECTSOURCEPATH}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.project.version.name='PVN_$(date --utc +%m%d%H%M%SZ)' \
    --detect.project.name="PN_bcprov-jdk15on-164_1021015319Z" \
    --detect.project.version.name='pjclone2' \



Try to "exclude" or ignore a single file by hiding it (success: change owner/perms so detect cannot open it):
[pjalajas@sup-pjalajas-hub test]$ mv projects/bcprov-jdk15on-164/ignoreme.commons-lang-2.6.jar projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name "*commons-lang-2.6*" | parallel echo
projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | parallel mv {} {//}/.{/}
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name "*commons-lang-2.6*" | parallel echo
projects/bcprov-jdk15on-164/ignoreme/.commons-lang-2.6.jar
DNW (did not work):
/ignoreme/.commons-lang-2.6.jar
ignoreme/.commons-lang-2.6.jar#
» .commons-lang-2.6.jar
277.56 KB
Match Type
Exact Directory
Component
Apache Commons Lang 2.6
License
Apache-2.0
Usage
Dynamically Linked

try with chown && chmod:
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | parallel ls -al {}
-rw-r--r--. 1 pjalajas users 284220 Apr 15 12:39 projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | sudo /usr/local/bin/parallel chown root: {}                                                                                                                                                                                                                                                                         
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | parallel ls -al {}                                                                                                                                                                                                                                                                                                  
-rw-r--r--. 1 root root 284220 Apr 15 12:39 projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | sudo /usr/local/bin/parallel chmod 600 {}                                                                                                                                                                                                                                                                           
[pjalajas@sup-pjalajas-hub test]$ find projects/bcprov-jdk15on-164/ -name commons-lang-2.6.jar | parallel ls -al {}                                                                                                                                                                                                                                                                                                  
-rw-------. 1 root root 284220 Apr 15 12:39 projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
WORKS:  ignoreme/commons-lang-2.6.jar#
» commons-lang-2.6.jar
Detect and Black Duck see it, but Black Duck cannot open it.  
[pjalajas@sup-pjalajas-hub test]$ find /home/pjalajas/blackduck/runs/2020-09-28-20-09-46-507/scan/BlackDuckScanOutput/2020-09-28_20-09-52-413_1 -type f | parallel grep commons-lang
  -->  ScanProblem{childProblem=false, scanError=com.blackducksoftware.scan.api.ScanError@73790bb5, problem=Problem{exceptionType=java.io.IOException, cause=java.nio.file.AccessDeniedException: /home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar, message=/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar, stack=java.io.IOException: /home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar..., errorTime=1601323797223}}
  -->  ScanNode{id=4165, path=ignoreme/commons-lang-2.6.jar, parentId=null, type=FILE, name=commons-lang-2.6.jar, size=284220, archiveUri=, uri=file:///home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar, clientSignatures.size=0, sha1=null, md5=null, modifiedOn=null, createdOn=null}
DEBUG: visit failure, problem Problem{exceptionType=java.io.IOException, cause=java.nio.file.AccessDeniedException: /home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar, message=/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar, stack=java.io.IOException: /home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar..., errorTime=1601323797223}



    --___logging.level.com.synopsys.integration='TRACE' \
    -___de \
    --detect.blackduck.signature.scanner.exclusion.pattern.search.depth=200 \
    --detect.blackduck.signature.scanner.upload.source.mode=true \
    --detect.blackduck.signature.scanner.license.search=true \
    ??? -copyright-search 
    --blackduck.timeout=36000 \
    --blackduck.timeout=1800 \
    --detect.excluded.detector.types=ALL \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/' \
    --detect.detector.search.depth=200 \
    --detect.detector.search.continue=true \
These work: even though the log reports 2020-08-20T02:09:59.835717756Z 2020-08-19 22:09:59 DEBUG [main] --- Traversing directory: /home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/subdir1/subdir2
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/' \

These don't work:
    --detect.blackduck.signature.scanner.exclusion.patterns='/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/dir2/*/customerssl/*/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='*/customerssl/*/package-split/' \ ava.lang.IllegalArgumentException: The exclusion pattern: */customerssl/*/package-split/ is not valid. An exclusion pattern must start and end with a forward slash (/) and may not contain double asterisks (**).
    --detect.blackduck.signature.scanner.exclusion.name.patterns='*/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='/dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='*/customerssl/*/package-split' \
####

    --detect.blackduck.signature.scanner.arguments="\ --copyright-search\ --debug\ --insecure\ " \
    --detect.npm.arguments=install \
    --detect.detector.buildless=true \
    --detect.pip.only.project.tree=true \
    --detect.pip.project.name="PN$(echo "${DETECTSOURCEPATH}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.pip.project.version.name='PVN$(date --utc +%m%d%H%M%SZ)' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/' \
    WORKS:         --detect.blackduck.signature.scanner.exclusion.patterns='/customerssl/*/package-split/,/ignoreme/' \
    WORKS:         --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
                   --detect.blackduck.signature.scanner.exclusion.patterns='/varies/customerssl/*/package-split/' \
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.name.patterns='customerssl/**/package-split' \
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.name.patterns='customerssl/*/package-split,boost' \
    --detect.pip.project.name='PyYAML' \
    --detect.pip.project.version.name='3.12' \
    --de \
    -d \
    --detect.pip.only.project.tree=true \ #   By default, pipenv includes all dependencies found in the graph. Set to true to only include dependencies found underneath the dependency that matches the provided pip project and version name.
    --detect.parallel.processors=0 \
    --detect.blackduck.signature.scanner.memory=24476 \
    --detect.detector.search.depth=200 \
    --detect.blackduck.signature.scanner.exclusion.pattern.search.depth=200 \
    --detect.blackduck.signature.scanner.snippet.matching=SNIPPET_MATCHING \
    --detect.blackduck.signature.scanner.upload.source.mode=true \
    --detect.blackduck.signature.scanner.individual.file.matching=ALL \
    --detect.blackduck.signature.scanner.license.search=true \ # unrecognized option
   --detect.blackduck.signature.scanner.snippet.matching=NONE,SNIPPET_MATCHING,SNIPPET_MATCHING_ONLY,FULL_SNIPPET_MATCHING,FULL_SNIPPET_MATCHING_ONLY 
    --detect.blackduck.signature.scanner.individual.file.matching=NONE,SOURCE,BINARY,ALL 

    -#d \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='tobeignore?/alsoi?nor*,boost' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/boost/' \
    --detect.detector.search.exclusion='boost' \
    --detect.excluded.detector.types='NUGET' \
    --#logging.level.com.synopsys.integration='INFO' \
    #--blackduck.url='https://sup-pjalajas-2.dc1.lan' \
    --detect.detector.search.exclusion.files 

    --detect.detector.search.exclusion.patterns # A comma-separated list of directory name patterns to exclude from detector search.  While searching the source directory to determine which detectors to run, subdirectories whose name match a pattern in this list will not be searched. These patterns are file system glob patterns ('?' is a wildcard for a single character, '*' is a wildcard for zero or more characters).
    --detect.detector.search.exclusion # A comma-separated list of directory names to exclude from detector search.
    --detect.detector.search.exclusion.paths # A comma-separated list of directory paths to exclude from detector search. (E.g. 'foo/bar/biz' will only exclude the 'biz' directory if the parent directory structure is 'foo/bar/'.) This property performs the same basic function as detect.detector.search.exclusion, but lets you be more specific.
    --detect.detector.search.exclusion.defaults=true   # If true, these directories will be excluded from the detector search: bin, build, .git, .gradle, node_modules, out, packages, target.

    --detect.detector.search.exclusion.defaults='false' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='node_modules' \

    --blackduck.proxy.host=http://localhost \
    --blackduck.proxy.port=8900 \
    --blackduck.offline.mode='true' \
    --detect.blackduck.signature.scanner.dry.run='true' \
    --detect.detector.search.exclusion.defaults='true' \
    steelstruts failed: --detect.blackduck.signature.scanner.memory=8192 \
    --detect.blackduck.signature.scanner.memory=4096
    --blackduck.username='weak' \
    --blackduck.api.token='brokentoken' \
    --blackduck.url='https://sup-pjalajas-hub.dc1.lan' \
    --detect.required.detector.types='CONDA' \
    --detect.conda.environment.name='envpete' \
\
    --detect.excluded.detector.types='ALL' \
    --logging.level.detect='TRACE' \
    guessing -d controls, else longhand does; if shorthand set, it copies to longhand
    --logging.level.com.synopsys.integration='TRACE' \
    --logging.level.detect='TRACE' \
    -#d \
    #fail; should be JAVA -D system property  --detect.blackduck.signature.scanner.arguments="\ --debug\ --user.home=/home/pjalajas/\ " \
    --blackduck.scan.excludesFile = /home/pjalajas/.config/blackduck/ignore \
    --detect.tools.excluded=SIGNATURE_SCAN --detect.detector.search.depth=3 --detect.python.python3=true --detect.detector.search.exclusion.defaults=true --detect.pip.requirements.path=${DETECTSOURCEPATH}/requirements.txt \
    --detect.tools.excluded=ALL,NONE,DETECTOR,SIGNATURE_SCAN,BINARY_SCAN,POLARIS,DOCKER,BAZEL
    --detect.blackduck.signature.scanner.exclusion.name.patterns='tobeignore?/alsoi?nor*' \
    kind of works, parses req .txt file: --detect.tools.excluded=SIGNATURE_SCAN --detect.detector.search.depth=3 --detect.python.python3=true --detect.detector.search.exclusion.defaults=true --detect.pip.requirements.path=requirements.txt \
    could not find req file:  --detect.pip.requirements.path=/requirements.txt \
    --detect.pip.requirements.path=/requirements.txt \
    --detect.pipenv.path
\
NOTE: even though option name is exclusion.pattern.search.depth, it does not apply to exclusion.patterns (because those are full paths), but instead, only to exclusion.name.patterns

Work:
    --detect.blackduck.signature.scanner.exclusion.pattern.search.depth=60 \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='alsoignor*' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='alsoi?nored' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='also*,alsoignore?' \
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/bcprov-jdk15on-164.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/tobeignored/alsoignorable/commons-text-1.3.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/tobeignored/commons-io-2.6.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/gradle-wrapper.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
    --detect.detector.search.depth=10 \
    --detect.blackduck.signature.scanner.exclusion.pattern.search.depth=10 \
--#detect.blackduck.signature.scanner.arguments='\ --debug\ ' \
--#detect.blackduck.signature.scanner.arguments='\ --debug\  do not use two ....arguments switches, fails with obscure detect version error ' \
    --#WORKS: detect.blackduck.signature.scanner.arguments="\ --debug\ --exclude-from=${HOME}/config/blackduck/ignore\ " \
    extremely! large npm (.js) projects:  https://gist.github.com/anvaka/8e8fa57c7ee1350e3491#file-02-with-most-dependencies-md
    7900 jars:  --detect.source.path='/home/pjalajas/Documents/dev/hub/test/projects/moab' \
    --detect.detector.search.exclusion.paths='cli/src,cli/target,test' \
    --detect.detector.search.exclusion.defaults='false' \
    --detect.detector.search.exclusion.paths='cli/src,cli/target,test,bin,build,.git,.gradle,node_modules,out,packages,target' \
    #--detect.source.path=
    #--detect.docker.image='redis' \
    #--detect.docker.image='prom/prometheus:v2.14.0' \
    #--detect.docker.tar='/home/pjalajas/Documents/dev/hub/test/projects/docker_prometheus_v2.14.0/docker_prometheus_v2.14.0.tar' \
    #--detect.blackduck.signature.scanner.exclusion.name.patterns='\ '

    #NO WORK: --detect.blackduck.signature.scanner.arguments=\'--debug\ --exclude=\'\ \'\' \
    #DID NOT exclude that class file:  --detect.blackduck.signature.scanner.exclusion.name.patterns='QuotedStringTokenizer.class,*annotat*,tes*'  








[pjalajas@sup-pjalajas-hub test]$ sort -u -t\- pjdetect.bash 

    7900 jars:  --detect.source.path='/home/pjalajas/Documents/dev/hub/test/projects/moab' \
bash <(curl -k -s -L https://detect.synopsys.com/detect.sh) \
    --blackduck.api.token='brokentoken' \
    --blackduck.offline.mode='true' \
    --blackduck.password='blackduck' \
    --blackduck.proxy.host=http://localhost \
#--blackduck.proxy.ignored.hosts                                                  A comma separated list of regular expression host patterns that should not use the proxy.      
#--blackduck.proxy.ntlm.domain                                                    NTLM Proxy domain.                                                                             
#--blackduck.proxy.ntlm.workstation                                               NTLM Proxy workstation.                                                                        
#--blackduck.proxy.password                                                       Proxy password.                                                                                
    --blackduck.proxy.port=8900 \
#--blackduck.proxy.username                                                       Proxy username. 
    --blackduck.scan.excludesFile = /home/pjalajas/.config/blackduck/ignore \
    --blackduck.timeout=1800 \
    --blackduck.trust.cert='true' \
    --blackduck.url='https://sup-pjalajas-2.dc1.lan' \
    --blackduck.url='https://sup-pjalajas-hub.dc1.lan' \
    --blackduck.username='sysadmin' \
#cat $HOME/config/blackduck/ignore
     -copyright-search 
    could not find req file:  --detect.pip.requirements.path=/requirements.txt \
    -d \
date --utc
    -de \
    --detect.blackduck.signature.scanner.arguments="\ --copyright-search\ --debug\ --insecure\ " \
    --detect.blackduck.signature.scanner.arguments='\ --debug\ ' \
    --detect.blackduck.signature.scanner.arguments='\ --debug\  do not use two ....arguments switches, fails with obscure detect version error ' \
    --detect.blackduck.signature.scanner.dry.run='true' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='\ '
    --detect.blackduck.signature.scanner.exclusion.name.patterns='also*,alsoignore?' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='alsoignor*' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='alsoi?nored' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='*/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='/dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/customerssl/*/package-split' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='node_modules' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='tobeignore?/alsoi?nor*' \
    --detect.blackduck.signature.scanner.exclusion.name.patterns='tobeignore?/alsoi?nor*,boost' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/boost/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='*/customerssl/*/package-split/' \ ava.lang.IllegalArgumentException: The exclusion pattern: */customerssl/*/package-split/ is not valid. An exclusion pattern must start and end with a forward slash (/) and may not contain double asterisks (**).
    --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/dir2/*/customerssl/*/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.patterns='/varies/customerssl/*/package-split/' \
    --detect.blackduck.signature.scanner.exclusion.pattern.search.depth=10 \
    --detect.blackduck.signature.scanner.individual.file.matching=NONE,SOURCE,BINARY,ALL 
    --detect.blackduck.signature.scanner.license.search=true \ # unrecognized option
    --detect.blackduck.signature.scanner.memory=24476 \
    --detect.blackduck.signature.scanner.memory=4096
    --detect.blackduck.signature.scanner.snippet.matching=NONE,SNIPPET_MATCHING,SNIPPET_MATCHING_ONLY,FULL_SNIPPET_MATCHING,FULL_SNIPPET_MATCHING_ONLY 
    --detect.blackduck.signature.scanner.upload.source.mode=true \
    --detect.cleanup='false' \
    --detect.conda.environment.name='envpete' \
    --detect.detector.buildless=true \
    --detect.detector.search.continue=true \
    --detect.detector.search.depth=200 \
    --detect.detector.search.exclusion # A comma-separated list of directory names to exclude from detector search.
    --detect.detector.search.exclusion='boost' \
    --detect.detector.search.exclusion.defaults='false' \
    --detect.detector.search.exclusion.defaults='true' \
    --detect.detector.search.exclusion.defaults=true   # If true, these directories will be excluded from the detector search: bin, build, .git, .gradle, node_modules, out, packages, target.
    --detect.detector.search.exclusion.files 
    --detect.detector.search.exclusion.paths # A comma-separated list of directory paths to exclude from detector search. (E.g. 'foo/bar/biz' will only exclude the 'biz' directory if the parent directory structure is 'foo/bar/'.) This property performs the same basic function as detect.detector.search.exclusion, but lets you be more specific.
    --detect.detector.search.exclusion.paths='cli/src,cli/target,test' \
    --detect.detector.search.exclusion.paths='cli/src,cli/target,test,bin,build,.git,.gradle,node_modules,out,packages,target' \
    --detect.detector.search.exclusion.patterns # A comma-separated list of directory name patterns to exclude from detector search.  While searching the source directory to determine which detectors to run, subdirectories whose name match a pattern in this list will not be searched. These patterns are file system glob patterns ('?' is a wildcard for a single character, '*' is a wildcard for zero or more characters).
    --detect.docker.image='prom/prometheus:v2.14.0' \
    --detect.docker.image='redis' \
    --detect.docker.tar='/home/pjalajas/Documents/dev/hub/test/projects/docker_prometheus_v2.14.0/docker_prometheus_v2.14.0.tar' \
    --detect.excluded.detector.types='ALL' \
    --detect.excluded.detector.types='NUGET' \
    --detect.npm.arguments=install \
    --detect.parallel.processors=0 \
    --detect.pipenv.path
    --detect.pip.only.project.tree=true \ #   By default, pipenv includes all dependencies found in the graph. Set to true to only include dependencies found underneath the dependency that matches the provided pip project and version name.
    --detect.pip.project.name="PN$(echo "${DETECTSOURCEPATH}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.pip.project.name='PyYAML' \
    --detect.pip.project.version.name='3.12' \
    --detect.pip.project.version.name='PVN$(date --utc +%m%d%H%M%SZ)' \
    --detect.pip.requirements.path=/requirements.txt \
    --detect.project.name="PN_$(echo "${DETECTSOURCEPATH}" | tr / '\n' | tail -n 1)_$(date --utc +%m%d%H%M%SZ)" \
    --detect.project.version.name='PVN_$(date --utc +%m%d%H%M%SZ)' \
    --detect.project.version.notes="$(echo "${DETECTSOURCEPATH}" | tr / '\n' | tail -n 1)\ $(date --utc +%m%d%H%M%SZ)\ pjalajas@synopsys.com" \
    --detect.required.detector.types='CONDA' \
    --detect.source.path=
    --detect.source.path="${DETECTSOURCEPATH}" \
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions" # small, exclusions test
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/acegisecurity-1.0.7"  # customer 4 vs 5 report api 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164"   # small, fast, good for testing exclusions
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/bindmounts"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/boost-asio-examples" # clang c/c++ .c .h
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/conda-bunda/hunspell-1.6.1-0"   # customer conda 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/customer/customer_bootstrap_sortable"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/customer/pyyaml"  # pip3 install --target ./target PyYAML-3.12-cp35-cp35m-linux_x86_64.whl
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/jsjam"  # huge javascript project compilation, use buildless=true for now...
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/jsjam_source_20200527PJ.tar.gz"  #  WORKS
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/moab"  # huge, jars only, see also jsjam for huge javascript project #7900 jars:  --detect.source.path='/home/pjalajas/Documents/dev/hub/test/projects/moab' \
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/monkeyfist"  # kind of an internal reference, du -sh: 5.6G 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/monkeyfist_source_20200527PJ.tar.gz"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/multiexpanded/steelstruts"  # server killer, Qu'est-ce que c'est
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/plaban"   # pip requirements.txt file only
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/pyriscope"   # customer problem/test project
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/seamonkey"   # kind of an internal reference/ 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/steelstruts"   # huge
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/tomtiger"  # 
DETECTSOURCEPATH="/home/pjalajas/Documents/dev/hub/test/projects/zlib-1.2.11" # clang c/c++ .c .h customer 788092
DETECTSOURCEPATH="/home/pjalajas/node_modules/bootstrap-sortable/"  # ??? 
    --detect.tools.excluded=SIGNATURE_SCAN --detect.detector.search.depth=3 --detect.python.python3=true --detect.detector.search.exclusion.defaults=true --detect.pip.requirements.path=${DETECTSOURCEPATH}/requirements.txt \
    #DID NOT exclude that class file:  --detect.blackduck.signature.scanner.exclusion.name.patterns='QuotedStringTokenizer.class,*annotat*,tes*'  
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.name.patterns='customerssl/**/package-split' \
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.name.patterns='customerssl/*/package-split,boost' \
    DOES NOT WORK: --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
#does not work:  export XDG_CONFIG_HOME=/home/pjalajas  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#env
#export DETECT_LATEST_RELEASE_VERSION=4.4.1
#export DETECT_LATEST_RELEASE_VERSION=5.4.0
#export DETECT_LATEST_RELEASE_VERSION=5.6.2
#export DETECT_LATEST_RELEASE_VERSION=6.0.0
#export DETECT_LATEST_RELEASE_VERSION=6.1.0
#export DETECT_LATEST_RELEASE_VERSION=6.2.0
#export DETECT_LATEST_RELEASE_VERSION=6.3.0
export DETECT_SKIP_PHONE_HOME=true   # one of these is old
export SPRING_APPLICATION_JSON='{"blackduck.url":"https://127.0.0.1:443","blackduck.api.token":"ZTAxYjg2YjYtMDZhOC00M2VmLThmYmUtMzUxOTJlZjZkZDdkOjU3YjA0ZDIwLWMzN2YtNDE3YS04ZTE0LTJiNDM2MjAxM2JjZA=="}'
export SYNOPSYS_SKIP_PHONE_HOME=true
    extremely! large npm (.js) projects:  https://gist.github.com/anvaka/8e8fa57c7ee1350e3491#file-02-with-most-dependencies-md
#fail: export user.home=/home/pjalajas
#fail: export XDG_CONFIG_HOME=/home/pjalajas/.config
#fail?:  export XDG_CONFIG_HOME=/home/pjalajas/.config/  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#fails: bash <(curl --trace-ascii -k -s -L https://detect.synopsys.com/detect.sh) \
    #fail; should be JAVA -D system property  --detect.blackduck.signature.scanner.arguments="\ --debug\ --user.home=/home/pjalajas/\ " \
find $DETECTSOURCEPATH | cut -c1-1000 | head -n 100 
    guessing -d controls, else longhand does; if shorthand set, it copies to longhand
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/bcprov-jdk15on-164.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/commons-lang-2.6.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/gradle-wrapper.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/tobeignored/alsoignorable/commons-text-1.3.jar
/home/pjalajas/Documents/dev/hub/test/projects/bcprov-jdk15on-164/ignoreme/tobeignored/commons-io-2.6.jar
hostname -f 
#ip addr
#ip link
    kind of works, parses req .txt file: --detect.tools.excluded=SIGNATURE_SCAN --detect.detector.search.depth=3 --detect.python.python3=true --detect.detector.search.exclusion.defaults=true --detect.pip.requirements.path=requirements.txt \
#Lines in ignore file must have path from source root down to ignored directory, may have multiple subdirs, and must be wrapped in '/': CLI_Output.txt:DEBUG: Adding exclude pattern: '/ignoreme/tobeignored/'
    --#logging.level.com.synopsys.integration='INFO' \
    --logging.level.com.synopsys.integration='TRACE' \
    --logging.level.detect='TRACE' \
#need to pass to scan.scli?
#netstat -s
NOTE: even though option name is exclusion.pattern.search.depth, it does not apply to exclusion.patterns (because those are full paths), but instead, only to exclusion.name.patterns
  #Not sure about relative paths for <path> below (may be from command line dir, or from java home, or other; test to confirm), but absolute paths for <path> are definitely OK. 
  #Not sure about trailing slashes for <path>. 
    #NO WORK: --detect.blackduck.signature.scanner.arguments=\'--debug\ --exclude=\'\ \'\' \
#phone home phonehome; In a network where access to outside servers is limited, this mechanism may fail, and those failures may be visible in the log. This is a harmless failure; Synopsys Detect will continue to function normally.
#[pjalajas@sup-pjalajas-hub 00770013_443Error]$ du -sh /home/pjalajas/Documents/dev/hub/test/projects/* | sort -k1h
#[pjalajas@sup-pjalajas-hub customer_bootstrap_sortable]$ npm install /home/pjalajas/Documents/dev/hub/test/projects/customer/customer_bootstrap_sortable
#[proxy]
pwd
#SEE: https://jira-sig.internal.synopsys.com/browse/HUB-23741
    steelstruts failed: --detect.blackduck.signature.scanner.memory=8192 \
These work: even though the log reports 2020-08-20T02:09:59.835717756Z 2020-08-19 22:09:59 DEBUG [main] --- Traversing directory: /home/pjalajas/Documents/dev/hub/test/projects/00820057_RegexExclusions/dir1/dir2/varies1/customerssl/varies2/package-split/subdir1/subdir2
  #This works: --detect.blackduck.signature.scanner.arguments="\ --exclude-from=<path>/<file>\ "  # ignore file can be anywhere, any name
  #This works:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=<path>/<file> " # ignore file can be anywhere, any name
  #This works:  export JAVA_TOOL_OPTIONS=" -Duser.home=<path> " # ignore file has to be located here: <user.home>/.config/blackduck/ignore (but user.home can be anywhere, but applies to all of Synopsys Detect java)
  #This works:  export XDG_CONFIG_HOME=<path> # ignore file has to be located here: $XDG_CONFIG_HOME/blackduck/ignore 
#To disable this mechanism, set the environment variable SYNOPSYS_SKIP_PHONE_HOME to true.
unset DETECT_LATEST_RELEASE_VERSION
unset JAVA_TOOL_OPTIONS
unset XDG_CONFIG_HOME
#USAGE: /home/pjalajas/Documents/dev/hub/test/pjdetect.bash |& while read line ; do echo "$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ) $line" ; done |& tee -a /home/pjalajas/log/pjdetect.bash_$(hostname)_$(date +%Y%m%d_%H%M%S%Z%a)PJ.log
#USAGE: sudo for docker local tar scan:  [pjalajas@sup-pjalajas-hub projects]$ sudo /home/pjalajas/Documents/dev/customers/customer/pjdetect.bash |& tee -a /home/pjalajas/log/pjdetect.bash_$(hostname)_$(date +%Y%m%d_%H%M%S%Z%a)PJ.log
vmstat -w
#WARNING: may need to escape spaces in some properties. 
whoami
Work:
    --#WORKS: detect.blackduck.signature.scanner.arguments="\ --debug\ --exclude-from=${HOME}/config/blackduck/ignore\ " \
    WORKS:         --detect.blackduck.signature.scanner.exclusion.patterns='/*/customerssl/*/package-split/,/ignoreme/' \
    WORKS:         --detect.blackduck.signature.scanner.exclusion.patterns='/customerssl/*/package-split/,/ignoreme/' \
#works?:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=/home/pjalajas/.config/blackduck/ignore " 
#WORKS:  export JAVA_TOOL_OPTIONS=" -Dblackduck.scan.excludesFile=/home/pjalajas/.config/blackduck/ignore " 
#WORKS:  export XDG_CONFIG_HOME=/home/pjalajas/.config/  #<some path>/.config   and $XDG_CONFIG_HOME/blackduck/ignore
#works java -jar synopsys-detect-6.1.0.jar \
#WORKS (still a code and doc bug):  export  JAVA_TOOL_OPTIONS=" -Duser.home=/home/pjalajas/ " # ignore file $user.home/.config/blackduck/ignore, full source path to ignored dir, full wrap in '/', sigscan only
'
