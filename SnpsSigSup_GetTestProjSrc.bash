#!/usr/bin/bash
#SCRIPT: SnpsSigSup_GetTestProjSrc.bash
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/, https://www.synopsys.com/software-integrity/support.html
#LICENSE: SPDX Apache-2.0
#VERSION: 2011111403Z
#GREPVCKSUM: TODO 

#PURPOSE: To download open source project files for various Synopsys testing purposes.

#REQUIREMENTS

usage() {  
  cat << USAGEEOF 
    Usage: 
    --help -h display this help
    --debug -d debug mode (set -x)
    Needs lots of work.  A proof of concept.  Suggestions welcome. 
    Edit CONFIGs if any, then:
    bash ./SnpsSigSup_GetTestProjSrc.bash |& gzip -9 > /tmp/SnpsSigSup_GetTestProjSrc.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz 
    or, like:
    bash ./SnpsSigSup_GetTestProjSrc.bash |& tee /dev/tty |& gzip -9 > ./log/SnpsSigSup_GetTestProjSrc.bash_\$(date --utc +%Y%m%d%H%M%SZ%a)_\$(hostname -f).out.gz

    Takes several minute or so to run.
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
hostname -f
pwd

echo
echo $0
grep -i "^#version:" $0
md5sum $0
grep -i -v grepvcksum $0 | cksum
echo

#MAIN

#TODO: generalize 
#This is the list of currently supported Synopsys Black Duck Detect package managers. https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/631276245/Package+Managers+Supported+by+Detect#Maven-support
for mpkgmgr in BITBAKE CARGO COCOAPODS CONDA CPAN CRAN GIT GO_MOD GO_DEP GO_VNDR GO_VENDOR GO_GRADLE GRADLE HEX LERNA MAVEN NPM NUGET PACKAGIST PEAR PIP RUBYGEMS SBT SWIFT YARN CLANG
do
  echo
  echo downloading $mpkgmgr project release .gz archives
  wget --quiet --output-document=- "https://github.com/topics/${mpkgmgr}?o=desc&s=stars" | grep REPOSITORY_CARD | tr ' ' '\n' | grep href.*stargazers | sed -re 's#href="##g' -e 's#/stargazers"##g' | \
  head -n 200 | \
  while read mprojdir
  do
    echo mprojdir = $mprojdir
    echo downloading archives from "https://github.com${mprojdir}" # like https://github.com/spring-guides/gs-gradle
    #TODO:  wrap this block to download more pages of releases for each project
    wget --quiet --output-document=- "https://github.com${mprojdir}/releases" | \
      tr ';"&=' '\n' | grep -e "^/" | grep -e "only need one type of archive, dont need .zip" -e "\.gz" | \
    while read marchive ; do
      echo downloading $marchive...
      #https://github.com/spring-guides/gs-gradle/archive/2.1.6.RELEASE.zip
      wget --no-verbose --no-clobber --progress=dot --directory-prefix="./pkgmgrs/github.com/${mpkgmgr}${mprojdir}" "https://github.com/${marchive}"
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

[pjalajas@sup-pjalajas-hub test]$ echo $(date --utc ; hostname -f ; pwd ) ; echo ; find pkgmgrs/github.com/ -maxdepth 1 -type d | while read mdir ; do echo -n "du -sh: " ; du -sh $mdir ; echo -n "num projects: " ; find $mdir -type d | wc -l ; echo -n "num project versions: " ; find $mdir -type f | wc -l ; echo ; done
Wed Nov 11 13:28:23 UTC 2020 sup-pjalajas-hub.dc1.lan /home/pjalajas/dev/hub/test

du -sh: 26G     pkgmgrs/github.com/
num projects: 992
num project versions: 4981

du -sh: 209M    pkgmgrs/github.com/BITBAKE
num projects: 18
num project versions: 87

du -sh: 231M    pkgmgrs/github.com/CPAN
num projects: 43
num project versions: 194

du -sh: 94M     pkgmgrs/github.com/GO_MOD
num projects: 16
num project versions: 63

du -sh: 1.6G    pkgmgrs/github.com/CONDA
num projects: 50
num project versions: 246

du -sh: 518M    pkgmgrs/github.com/MAVEN
num projects: 41
num project versions: 181

du -sh: 28K     pkgmgrs/github.com/GO_DEP
num projects: 3
num project versions: 2

du -sh: 206M    pkgmgrs/github.com/HEX
num projects: 53
num project versions: 250

du -sh: 1.6G    pkgmgrs/github.com/LERNA
num projects: 43
num project versions: 204

du -sh: 1.5G    pkgmgrs/github.com/NPM
num projects: 49
num project versions: 286

du -sh: 938M    pkgmgrs/github.com/GRADLE
num projects: 43
num project versions: 188

du -sh: 77M     pkgmgrs/github.com/PACKAGIST
num projects: 54
num project versions: 197

du -sh: 157M    pkgmgrs/github.com/SBT
num projects: 42
num project versions: 248

du -sh: 3.1G    pkgmgrs/github.com/YARN
num projects: 42
num project versions: 186

du -sh: 1.6G    pkgmgrs/github.com/COCOAPODS
num projects: 55
num project versions: 280

du -sh: 3.8G    pkgmgrs/github.com/GIT
num projects: 47
num project versions: 545

du -sh: 4.5G    pkgmgrs/github.com/NUGET
num projects: 61
num project versions: 292

du -sh: 1.5G    pkgmgrs/github.com/CLANG
num projects: 46
num project versions: 211

du -sh: 1.3G    pkgmgrs/github.com/CRAN
num projects: 51
num project versions: 225

du -sh: 14M     pkgmgrs/github.com/PEAR
num projects: 37
num project versions: 110

du -sh: 1.5G    pkgmgrs/github.com/PIP
num projects: 46
num project versions: 201

du -sh: 290M    pkgmgrs/github.com/CARGO
num projects: 53
num project versions: 320

du -sh: 332M    pkgmgrs/github.com/RUBYGEMS
num projects: 49
num project versions: 232

du -sh: 1.3G    pkgmgrs/github.com/SWIFT
num projects: 49
num project versions: 233

'
