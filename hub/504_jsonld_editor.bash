#!/usr/bin/bash
#SCRIPT: 504_jsonld_editor.bash
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#DATE: Sat Jan 23 03:21:41 UTC 2021
#VERSION: 2101291930Z
#CHANGELOG: add LICENSE 

#PURPOSE:  Edit the project info in 1000s of jsonld files before uploading to Synopsys Black Duck server (in bdio zip).

#USAGE: Fulfill REQUIREMENTS. Unzip source bdio into new dir. cd to dir above new dir.  Edit CONFIGS, run bash <scriptname.


##########################
#REQUIREMENTS
#gnu parallel https://www.gnu.org/software/parallel/

##########################
#NOTES:
#BDIO files are compressed (with zip). 504 MB is compressed size. 
#Need to keep file numbers in serial number order, no gaps.
#Need to change project name (PN) and project version name (PVN) in all files to be "test#" where # is the current test number, like 0008.
#Need to change urn:uuid in all files to end in 000# where # is the current test number, like 0008.
#I think this is that idempotent thing where it can be run over and over without issue as it replaces previously created files.

##########################
#PLAN:
#Copy file 00 to 237 and 474 and so on a total of 6 times for a total number of 7 copies of 00 in the bdio. 

##########################
#CONFIG
export TEST_NUMBER="0009"
export BDIO_DIR="./test_${TEST_NUMBER}" # no trailing slash, should probably match TEST_NUMBER
export HIGH_NUMBER=236 # highest original bdio-entry-#.jsonld
export URN_UUID="99c8b185-859c-34b4-be23-2bd4445eb516"     #    urn:uuid:99c8b185-859c-34b4-be23-2bd4445eb516 [u]rn:uuid:[9]9c8b185-859c-34b4-be23-2bd4445eb51[6]
export SCAN_HAS_NAME="tomtiger10/PN_tomtiger10_0120061527Z/PVN_0120061528Z scan"  #    "@value" : "tomtiger10/PN_tomtiger10_0120061527Z/PVN_0120061528Z scan"
export PROJECT_HAS_NAME="PN_tomtiger10_0120061527Z"        #  "@value" : "PN_tomtiger10_0120061527Z"
export VERSION_HAS_NAME="PVN_0120061528Z"               #  "@value" : "PVN_0120061528Z"

##########################
#INIT

export NEW_STARTING_NUMBER=$(( HIGH_NUMBER + 1 )) # this will be added to input FILE number (00-based)
#export NEW_URN_UUID="$(echo $URN_UUID | sed -re "s/${URN_UUID}/$(echo $URN_UUID | cut -c 1-32)${TEST_NUMBER}/g")"
export NEW_URN_UUID="$(echo $URN_UUID | sed -re "s/${URN_UUID}/$(echo $URN_UUID | cut -c 1-32)${TEST_NUMBER}/g")"
echo NEW_URN_UUID=$NEW_URN_UUID
export NEW_SCAN_HAS_NAME="$(echo $SCAN_HAS_NAME | sed -re "s#${SCAN_HAS_NAME}#Test${TEST_NUMBER} scan#g" )"
export NEW_SCAN_HAS_NAME="Test${TEST_NUMBER} scan"
echo NEW_SCAN_HAS_NAME=$NEW_SCAN_HAS_NAME
#export NEW_PROJECT_HAS_NAME="$(echo $PROJECT_HAS_NAME | sed -re "s#${}#PN_Test_${TEST_NUMBER}#g" )"
export NEW_PROJECT_HAS_NAME="PN_Test_${TEST_NUMBER}"
echo NEW_PROJECT_HAS_NAME=$NEW_PROJECT_HAS_NAME
#export NEW_VERSION_HAS_NAME="$(echo $VERSION_HAS_NAME | sed -re "s#PVN_0120061528Z#PVN_Test_${TEST_NUMBER}#g" )"
export NEW_VERSION_HAS_NAME="PVN_Test_${TEST_NUMBER}"
echo NEW_VERSION_HAS_NAME=$NEW_VERSION_HAS_NAME
export ZIP_FILE_NAME=test_${TEST_NUMBER}.bdio
echo ZIP_FILE_NAME=${BDIO_DIR}/$ZIP_FILE_NAME

