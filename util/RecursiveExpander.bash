#!/usr/bin/bash
#SCRIPT: RecursiveExpander.bash
#AUTHOR: pjalajas@blackducksoftware.com, pjalajas@synopsys.com
#DATE: 2016-02-12, 2020-10-23
#VERSION:  2010231748Z
#LICENSE:  SPDX Apache-2.0
#SUPPORT:  https://community.synopsys.com/

#PURPOSE: Fully expands all supported archives (contain multiple files; sometimes also compressed, like .zip or .tar.gz) and compressed single files (.gz).  For statistics, or lightening server archive-processing load, or other purposes.

#USAGE: /fast/dev/RecursiveExpander.bash workspace/30188-PROD
#USAGE:       repeat as needed until no more are expanded.  Should only take up to like 5 times or so. 

#NOTES:  For each supported filename extension, script drills down into code tree and expands any such files it can see.  It does not process the expanded files at all--repeat as many times as needed so that no more expansions are reported, or until you get tired; consider putting in a loop. .

#TODO: convert to functions, pass each filetype/ext to its function
#TODO:  need to:
#    identify archive type
#    identify file listing command for that archive type
#    get listing of files within that archive
#    for each archive file with that archive expand it to pipe/dev/null to test
#    First draft, just expand top levels to /dev/null
#    Loop and count, detect when no more. 

#function expand_rpm {
        #rpm2cpio - | cpio --extract --only-verify-crc --quiet - > /dev/null
#}
#function expand_zip {
        ##file -
#}

for mzip in $(find "$1" -type f -iname "*\.zip") ; do 
    #echo "Unzipping ${mzip}    to  /dev/null"  # ${mzip%%.*}  
    echo ${mzip}  
    #unzip -n "${mzip}" -d /dev/null #  "${mzip%%.*}" 
    #echo "Making new directory ${mzip}/"
    #mkdir -p ${mzip}/
    #unzip "${mzip}" -d "${mzip%%.*}" 
    unzip "${mzip}" -d "${mzip}.exp" 
    #unzip -p "${mzip}" > /dev/null 
    #unzip -tv "${mzip}"  
    #unzip -p "${mzip}" \*.zip    > /dev/null   # -c option is like -p but also prints filename
    #unzip -p "${mzip}" \*.zip | expand_zip   > /dev/null   
    #unzip -p "${mzip}" \*.tar    > /dev/null
    #unzip -p "${mzip}" \*.tar.gz > /dev/null
    #unzip -p "${mzip}" \*.tgz    > /dev/null
    #unzip -p "${mzip}" \*.rpm | rpm2cpio - | cpio --extract --only-verify-crc --quiet - > /dev/null
    #unzip -p "${mzip}" \*.rpm | expand_rpm 
    #DO NOT REMOVE, NOT EXPANDING to file system! _rm_xxx -f "${mzip}" 
    #rm -f "${mzip}" 
    find "$1" -type f -wholename "$mzip" -delete 
done  

#No .tar.gz types, tar xf
for mtar in $(find "$1" -type f -iname "*\.tar") ; do 
    fullfile="$mtar"
    filename="${fullfile##*/}"
    echo $fullfile 
    export mnewdirfull="${fullfile}.exp"
    echo "Making \$mnewdirfull : $mnewdirfull"
    mkdir -p "${mnewdirfull}"
    tar xf "${mtar}" -C "${mnewdirfull}"
    if [ "$?" != "0" ] ; then
         echo -e "This command: \ntar xf "${mtar}" -C ${mnewdirfull} \nthrew an error...let's test the archive..."
         echo "First, removing target directory..."
         rm -rf "$mnewdirfull"
         file "$fullfile"
         mfiletype="$(file $fullfile | cut -d\: -f2)"  
         if [ $(echo "$mfiletype" | grep -ci " zip ") -gt 0 ] ; then 
               echo $fullfile is a ZIP, renaming to ${fullfile}.zip. Loop again to extract as ZIP file. 
               mv "$fullfile" "${fullfile}.zip"
         elif [ $(echo "$mfiletype" | grep -ci " gzip ") -gt 0 ] || [ $(echo "$mfiletype" | grep -ci "compress'd data 16 bits") -gt 0 ] ; then 
               echo $fullfile is a gzip, renaming to ${fullfile}.tar.gz. Loop again to extract as tar.gz file. 
               echo FIX ME!
               mv "$fullfile" "${fullfile}.tar.gz"
         fi 
    else
         #expanded successfully, delete source archive
         find "$1" -type f -wholename "$fullfile" -delete
    fi
