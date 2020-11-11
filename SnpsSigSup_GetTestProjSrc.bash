#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetTestProjSrc.bash
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/, https://www.synopsys.com/software-integrity/support.html
#LICENSE: SPDX Apache-2.0
#VERSION: 2011110333Z
#GREPVCKSUM: TODO 

#PURPOSE: To download open source project files for various Synopsys testing purposes.

#REQUIREMENTS
#lspci: in package pcitutils

usage() {  
  cat << USAGEEOF 
    Usage: 
    --help -h display this help
    --debug -d debug mode (set -x)
    Needs lots of work.  A proof of concept.  Suggestions welcome. 
    Edit CONFIGs, then:
    sudo ./SnpsSigSup_GetTestProjSrc.bash |& gzip -9 > /tmp/SnpsSigSup_GetTestProjSrc.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz 
    or, like:
    sudo ./SnpsSigSup_GetTestProjSrc.bash |& tee /dev/tty |& gzip -9 > ./log/SnpsSigSup_GetTestProjSrc.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz

    Takes a minute or so to run.
USAGEEOF
  exit 1
  } 
export -f usage

debug() {
  set -x
}
export -f debug

#bad if [[ "$#" == "--help"  || "$#" == "-h" ]] ; then usage ; exit 0 ; fi 
#bad if [[ "$#" == "--debug" || "$#" == "-d" ]] ; then debug ; fi 

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    usage
    shift #  
    ;;
    -d|--debug)
    set -x
    shift #  
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters



#NOTES:  Generally quite safe, even when run as root. Only downloads project releases that are in .gz format. Currently only downloads first page (most recent) of (.gz) archives for each project.

#TODO: 
#Speed up with gnu parallel or xargs.

#CONFIG

#TODO these first few are broken:
OUTDIR=.

#INITIALIZE

echo
echo New script, lightly tested, lots of bugs and errors will be thrown.  Please send issues and suggestions to pjalajas@synopsys.com, thanks!
echo
date 
date --utc
id -a
pwd

echo
echo Running in shell...
#Credit: https://askubuntu.com/a/1022440
#Keep multiple in case of oddities
#ps -p "$$"
#sh -c 'ps -p $$ -o ppid=' | xargs ps -o cmd= -p #-bash
#sh -c 'ps -p $$ -o ppid=' | xargs -i readlink -f /proc/\{\}/exe #/bin/bash

echo
echo $0
grep [V]ersion $0
md5sum $0
grep -i -v grepvcksum $0 | cksum
echo

hostname -f
echo

#MAIN

#wget --mirror --no-parent --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://github.com/search?o=desc&q=build.gradle&s=forks&type=Repositories'
#wget --quiet --output-document=- 'https://github.com/search?o=desc&q=build.gradle&s=forks&type=Repositories' | tr ';' '\n' | grep "/spring-guides/gs-gradle"
#https://github.com/spring-guides/gs-gradle&quot
#:null}}" data-hydro-click-hmac="b7b7ffa6965744cc5fecf188f4e22068385a38e20ace761c5725f7e04591dd56" href="/spring-guides/gs-gradle">spring-guides/gs-<em>gradle</em></a>
            #<a class="muted-link" href="/spring-guides/gs-gradle/stargazers">
#wget --quiet --output-document=- 'https://github.com/search?o=desc&q=build.gradle&s=forks&type=Repositories' | tr ';"' '\n' | grep "https://github.com/.*/.*"

#https://github.com/search?o=desc&p=100&q=build.gradle&s=forks&type=Repositories