##########################
#MAIN

echo HIGH_NUMBER=$HIGH_NUMBER
echo NEW_STARTING_NUMBER=$NEW_STARTING_NUMBER

echo 'sed out original CONFIG values in source files before copying...'
#TODO how to safely handling special chars in strings for sed delim
echo $URN_UUID
echo $NEW_URN_UUID
#sed -i -re "s/${URN_UUID}/${NEW_URN_UUID}/g" bdio-*\.json
#WORKS: ls -1rt bdio-*\.jsonld | parallel --bar sed -i -re "s/${URN_UUID}/${NEW_URN_UUID}/g"
#sed -i -re "s#${SCAN_HAS_NAME}#${NEW_SCAN_HAS_NAME}#g" bdio-*\.json
#sed -i -re "s#${PROJECT_HAS_NAME}#${NEW_PROJECT_HAS_NAME}#g" bdio-*\.json
#sed -i -re "s#${VERSION_HAS_NAME}#${NEW_VERSION_HAS_NAME}#g" bdio-*\.json
#: '
#ls -1rt ${BDIO_DIR}/bdio-*\.jsonld | \
ls -1 ${BDIO_DIR}/bdio-entry-*\.jsonld | sort -t- -k3n | \
  parallel --bar \
    sed -i -r \
      -e \"s/${URN_UUID}/${NEW_URN_UUID}/g\" \
      -e \"s#${SCAN_HAS_NAME}#${NEW_SCAN_HAS_NAME}#g\" \
      -e \"s#${PROJECT_HAS_NAME}#${NEW_PROJECT_HAS_NAME}#g\" \
      -e \"s#${VERSION_HAS_NAME}#${NEW_VERSION_HAS_NAME}#g\"
#'


exit