echo ; echo
done  

#tar.gz types, tar xzf 
for mtar in $(find "$1" -type f -iname "*\.tar\.gz" -o -iname "*\.tgz" -o -iname "*\.tar.Z") ; do
    fullfile="$mtar"
    filename="${fullfile##*/}"
    echo $fullfile
    export mnewdirfull="${fullfile}.exp"
    echo "Making \$mnewdirfull : $mnewdirfull"
    echo "Expanding $mtar into $mnewdirfull ..."
    mkdir -p "${mnewdirfull}"
    tar xzf "${mtar}" -C "${mnewdirfull}"
    if [ "$?" != "0" ] ; then
         echo -e "This command: \ntar xf "${mtar}" -C ${mnewdirfull} \nthrew an error...let's test the archive..."
         echo "First, removing target directory..."
         rm -rf "$$mnewdirfull"
         file $fullfile
         mfiletype="$(file $fullfile | cut -d\: -f2)"
         if [ $(echo "$mfiletype" | grep -ci " zip ") -gt 0 ] ; then
               echo $fullfile is a ZIP, renaming to ${fullfile}.zip. Loop again to extract as ZIP file.
               mv "$fullfile" "${fullfile}.zip"
         elif [ $(echo "$mfiletype" | grep -ci " gzip ") -gt 0 ] || [ $(echo "$mfiletype" | grep -ci "compress'd data 16 bits") -gt 0 ] ; then
               echo $fullfile is a gzip, renaming to ${fullfile}.tar.gz. Loop again to extract as tar.gz file.
               echo FIX ME!
               mv "$fullfile" "${fullfile}.tar.gz"
         fi
    else
         #expanded successfully, delete source archive
         find "$1" -type f -wholename "$fullfile" -delete
    fi
echo ; echo
done
echo ; echo
echo "Done expanding this round.  Run again until no more expansions."
echo ; echo






#http://www.thegeekstuff.com/2010/04/view-and-extract-packages/
#  RPM is a sort of a cpio archive. First, convert the rpm to cpio archive using rpm2cpio command. 
#for mrpm in $(find "$1" -type f -iname "*\.rpm" ) ; do 
   #echo $mrpm
   ##rpm --verify $mrpm
   ##rpm --checksig $mrpm  
   #rpm2cpio $mrpm - | cpio --extract --only-verify-crc --quiet - > /dev/null
#done


exit
#REFERENCE



: '

multiline comment:


#!/bin/bash
#/fast/dev/FindExpandables.bash
#pjalajas@blackducksoftware.com
#2016-02-12


#CONFIG
mpathroot='.'
mpathroot='/fast/jenkins-homes/tranche1/jenkins-ccs/workspace/30188-PROD'
mpathroot=$1



#MAIN
echo $(date) $(hostname -f)

find $1 -type f -regextype posix-extended -iregex ".*\.(tar|zip|ear|ipa|apk|gem|war|tbz2|tbz|tgz|tb2|gz|bz2)$" -exec file {} \; 





exit
first draft:
#find "$mpathroot" -type f -iname "*.zip" -print0 | \
find "$mpathroot" -type f -regextype posix-extended -iregex ".*\.(zip|tar)$" -print0 | \
xargs -0 -Imin bash -c '
    filename=$(basename "min")
    mextension="${filename##*.}"
    mwholefilepathname="min"
    mfiletype=$(file -b ${mwholefilepathname})
    #echo \$mwholefilepathname : $mwholefilepathname
    #echo \$mfiletype : $mfiletype 
    #echo \$mextension : $mextension
    case $mextension in
        zip )
            if [[ "$mfiletype" != *"Zip archive data"* ]] ; then
                echo -e "$mwholefilepathname has filetype mismatch : \n     $mfiletype"
            fi
            ;;
        tar )
            if [[ "$mfiletype" != *"tar archive"* ]] ; then
                echo -e "$mwholefilepathname has filetype mismatch : \n     $mfiletype"
                if [[ "$mfiletype" == *"gzip compressed data"* ]] ; then
                    echo "Renaming..."
                    mv "$mwholefilepathname" "${mwholefilepathname}.gz"
                fi
            fi
            ;;
        gz )
            if [[ "$mfiletype" != *"gzip compressed data"* ]] ; then
                echo -e "$mwholefilepathname has filetype mismatch : \n     $mfiletype"
            fi
            ;;
    esac