#mpage is the number of pages of the github repo listings that are parsed for projects from which to download archives. 
for mpage in {1..5} ; do 
  #works: wget --quiet --output-document=- "https://github.com/search?o=desc&p=${mpage}&q=build.gradle&s=forks&type=Repositories" | tr ';"&' '\n' | grep "https://github.com/.*/.*" | grep -v -e "github.com/notifications/" -e "github.com/search/" -e "github.com/site/"
  #  outputs rows like:  https://github.com/spring-guides/gs-gradle
  #Most STARS:  https://github.com/search?o=desc&q=build.gradle&s=stars&type=Repositories
  #Most FORKS:  wget --quiet --output-document=- "https://github.com/search?o=desc&p=${mpage}&q=build.gradle&s=forks&type=Repositories" | \
  wget --quiet --output-document=- "https://github.com/search?o=desc&p=${mpage}&q=build.gradle&s=stars&type=Repositories" | \
    tr ';"&' '\n' | \
    grep "https://github.com/.*/.*" | \
    grep -v -e "github.com/notifications/" -e "github.com/search/" -e "github.com/site/" | \
  head -n 1000 | \
  while read mprojpage
  do
    echo downloading archives from "${mprojpage}" # like https://github.com/spring-guides/gs-gradle
    mprojdir="$(echo ${mprojpage} | sed -re 's#https://##g')"
    echo mprojdir = $mprojdir
    #TODO:  wrap this block to download more pages of releases for each project
    wget --quiet --output-document=- "${mprojpage}/releases" | \
      tr ';"&=' '\n' | grep -e "^/" | grep -e "only need one type of archive, dont need .zip" -e "\.gz" | \
    while read marchive ; do
      #https://github.com/spring-guides/gs-gradle/archive/2.1.6.RELEASE.zip
      #       --directory-prefix=prefix
      # wget --no-verbose --no-clobber --progress=dot:mega --directory-prefix="./pkgmgrs/${mprojdir}" "https://github.com/${marchive}"
      wget --no-verbose --no-clobber --progress=dot --directory-prefix="./pkgmgrs/${mprojdir}" "https://github.com/${marchive}"
    done
    echo
  done
  echo 
done


#WRAP UP

echo
date
date --utc
echo Done $0.

exit
#REFERENCE
:'
multiline comment

output example:  

downloading archives from https://github.com/etiennestuder/gradle-credentials-plugin
mprojdir = github.com/etiennestuder/gradle-credentials-plugin
2020-11-10 23:51:41 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v2.1 [70740] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v2.1.tar.gz" [1]
2020-11-10 23:51:42 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v2.0 [69971] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v2.0.tar.gz" [1]
2020-11-10 23:51:42 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.7 [67612] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.7.tar.gz" [1]
2020-11-10 23:51:43 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.6 [67363] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.6.tar.gz" [1]
2020-11-10 23:51:43 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.5 [67308] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.5.tar.gz" [1]
2020-11-10 23:51:44 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.4 [63455] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.4.tar.gz" [1]
2020-11-10 23:51:44 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.3 [63058] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.3.tar.gz" [1]
2020-11-10 23:51:44 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.2 [62897] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.2.tar.gz" [1]
2020-11-10 23:51:45 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.1 [62533] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.1.tar.gz" [1]
2020-11-10 23:51:45 URL:https://codeload.github.com/etiennestuder/gradle-credentials-plugin/tar.gz/v1.0.0 [62334] -> "./pkgmgrs/github.com/etiennestuder/gradle-credentials-plugin/v1.0.0.tar.gz" [1]

downloading archives from https://github.com/szaza/tensorflow-example-java
mprojdir = github.com/szaza/tensorflow-example-java

downloading archives from https://github.com/vivin/gradle-semantic-build-versioning
mprojdir = github.com/vivin/gradle-semantic-build-versioning
2020-11-10 23:51:47 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/4.0.0 [99713] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/4.0.0.tar.gz" [1]
2020-11-10 23:51:47 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/3.0.4 [99970] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/3.0.4.tar.gz" [1]
2020-11-10 23:51:47 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/3.0.3 [99926] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/3.0.3.tar.gz" [1]
2020-11-10 23:51:48 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/3.0.2 [99719] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/3.0.2.tar.gz" [1]
2020-11-10 23:51:48 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/3.0.1 [99710] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/3.0.1.tar.gz" [1]
2020-11-10 23:51:48 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/3.0.0 [98788] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/3.0.0.tar.gz" [1]
2020-11-10 23:51:49 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/2.0.2 [71731] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/2.0.2.tar.gz" [1]
2020-11-10 23:51:49 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/2.0.1 [70360] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/2.0.1.tar.gz" [1]
2020-11-10 23:51:49 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/2.0.0 [69843] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/2.0.0.tar.gz" [1]
2020-11-10 23:51:50 URL:https://codeload.github.com/vivin/gradle-semantic-build-versioning/tar.gz/1.2.1 [68456] -> "./pkgmgrs/github.com/vivin/gradle-semantic-build-versioning/1.2.1.tar.gz" [1]

