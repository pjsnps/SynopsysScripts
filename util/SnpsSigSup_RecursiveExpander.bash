#!/usr/bin/bash
#SCRIPT: SnpsSigSup_RecursiveExpander.bash
#AUTHOR: pjalajas@blackducksoftware.com, pjalajas@synopsys.com
#DATE: 2016-02-12, 2020-10-23, 2020-11-11
#VERSION:  2011180228Z
#CHANGELOG: 2011180228Z note re TODO to report missing requirements only after failing to process such an archive (but keep going). 
#LICENSE:  SPDX Apache-2.0
#SUPPORT:  https://community.synopsys.com, https://www.synopsys.com/software-integrity/support.html, Software-integrity-support@synopsys.com

#PURPOSE: Fully expands all supported archives (contain multiple files; sometimes also compressed, like .zip or .tar.gz) and compressed single files (.gz).  For statistics, or lightening server archive-processing load, or other purposes.  See SUPPORTED EXTENSIONS.

#REQUIREMENTS:  
#gnu parallel https://www.gnu.org/software/parallel/

#USAGE: bash SnpsSigSup_RecursiveExpander.bash workspace/30188-PROD

#NOTES:  For each supported filename extension, script drills down into code tree and expands any such files it can see. For now, manually repeat until no more expansions performed (or tried).  

#TODO:  parallelize - done
#CHANGELOG: 2011180228Z note re TODO to report missing requirements only after failing to process such an archive (but keep going). 
#TODO:  speed up even more:  https://stackoverflow.com/questions/23483162/what-is-the-best-way-to-speed-up-a-find-command-on-a-huge-directory-tree-using-g -- DONE! wow!
#TODO:  add archive types; deal properly with bzip and gzip single files?
#TODO:  process bad archive errors
#TODO:  don't loop through file tree if no actual expansions; so fast now, maybe doesn't matter
#TODO:  auto loop until done; problem tracking status of gnu parallel threads -- done, but relies on touch /tmp/ file...
#TODO:  ?:convert to functions



#INIT

#Check REQUIREMENTS
if [[ "$(parallel --version |& grep "^GNU parallel" >& /dev/null ; echo $?)" != "0" ]] ; then
  echo "GNU parallel required.  https://www.gnu.org/software/parallel/"
  exit
fi
if [[ "$(bunzip2 --version |& grep "^bzip2" >& /dev/null ; echo $?)" != "0" ]] ; then
  echo "bunzip2 required.  http://www.bzip.org "
  exit
fi
#TODO:  unzip --version |& grep "^UnZip" 
#TODO:  tar
#TODO: gunzip


#SUPPORTED EXTENSIONS
#copy to here from case test block 
export msupportedstring='apk|ear|ipa|war|zip|tar.gz|tgz|tar|tbz|tbz2|taz|tb2|tlz|tzst|tz2|tz|bz|bz2|gzip' #  CURRENTLY SUPPORTED EXTENSIONS
#Set mexpanded to true at top of file tree search, immediately set to false, then set to true is any files attempted to be expanded.
#mexpanded=true 
touch "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded" # TODO can probably use better filename...
shopt -s lastpipe # so while find pipe doesn't drop mexpanded var in subprocess https://stackoverflow.com/a/5007089/12399192
date 
date --utc


#FUNCTIONS

function f_mexpand_dir {
    mkdir "${1}.expanded/"
    echo "${1}.expanded/"
}
export -f f_mexpand_dir