'

exit
#REFERENCE

-bash-4.1$ find /fast/jenkins-homes/tranche1/jenkins-ccs/workspace/30188-PROD -type f -regextype posix-extended -iregex ".*\.(tar|zip|ear|ipa|apk|gem|war|tbz2|tbz|tgz|tb2|gz|bz2)$" -exec file {} \; | grep -v -e "\.zip\:.*Zip archive data" -e "\.tar\:.*tar archive" -e "\.gz\:.*gzip compressed data" -e "\.war\:.*Zip archive data" -e "\.apk\: Zip archive data"
-bash-4.1$

#-bash-4.1$ find . -type f -regextype posix-extended -iregex ".*\.zip$" -print0 | xargs -0 -I% file % | grep -v "\.zip\:.*Zip archive data"
string='My long string';

if [[ $string == *"My long"* ]]
then
  echo "It's there!";
fi


irst, get file name without the path:

filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"

Alternatively, you can focus on the last '/' of the path instead of the '.' which should work even if you have unpredictable file extensions:

filename="${fullfile##*/}"


gz: gzip compressed data
~
~



-bash-4.1$ /fast/dev/RecursiveExpander.bash /fast/dev/ShredMe/3400-PROD
/fast/dev/ShredMe/3400-PROD/2016CCOnlineSSLCerts.tar
Making $mnewdirfull : /fast/dev/ShredMe/3400-PROD/2016CCOnlineSSLCerts
tar: This does not look like a tar archive
tar: Skipping to next header
tar: Exiting with failure status due to previous errors
-bash-4.1$
-bash-4.1$
-bash-4.1$
-bash-4.1$ file /fast/dev/ShredMe/3400-PROD/2016CCOnlineSSLCerts.tar
/fast/dev/ShredMe/3400-PROD/2016CCOnlineSSLCerts.tar: Zip archive data, at least v2.0 to extract
-bash-4.1$


-bash-4.1$ rpm2cpio /fast/jenkins-homes/tranche3/jenkins-cib-markets/workspace/28411-UDBA-RC1/perl-5.8.0-101.EL3.x86_64.rpm - | cpio --extract --only-verify-crc -
71603 blocks
-bash-4.1$


-bash-4.1$ find /fast/jenkins-homes/tranche3/jenkins-cib-markets -type f -exec file {} + | cut -d\: -f2 | tr -s \  | sort | uniq -c | grep -e gzip -e compress -e tar -e archive -e extract -e RPM
     22  gzip compressed data, from Unix, last modified
      1  Macromedia Flash data (compressed), version 9
      2  POSIX tar archive (GNU)
      2  RPM v3.0 bin i386/x86_64 libaio-0.3.96-7
      2  RPM v3.0 bin i386/x86_64 perl-5.8.0-101.EL3
    303  Zip archive data, at least v1.0 to extract
     35  Zip archive data, at least v2.0 to extract


for mzip in $(find "$1" -type f -iname "*.zip") ; do 
    unzip -n "$mzip" -d "${mzip%%.*}" ; 
    rm -f "$mzip" ; 
done  # repeat as needed until no more .zips, repeat for other archives: .gz, .tgz, .gzip, .tar?
#

CREDIT: http://stackoverflow.com/a/965072
First, get file name without the path:
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
Alternatively, you can focus on the last '/' of the path instead of the '.' which should work even if you have unpredictable file extensions:
filename="${fullfile##*/}"

$mnewdirfull : /fast/dev/ShredMe/88135-RC1/cg/conf/Lev2/Web/SASEnvironmentManager/agent-5.8.0-EE/bundles/agent-5.8.0/product_connectors//snmp-1_0_2_tar_gz

'