downloading archives from https://github.com/shakalaca/learning_gradle_android
mprojdir = github.com/shakalaca/learning_gradle_android

downloading archives from https://github.com/commercehub-oss/gradle-cucumber-jvm-plugin
mprojdir = github.com/commercehub-oss/gradle-cucumber-jvm-plugin
2020-11-10 23:51:51 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.13 [69047] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.13.tar.gz" [1]
2020-11-10 23:51:51 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.12 [68568] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.12.tar.gz" [1]
2020-11-10 23:51:52 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.11 [65680] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.11.tar.gz" [1]
2020-11-10 23:51:52 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.10 [65488] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.10.tar.gz" [1]
2020-11-10 23:51:52 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.9 [65384] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.9.tar.gz" [1]
2020-11-10 23:51:53 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.8 [65340] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.8.tar.gz" [1]
2020-11-10 23:51:53 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.6 [64636] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.6.tar.gz" [1]
2020-11-10 23:51:53 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.5 [64497] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.5.tar.gz" [1]
2020-11-10 23:51:54 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.4 [64260] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.4.tar.gz" [1]
2020-11-10 23:51:54 URL:https://codeload.github.com/commercehub-oss/gradle-cucumber-jvm-plugin/tar.gz/0.3 [62353] -> "./pkgmgrs/github.com/commercehub-oss/gradle-cucumber-jvm-plugin/0.3.tar.gz" [1]



Tue Nov 10 23:51:54 EST 2020
Wed Nov 11 04:51:54 UTC 2020
Done /home/pjalajas/dev/git/SynopsysScripts/SnpsSigSup_GetTestProjSrc.bash.


2307  15/07/20 14:46:57: curl -s https://archive.apache.org/dist/tomcat/ | tr '"' 'n' | grep -e "^[0-9]*.[0-9]*.[0-9]" | head | xargs -I'%' wget --spider --output-document=- --no-parent 'https://archive.apache.org/dist/tomcat/%'
 2297  15/07/20 14:38:03: #curl -s https://archive.apache.org/dist/tomcat/ | tr '"' '\n' | grep -e "^[0-9]*\.[0-9]*\.[0-9]" | xargs -I'%' wget --mirror --no-directories --no-parent 'https://archive.apache.org/dist/tomcat/%'
 2308  15/07/20 14:47:07: curl -s https://archive.apache.org/dist/tomcat/ | tr '"' '\n' | grep -e "^[0-9]*\.[0-9]*\.[0-9]" | head -n 100  | xargs -I'%' wget --spider --output-document=- --no-parent 'https://archive.apache.org/dist/tomcat/%'
 2313  15/07/20 14:48:35: wget --spider --recursive --output-document=- --no-parent 'https://archive.apache.org/dist/tomcat' | head -n 100
 2314  15/07/20 14:49:52: wget --spider --recursive --output-document=- --no-parent --reject=gif 'https://archive.apache.org/dist/tomcat' | head -n 100
 2331  15/07/20 15:00:59: wget --mirror --no-parent --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
 2332  15/07/20 16:58:34: wget --mirror --no-parent --no-clobber --continue --wait 1 --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
 2334  15/07/20 16:59:47: wget --mirror --no-parent  --continue --wait 1 --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
 2335  15/07/20 17:00:24: wget --mirror --no-parent  --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
 2342  15/07/20 22:31:55: #wget --mirror --no-parent  --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
 2344  15/07/20 22:32:01: wget --mirror --no-parent  --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
'