function f_main {

    #Parse input file name into fragments
    mfullfile="${1}"
    mfilename="${mfullfile##*/}"
    mextension="${mfilename##*.}"
    #mextension="$(echo $mfilename | grep -iPo "(tar.gz|tar|zip|ear|ipa|apk|gem|war|tbz2|tbz|tgz|tb2|gz|bz2)$")" # TO BE SUPPORTED EXTENSIONS
    #https://en.wikipedia.org/wiki/Tar_(computing)
    #TODO: gem|bz2)$")" # TO BE SUPPORTED EXTENSIONS
    #TODO:  add cpio; add?: rpm
    #NOTE:  do not expand .jar. TODO: or make it an option.
    mextension="$(echo $mfilename | grep -iPo "(${msupportedstring})$")" #  CURRENTLY SUPPORTED EXTENSIONS
    mextensionlower="$(echo "$mextension" | tr '[:upper:]' '[:lower:]')"


    #Process each type of filename extension:
    case $mextensionlower in
      apk|ear|ipa|war|zip)
        #all file types that can be expanded with unzip
        mexpanded_dir="$(f_mexpand_dir $mfullfile)"
        unzip "$mfullfile" -d "$mexpanded_dir" >& /dev/null
        mexitcode=$?
        mv -v "${mfullfile}" "${mfullfile}.processed"
        #export mexpanded=true
        touch "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
        ;;
      tar.gz|tgz|tar|tbz|tbz2|taz|tb2|tlz|tzst|tz2|tz)
        #all file types that can be expanded with "tar xf".
        mexpanded_dir="$(f_mexpand_dir $mfullfile)"
        tar xf "${mfullfile}" -C "${mexpanded_dir}" 2> /dev/null
        mexitcode=$?
        mv -v "${mfullfile}" "${mfullfile}.processed"
        #export mexpanded=true
        touch "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
        ;;
      bz|bz2)
        #all file types that can be expanded with "bunzip2".
        #TODO this may not work properly. Does it expand the file in place?  Is that OK? 
        mexpanded_dir="$(f_mexpand_dir $mfullfile)"
        bunzip2 "${mfullfile}" 2> /dev/null
        mexitcode=$?
        mv -v "${mfullfile}" "${mfullfile}.processed" # source may not exist with bunzip2
        #export mexpanded=true
        touch "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
        ;;
       gzip)
        #all file types that can be expanded with "gunzip".
        #TODO this may not work properly. Does it expand the file in place?  Is that OK? 
        mexpanded_dir="$(f_mexpand_dir $mfullfile)"
        gunzip "${mfullfile}" 2> /dev/null
        mexitcode=$?
        mv -v "${mfullfile}" "${mfullfile}.processed" # source may not exist with bunzip2
        #export mexpanded=true
        touch "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
        ;;
      *)
        #echo will ignore $mfilename
        mexitcode=0
       ;;
    esac

 
    #Process any expansion errors...
    if [[ "$mexitcode" != "0" ]] ; then
      echo "ERROR: $mfullfile :: exitcode : $mexitcode"
      mv "${mfullfile}.processed" "${mfullfile}.error"
      file "${mfullfile}.error"
      #TODO use "file" output to expand with correct tool; need to put big case block into a function? 
      #  Or just rename it here to the "correct" filename extension and it will be expanded on the next loop. 
      #  Be sure to touch the /tmp .mexpanded file so the while loop will run again.
      #  22  gzip compressed data, from Unix, last modified
      #  1  Macromedia Flash data (compressed), version 9
      #  2  POSIX tar archive (GNU)
      #  2  RPM v3.0 bin i386/x86_64 libaio-0.3.96-7
      #  2  RPM v3.0 bin i386/x86_64 perl-5.8.0-101.EL3
      #  303  Zip archive data, at least v1.0 to extract
      #  35  Zip archive data, at least v2.0 to extract
      rm -rf "${mfullfile}.expanded"
      mfiletype="$(file "${mfullfile}" | cut -d\: -f2)"  
      if [ $(echo "${mfiletype}" | grep -ci " zip ") -gt 0 ] ; then 
        mv "$mfullfile" "${mfullfile}.zip"
      elif [ $(echo "$mfiletype" | grep -ci " gzip ") -gt 0 ] || [ $(echo "$mfiletype" | grep -ci "compress'd data 16 bits") -gt 0 ] ; then 
        mv "$mfullfile" "${mfullfile}.gz"
      elif [ $(echo "$mfiletype" | grep -ci " tar archive ") -gt 0 ] ; then 
        mv "$mfullfile" "${mfullfile}.tar"
      fi 
    fi 
    
    echo # a little space between each supported file processed
}
export -f f_main




#MAIN

