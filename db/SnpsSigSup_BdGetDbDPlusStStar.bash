#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetDbDPlusStStar.bash 
#DATE: Fri Oct 16 20:32:16 UTC 2020
#AUTHOR: pjalajas@synopsys.com
#SUPPORT: https://community.synopsys.com/s/ Software-integrity-support@synopsys.com
#LICENSE: SPDX Apache-2.0 https://spdx.org/licenses/Apache-2.0.html
#VERSION: 2010162032Z
#GREPVCKSUM: TODO 

#PURPOSE: Get all Black Duck (Hub) bds_hub st schema table specs.

#NOTES: Best to pipe through |& grep, or |& less -inRF, or redirect to a file. 

#USAGE: #1. bash SnpsSigSup_BdGetDbDPlusStStar.bash |& head
#USAGE: #2. bash SnpsSigSup_BdGetDbDPlusStStar.bash |& less -inRF
#USAGE: #3. bash SnpsSigSup_BdGetDbDPlusStStar.bash |& grep scan_ 

#NOTES: 

#TODO: generalize pg conn settings, -d option.

#MAIN

psql -h 127.0.0.1 -p 55436 -U blackduck -d bds_hub -c "\d+ st.*" 

#REFERENCE
<< ////
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