#LEGACY 
echo 'read in list of source files, NOT header file, and make 6 copies of each for a total of 7 copies (7 * 81 MB = 567 MB > 504 MB goal)...'
ls -1 ${BDIO_DIR}/bdio-entry-*\.jsonld | sort -t- -k3n | \
while read FILE 
do
  echo processing $FILE
  #get number from filename
  #bdio-entry-00.jsonld
  NUMBER=$(echo $FILE | cut -d\- -f3 | cut -d\. -f1)
  #echo $NUMBER
  TARGET_LIST=''
  for MULTIPLE in {1..6} ; do
    #NEW_FILE_NUMBER=$(( 10#$NUMBER + NEW_STARTING_NUMBER ))  # https://stackoverflow.com/questions/24777597/value-too-great-for-base-error-token-is-08 so weird
    export NEW_FILE_NUMBER=$(( 10#$NUMBER + ( MULTIPLE * NEW_STARTING_NUMBER ) ))  # https://stackoverflow.com/questions/24777597/value-too-great-for-base-error-token-is-08 so weird
    #echo NEW_FILE_NUMBER=$NEW_FILE_NUMBER
    TARGET_LIST="$TARGET_LIST $NEW_FILE_NUMBER"  # see B C D E F G in parallel command in REFERENCE section below
    #echo $TARGET_LIST
    #TODO probably should use parallel here...
    #cp $FILE bdio-entry-${NEW_FILE_NUMBER}.jsonld  # Comment for TESTING.  UNcomment for Prod.
  done
  #parallel echo $FILE bdio-entry-{}.jsonld ::: ${TARGET_LIST}  # Comment for TESTING.  UNcomment for Prod.
  parallel --bar cp $FILE ${BDIO_DIR}/bdio-entry-{}.jsonld ::: ${TARGET_LIST}  # Comment for TESTING.  UNcomment for Prod.
done

#ls -1 ${BDIO_DIR}/bdio-entry-*\.jsonld | sort -t- -k3n | \
#zip -9 ${ZIP_FILE_NAME} $(ls -${BDIO_DIR}/bdio-*\.jsonld
zip -9 ${ZIP_FILE_NAME} $(ls -1 ${BDIO_DIR}/bdio-entry-*\.jsonld | sort -t- -k3n) 

ls -lh ${ZIP_FILE_NAME} 
echo "Hope that's big enough..."
echo "Now upload ${ZIP_FILE_NAME} to Black Duck (Hub) to break your server." 






exit
##########################
#REFERENCE
[pjalajas@sup-pjalajas-2 test8]$ parallel echo src_{1} target_{2} ::: A ::: B C D E F G
src_A target_B
src_A target_C
src_A target_D
src_A target_E
src_A target_F
src_A target_G


 1192  2021-01-21 20:21:18 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-
............/99c8b185-859c-34b4-be23-012345670006/g' FILE ; done ; grep urn:uuid
 1193  2021-01-21 20:21:24 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-
............/99c8b185-859c-34b4-be23-012345670006/g' $FILE ; done ; grep urn:uuid
 1194  2021-01-21 20:21:40 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-
............/99c8b185-859c-34b4-be23-012345670006/g' $FILE ; done ; grep -H urn:uuid $FILE
 1195  2021-01-21 20:21:58 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-
............/99c8b185-859c-34b4-be23-012345670006/g' $FILE ; grep -H urn:uuid $FILE ; done 
 1196  2021-01-21 20:22:22 EST Thu :: grep -e PN_ -e PVN_ bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld 
 1197  2021-01-21 20:23:09 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/PN_tomtiger10_0120061527
Z/test6/g' $FILE ; grep -H test6 $FILE ; done 
 1198  2021-01-21 20:23:34 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/PVN_0120061528Z/PVN_test
6/g' $FILE ; grep -H test6 $FILE ; done 
 1199  2021-01-21 20:25:14 EST Thu :: zip test6.bdio bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld 
 1200  2021-01-21 20:25:48 EST Thu :: docker container logs --details $(docker ps | grep scan | cut -d\  -f1) |& less -inRF
 1201  2021-01-21 20:26:49 EST Thu :: grep -e test5 bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld 
 1202  2021-01-21 20:27:11 EST Thu :: cpvi bdio-header.jsonld
 1203  2021-01-21 20:28:03 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/test6/test7/g' $FILE ; grep -H test6 $FILE ; done 
 1204  2021-01-21 20:28:11 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/test6/test7/g' $FILE ; grep -H test7 $FILE ; done 
 1205  2021-01-21 20:28:20 EST Thu :: grep -e test5 bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld 
 1206  2021-01-21 20:29:13 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-........0006/99c8b185-859c-34b4-be23-012345670007/g' $FILE ; grep -H urn:uuid $FILE ; done 
 1207  2021-01-21 20:29:24 EST Thu :: for FILE in bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld ; do sed -i -re 's/99c8b185-859c-34b4-be23-........0005/99c8b185-859c-34b4-be23-012345670007/g' $FILE ; grep -H urn:uuid $FILE ; done 
 1208  2021-01-21 20:29:36 EST Thu :: zip test7.bdio bdio-entry-00.jsonld bdio-entry-01.jsonld bdio-entry-02.jsonld bdio-entry-03.jsonld bdio-entry-04.jsonld bdio-header.jsonld 


HIGH_NUMBER=236
NEW_STARTING_NUMBER=237
processing bdio-entry-00.jsonld
NEW_FILE_NUMBER=237
NEW_FILE_NUMBER=474
NEW_FILE_NUMBER=711
NEW_FILE_NUMBER=948
NEW_FILE_NUMBER=1185
NEW_FILE_NUMBER=1422
processing bdio-entry-01.jsonld
NEW_FILE_NUMBER=238
NEW_FILE_NUMBER=475
NEW_FILE_NUMBER=712
NEW_FILE_NUMBER=949
NEW_FILE_NUMBER=1186
NEW_FILE_NUMBER=1423


[pjalajas@sup-pjalajas-2 test8]$ ls
bdio-entry-00.jsonld   bdio-entry-116.jsonld  bdio-entry-140.jsonld  bdio-entry-165.jsonld  bdio-entry-18.jsonld   bdio-entry-214.jsonld  bdio-entry-25.jsonld  bdio-entry-52.jsonld  bdio-entry-79.jsonld
bdio-entry-01.jsonld   bdio-entry-117.jsonld  bdio-entry-141.jsonld  bdio-entry-166.jsonld  bdio-entry-190.jsonld  bdio-entry-215.jsonld  bdio-entry-26.jsonld  bdio-entry-53.jsonld  bdio-entry-80.jsonld
bdio-entry-02.jsonld   bdio-entry-118.jsonld  bdio-entry-142.jsonld  bdio-entry-167.jsonld  bdio-entry-191.jsonld  bdio-entry-216.jsonld  bdio-entry-27.jsonld  bdio-entry-54.jsonld  bdio-entry-81.jsonld
bdio-entry-03.jsonld   bdio-entry-119.jsonld  bdio-entry-143.jsonld  bdio-entry-168.jsonld  bdio-entry-192.jsonld  bdio-entry-217.jsonld  bdio-entry-28.jsonld  bdio-entry-55.jsonld  bdio-entry-82.jsonld
bdio-entry-04.jsonld   bdio-entry-11.jsonld   bdio-entry-144.jsonld  bdio-entry-169.jsonld  bdio-entry-193.jsonld  bdio-entry-218.jsonld  bdio-entry-29.jsonld  bdio-entry-56.jsonld  bdio-entry-83.jsonld
bdio-entry-05.jsonld   bdio-entry-120.jsonld  bdio-entry-145.jsonld  bdio-entry-16.jsonld   bdio-entry-194.jsonld  bdio-entry-219.jsonld  bdio-entry-30.jsonld  bdio-entry-57.jsonld  bdio-entry-84.jsonld
bdio-entry-06.jsonld   bdio-entry-121.jsonld  bdio-entry-146.jsonld  bdio-entry-170.jsonld  bdio-entry-195.jsonld  bdio-entry-21.jsonld   bdio-entry-31.jsonld  bdio-entry-58.jsonld  bdio-entry-85.jsonld
bdio-entry-07.jsonld   bdio-entry-122.jsonld  bdio-entry-147.jsonld  bdio-entry-171.jsonld  bdio-entry-196.jsonld  bdio-entry-220.jsonld  bdio-entry-32.jsonld  bdio-entry-59.jsonld  bdio-entry-86.jsonld
bdio-entry-08.jsonld   bdio-entry-123.jsonld  bdio-entry-148.jsonld  bdio-entry-172.jsonld  bdio-entry-197.jsonld  bdio-entry-221.jsonld  bdio-entry-33.jsonld  bdio-entry-60.jsonld  bdio-entry-87.jsonld
bdio-entry-09.jsonld   bdio-entry-124.jsonld  bdio-entry-149.jsonld  bdio-entry-173.jsonld  bdio-entry-198.jsonld  bdio-entry-222.jsonld  bdio-entry-34.jsonld  bdio-entry-61.jsonld  bdio-entry-88.jsonld
bdio-entry-100.jsonld  bdio-entry-125.jsonld  bdio-entry-14.jsonld   bdio-entry-174.jsonld  bdio-entry-199.jsonld  bdio-entry-223.jsonld  bdio-entry-35.jsonld  bdio-entry-62.jsonld  bdio-entry-89.jsonld
bdio-entry-101.jsonld  bdio-entry-126.jsonld  bdio-entry-150.jsonld  bdio-entry-175.jsonld  bdio-entry-19.jsonld   bdio-entry-224.jsonld  bdio-entry-36.jsonld  bdio-entry-63.jsonld  bdio-entry-90.jsonld
bdio-entry-102.jsonld  bdio-entry-127.jsonld  bdio-entry-151.jsonld  bdio-entry-176.jsonld  bdio-entry-200.jsonld  bdio-entry-225.jsonld  bdio-entry-37.jsonld  bdio-entry-64.jsonld  bdio-entry-91.jsonld
bdio-entry-103.jsonld  bdio-entry-128.jsonld  bdio-entry-152.jsonld  bdio-entry-177.jsonld  bdio-entry-201.jsonld  bdio-entry-226.jsonld  bdio-entry-38.jsonld  bdio-entry-65.jsonld  bdio-entry-92.jsonld
bdio-entry-104.jsonld  bdio-entry-129.jsonld  bdio-entry-153.jsonld  bdio-entry-178.jsonld  bdio-entry-202.jsonld  bdio-entry-227.jsonld  bdio-entry-39.jsonld  bdio-entry-66.jsonld  bdio-entry-93.jsonld
bdio-entry-105.jsonld  bdio-entry-12.jsonld   bdio-entry-154.jsonld  bdio-entry-179.jsonld  bdio-entry-203.jsonld  bdio-entry-228.jsonld  bdio-entry-40.jsonld  bdio-entry-67.jsonld  bdio-entry-94.jsonld
bdio-entry-106.jsonld  bdio-entry-130.jsonld  bdio-entry-155.jsonld  bdio-entry-17.jsonld   bdio-entry-204.jsonld  bdio-entry-229.jsonld  bdio-entry-41.jsonld  bdio-entry-68.jsonld  bdio-entry-95.jsonld
bdio-entry-107.jsonld  bdio-entry-131.jsonld  bdio-entry-156.jsonld  bdio-entry-180.jsonld  bdio-entry-205.jsonld  bdio-entry-22.jsonld   bdio-entry-42.jsonld  bdio-entry-69.jsonld  bdio-entry-96.jsonld
bdio-entry-108.jsonld  bdio-entry-132.jsonld  bdio-entry-157.jsonld  bdio-entry-181.jsonld  bdio-entry-206.jsonld  bdio-entry-230.jsonld  bdio-entry-43.jsonld  bdio-entry-70.jsonld  bdio-entry-97.jsonld
bdio-entry-109.jsonld  bdio-entry-133.jsonld  bdio-entry-158.jsonld  bdio-entry-182.jsonld  bdio-entry-207.jsonld  bdio-entry-231.jsonld  bdio-entry-44.jsonld  bdio-entry-71.jsonld  bdio-entry-98.jsonld
bdio-entry-10.jsonld   bdio-entry-134.jsonld  bdio-entry-159.jsonld  bdio-entry-183.jsonld  bdio-entry-208.jsonld  bdio-entry-232.jsonld  bdio-entry-45.jsonld  bdio-entry-72.jsonld  bdio-entry-99.jsonld
bdio-entry-110.jsonld  bdio-entry-135.jsonld  bdio-entry-15.jsonld   bdio-entry-184.jsonld  bdio-entry-209.jsonld  bdio-entry-233.jsonld  bdio-entry-46.jsonld  bdio-entry-73.jsonld  bdio-header.jsonld
bdio-entry-111.jsonld  bdio-entry-136.jsonld  bdio-entry-160.jsonld  bdio-entry-185.jsonld  bdio-entry-20.jsonld   bdio-entry-234.jsonld  bdio-entry-47.jsonld  bdio-entry-74.jsonld
bdio-entry-112.jsonld  bdio-entry-137.jsonld  bdio-entry-161.jsonld  bdio-entry-186.jsonld  bdio-entry-210.jsonld  bdio-entry-235.jsonld  bdio-entry-48.jsonld  bdio-entry-75.jsonld
bdio-entry-113.jsonld  bdio-entry-138.jsonld  bdio-entry-162.jsonld  bdio-entry-187.jsonld  bdio-entry-211.jsonld  bdio-entry-236.jsonld  bdio-entry-49.jsonld  bdio-entry-76.jsonld
bdio-entry-114.jsonld  bdio-entry-139.jsonld  bdio-entry-163.jsonld  bdio-entry-188.jsonld  bdio-entry-212.jsonld  bdio-entry-23.jsonld   bdio-entry-50.jsonld  bdio-entry-77.jsonld
bdio-entry-115.jsonld  bdio-entry-13.jsonld   bdio-entry-164.jsonld  bdio-entry-189.jsonld  bdio-entry-213.jsonld  bdio-entry-24.jsonld   bdio-entry-51.jsonld  bdio-entry-78.jsonld