#while [[ "$mexpanded" == "true" ]]  
while [[ -f "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded" ]] ;
do
  echo searching for supported archives in file tree $1 ...
  #mexpanded=false 
  rm -f "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
       #seq -f "n%04g" 1 100 | xargs -n 1 -P 10 -I {} bash -c 'echo_var "$@"' _ {}
       #xargs -L1 -I'%' -P$(nproc) bash -c 'main "%"' 
       #find $1 -type f | parallel f_main {} 
       #very fast:  [pjalajas@sup-pjalajas-hub test]$ parallel find {} -iname "*.zip" ::: temp/maven/*
       #find "$mpathroot" -type f -regextype posix-extended -iregex ".*\.(zip|tar)$" -print0 | \
       #parallel f_main {} ::: find "${1}" -type f -regextype posix-extended -iregex ".*\.(tar.gz|gz|zip)$" 
       #parallel ffmpeg -i {} {.}.flac ::: *.wav  # process on left ::: input list on right
       # "(tar.gz|tar|zip|ear|ipa|apk|gem|war|tbz2|tbz|tgz|tb2|gz|bz2)$")" # TO BE SUPPORTED EXTENSIONS
       # TODO:  ADD 7zip
       #|tar|zip|ear|ipa|apk|gem|war|tbz2|tbz|tgz|tb2|gz|bz2)$")" # TO BE SUPPORTED EXTENSIONS
  #parallel f_main "{}" ::: "$(find "${1}" -type f -regextype posix-extended -iregex ".*\.(gz|tar|tar.gz|tbz|tbz2|zip)$")"  # CURRENTLY SUPPORTED EXTENSIONS
  parallel f_main "{}" ::: "$(find "${1}" -type f -regextype posix-extended -iregex ".*\.(${msupportedstring})$")"  # CURRENTLY SUPPORTED EXTENSIONS

done  # while mexpanded=true, while we expanded (or tried) something...


#WRAP UP

shopt -u lastpipe
rm -f "/tmp/SnpsSigSup_RecursiveExpander.bash.mexpanded"
date 
date --utc
echo No more supported achives, exiting...

exit

#REFERENCE
: '
multiline comment:

https://en.wikipedia.org/wiki/Zip_(file_format) :
Archiving only	ar cpio shar tar LBR WAD
Compression only	Brotli bzip2 compress gzip LZMA LZ4 lzip lzop SQ xz Zstandard
Archiving and compression	7z ACE ARC ARJ B1 Cabinet cfs cpt dar DGCA .dmg .egg kgb LHA LZX MPQ PEA RAR rzip sit sitx SQX UDA Xar zoo ZIP ZPAQ
Software packaging and distribution	APK APPX deb Package (macOS) RPM MSI ipa JAR WAR JavaRAR EAR XAP XBAP
Document packaging and distribution	OEB Package Format   OEBPS Container Format     Open Packaging Conventions   PAQ



#function expand_rpm {
        #rpm2cpio - | cpio --extract --only-verify-crc --quiet - > /dev/null
#}
#http://www.thegeekstuff.com/2010/04/view-and-extract-packages/
#  RPM is a sort of a cpio archive. First, convert the rpm to cpio archive using rpm2cpio command. 
#for mrpm in $(find "$1" -type f -iname "*\.rpm" ) ; do 
   #echo $mrpm
   ##rpm --verify $mrpm
   ##rpm --checksig $mrpm  
   #rpm2cpio $mrpm - | cpio --extract --only-verify-crc --quiet - > /dev/null
#done


#!/bin/bash
#/fast/dev/FindExpandables.bash
#pjalajas@blackducksoftware.com
#2016-02-12

-bash-4.1$ find /fast/jenkins-homes/tranche3/jenkins-cib-markets -type f -exec file {} + | cut -d\: -f2 | tr -s \  | sort | uniq -c | grep -e gzip -e compress -e tar -e archive -e extract -e RPM
     22  gzip compressed data, from Unix, last modified
      1  Macromedia Flash data (compressed), version 9
      2  POSIX tar archive (GNU)
      2  RPM v3.0 bin i386/x86_64 libaio-0.3.96-7
      2  RPM v3.0 bin i386/x86_64 perl-5.8.0-101.EL3
    303  Zip archive data, at least v1.0 to extract
     35  Zip archive data, at least v2.0 to extract

'
