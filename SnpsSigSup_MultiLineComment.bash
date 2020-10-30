#!/usr/bin/bash
#SCRIPT: SnpsSigSup_MultiLineComment.bash
#DATE: Fri Oct 16 20:50:59 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010162051Z
#CREDIT:  https://stackoverflow.com/questions/43158140/way-to-create-multiline-comments-in-bash
#GREPVCKSUM: TODO 

#PURPOSE: Multiline bash comment tricks, options

#NOTES: 

#USAGE: #1. bash SnpsSigSup_MultiLineComment.bash
#USAGE: #2.
#USAGE: #3. 


#MAIN

# PUT a # in front of top ' to ACTIVATE the code block, like so:
#: '
#remove it to make it a multiline comment.  

#PUT # before next : to ACTIVATE code block between the '

: '
echo 'testing single quote in paste block '
date --utc
# '




#REFERENCE

<< ////
Another good option. 
Example:
[pjalajas@sup-pjalajas-hub db]$ bash SnpsSigSup_BdGetDbDPlusStStar.bash | head
    Index "st.api_token_by_user_id"
 Column  | Type | Definition | Storage 
---------+------+------------+---------
 user_id | uuid | user_id    | plain
btree, for table "st.usermgmt_api_token"

       Index "st.api_token_name_u"
 Column  | Type | Definition  | Storage  
---------+------+-------------+----------
 user_id | uuid | user_id     | plain




psql -h 127.0.0.1 -p 55436 -U blackduck -d bds_hub -c "set search_path=st" -c "\d+ st.*" 
////
