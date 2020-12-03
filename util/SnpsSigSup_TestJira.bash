#!/usr/bin/bash
#SCRIPT: util/SnpsSigSup_TestJira.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-11-24
#LICENSE: SPDX Apache-2.0
#SUPPORT:  TODO
#VERSION: 2012022153Z
#CHANGELOG: 2012022153Z pj add case "5" POST create jira issue


#USAGE: bash util/SnpsSigSup_TestJira.bash 0 | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -C '.' | head
#USAGE: bash util/SnpsSigSup_TestJira.bash 0a | grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select((.value.havePermission==true) and (.key | contains("_ISSUE")))'
#USAGE: bash util/SnpsSigSup_TestJira.bash 0 |& grep "^{" |& jq -C '.' |& less -inRF
#USAGE: bash SnpsSigSup_TestJira.bash 1 |& less -inRF                                               

#USAGE 1 = return first page of project tickets
#USAGE 2 = add a comment to a Jira ticket


#TODO: pick an api version 2 or 3 and make all the same.
#TODO: remove progress output (by faking output to terminal; thought I did that...)
#TODO: document usages/options

#CONFIG

#snps-sig-sup-pjalajas.atlassian.net
USERSTRING="$(grep pjalajas@blackduckcloud.com ~/.pj)" # username:token ; WORKS, with api token, (google auth 2FA enabled)
JIRASERVERURL='https://snps-sig-sup-pjalajas.atlassian.net' # like https://snps-sig-sup-pjalajas.atlassian.net, no trailing slash
JIRASERVERURL='http://127.0.0.1:40002' # like https://snps-sig-sup-pjalajas.atlassian.net, no trailing slash
PROJECT_KEY="AT" #human readable jira ticket project, not numeric issue id (though I think that works too)
ISSUE_KEY="AT-1" #human readable jira ticket id, not numeric issue id (though I think that works too)
CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file


#INIT
JQ_STRING="" # TODO: fixme; ignore for now
CURL_DATA=' '  # don't edit, populated below if needed.




#MAIN

#Read command line option, prep curl command
case "$1" in
"0")
  #Get full list of all available user perms
  CURLX="GET"
  CURLURL="$JIRASERVERURL/rest/api/3/permissions" 
  ;;
"0a")
  #Get list of user perms for a jira issue/ticket... 
  #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0 | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | .key' | tr '\n' ','
      # ADD_COMMENTS,ADMINISTER,ADMINISTER_PROJECTS,ASSIGNABLE_USER,ASSIGN_ISSUES,BROWSE_PROJECTS,BULK_CHANGE,CLOSE_ISSUES,CREATE_ATTACHMENTS,CREATE_ISSUES,CREATE_PROJECT,CREATE_SHARED_OBJECTS,DELETE_ALL_ATTACHMENTS,DELETE_ALL_COMMENTS,DELETE_ALL_WORKLOGS,DELETE_ISSUES,DELETE_OWN_ATTACHMENTS,DELETE_OWN_COMMENTS,DELETE_OWN_WORKLOGS,EDIT_ALL_COMMENTS,EDIT_ALL_WORKLOGS,EDIT_ISSUES,EDIT_OWN_COMMENTS,EDIT_OWN_WORKLOGS,LINK_ISSUES,MANAGE_GROUP_FILTER_SUBSCRIPTIONS,MANAGE_SPRINTS_PERMISSION,MANAGE_WATCHERS,MODIFY_REPORTER,MOVE_ISSUES,RESOLVE_ISSUES,SCHEDULE_ISSUES,SET_ISSUE_SECURITY,SYSTEM_ADMIN,TRANSITION_ISSUES,USER_PICKER,VIEW_DEV_TOOLS,VIEW_READONLY_WORKFLOW,VIEW_VOTERS_AND_WATCHERS,WORK_ON_ISSUES,
  CURLX="GET"
  CURLURL="$JIRASERVERURL/rest/api/3/mypermissions?issueKey=${ISSUE_KEY}&permissions=ADD_COMMENTS,ADMINISTER,ADMINISTER_PROJECTS,ASSIGNABLE_USER,ASSIGN_ISSUES,BROWSE_PROJECTS,BULK_CHANGE,CLOSE_ISSUES,CREATE_ATTACHMENTS,CREATE_ISSUES,CREATE_PROJECT,CREATE_SHARED_OBJECTS,DELETE_ALL_ATTACHMENTS,DELETE_ALL_COMMENTS,DELETE_ALL_WORKLOGS,DELETE_ISSUES,DELETE_OWN_ATTACHMENTS,DELETE_OWN_COMMENTS,DELETE_OWN_WORKLOGS,EDIT_ALL_COMMENTS,EDIT_ALL_WORKLOGS,EDIT_ISSUES,EDIT_OWN_COMMENTS,EDIT_OWN_WORKLOGS,LINK_ISSUES,MANAGE_GROUP_FILTER_SUBSCRIPTIONS,MANAGE_SPRINTS_PERMISSION,MANAGE_WATCHERS,MODIFY_REPORTER,MOVE_ISSUES,RESOLVE_ISSUES,SCHEDULE_ISSUES,SET_ISSUE_SECURITY,SYSTEM_ADMIN,TRANSITION_ISSUES,USER_PICKER,VIEW_DEV_TOOLS,VIEW_READONLY_WORKFLOW,VIEW_VOTERS_AND_WATCHERS,WORK_ON_ISSUES"
  echo ; echo Parse output by piping output through something like " | grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) ' "
  ;;
"1")
  #See jira project
  CURLX="GET"
  CURLURL="$JIRASERVERURL/rest/api/2/search?jql=project=AT"
 ;;
"1a")
  #See jira issue/ticket
  CURLX="GET"
  CURLURL="$JIRASERVERURL/rest/api/2/issue/AT-1"
 ;;
"2")
  #Add comment 
  CURLX="POST"
  CURL_DATA='{ "body": "This is a pj comment" }'
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/comment"
  ;;
"2a")
  #Add comment, set visibility
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="POST"
  CURL_DATA='{ "body": "This is a pj comment that only administrators can see.", "visibility": { "type": "role", "value": "Administrators" } }'
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/comment"
  ;;
"3")
  #Show available transition info
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/transitions"
 ;;
"3a")
  #Set transition to Id 11 "To Do", or 31 "In Review".  Get numbers from test 3 above. 
  #https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-transitions-post
  #Permissions required: Browse projects and Transition issues project permission for the project that the issue is in.  If issue-level security is configured, issue-level security permission to view the issue.      App scope required: WRITE     OAuth scopes required: write:jira-work
  #Success returns HTTP/1.1 204 No Content.  Bad number returns: HTTP/1.1 400 Bad Request
  #   {"errorMessages":["Transition id '99' is not valid for this issue."],"errors":{}}

  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="POST"
  #CURL_DATA=' { "update": {}, "transition": { "id": "11" }} '  # To DO
  #CURL_DATA=' { "update": {}, "transition": { "id": "99" }} '  # ERROR 400 Bad Request
  CURL_DATA=' { "update": {}, "transition": { "id": "31" }} '  # In Review
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/transitions"
 ;;
"4")
  #Test perms at https://jirahost.customer.com/jira-test/rest/api/2/issue/HLRSDTEST-12/properties/com-synopsys-integration-alert
  # 2020-11-25 04:06:43.671 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : InternalEntityEclosingRequest : PUT https://jirahost.customer.com/jira-test/rest/api/2/issue/HLRSDTEST-12/properties/com-synopsys-integration-alert HTTP/1.1
  #2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : HttpResponseProxy : HttpResponseProxy{HTTP/1.1 403 Forbidden [Server: squid/4.1, Mime-Version: 1.0, Date: Wed, 25 Nov 2020 04:06:43 GMT, Content-Type: text/html;charset=utf-8, Content-Length: 4135, X-Squid-Error: ERR_ACCESS_DENIED 0, X-Cache: MISS from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com, X-Cache-Lookup: NONE from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com:3128, Via: 1.1 dc-pxy-loc-sqd-inf-a1.env.eng.customer.com (squid/4.1), Connection: close] ResponseEntityProxy{[Content-Type: text/html;charset=utf-8,Content-Length: 4135,Chunked: false]}}
  CURLX="PUT"
  CURL_DATA=' { "topicName": "pj topicName" } '  # TOOD: just guessing  
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/properties/com-synopsys-integration-alert"
 ;;
"4a")
  CURLX="GET"
  CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/properties/com-synopsys-integration-alert"
 ;;
"5")
  #Create a new JIRA issue
  #CURLX="POST"  # official, but fails on current testing...trying PUT...
  CURLX="PUT" # HTTP/1.1 405 Method Not Allowed, 0000: allow: POST,OPTIONS
  CURLX="OPTIONS"  # HTTP/1.1 204 No Content
  CURLX="POST"  # official, should work. Replace Bug with Task if needed. 
  CURL_DATA='{ "fields": { "project": { "key": "'${PROJECT_KEY}'" }, "summary": "PJ Ticket Summary here....", "description": "PJ Creating of an issue using project keys and issue type names using the REST API", "issuetype": { "name": "Bug" } } }'
  CURLURL="$JIRASERVERURL/rest/api/2/issue"
  ;;
esac 




#MAIN 

#TODO:  failed:  AFTER_STRING=" \| grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | .[]' "
curl \
   --silent --show-error \
   --trace-ascii ${CURL_TRACEASCII_OUT} \
   -D- \
   -u "${USERSTRING}" \
   -X "${CURLX}" \
   --data "${CURL_DATA}" \
   -H "Content-Type: application/json" \
   ${CURLURL} \
     

     #TODO: failed...
     #$AFTER_STRING 
     #| grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | [.key],[.key.havePermission]'  
     #works:  | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | .[]'  
     #| grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | [.key,.havePermission] | .[]'  


exit 




#REFERENCE

#curl       -D, --dump-header <file>
: '
To take Jira out of the testing, to focus on whether proxy is causing issue, use socat to just return 200; if proxy returns access denied, then you know its the proxy, not the jira.
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 4 |& less -inRF
== Info: About to connect() to 127.0.0.1 port 40002 (#0)
== Info:   Trying 127.0.0.1...
== Info: Connected to 127.0.0.1 (127.0.0.1) port 40002 (#0)
== Info: Server auth using Basic with user 'pjalajas@blackduckcloud.com'
=> Send header, 289 bytes (0x121)
0000: PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-a
0040: lert HTTP/1.1
004f: Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWN
008f: wZkQyQnVSNzNIVjV3VVkyNjg1OQ==
00ae: User-Agent: curl/7.29.0
00c7: Host: 127.0.0.1:40002
00de: Accept: */*
00eb: Content-Type: application/json
010b: Content-Length: 33
011f: 
=> Send data, 33 bytes (0x21)
0000:  { "topicName": "pj topicName" } 
== Info: upload completely sent off: 33 out of 33 bytes
<= Recv header, 17 bytes (0x11)
0000: HTTP/1.1 200 OK
HTTP/1.1 200 OK
== Info: no chunk, no close, no size. Assume close to signal end

<= Recv header, 2 bytes (0x2)
0000: 
<= Recv data, 0 bytes (0x0)
== Info: Closing connection 0



'







: '
Send to customer to test Jira plugin perms:

#To test POST creating new jira issue
#Change issueType "Bug" if needed for customer env.  Task? https://support.atlassian.com/jira-cloud-administration/docs/what-are-issue-types/ Not sure if case sensitive. 
USERSTRING="$(grep pjalajas@blackduckcloud.com ~/.pj)" # username:token ; WORKS, with api token, (google auth 2FA enabled)
JIRASERVERURL='https://snps-sig-sup-pjalajas.atlassian.net' # like https://snps-sig-sup-pjalajas.atlassian.net
PROJECT_KEY="AT" #human readable jira ticket project, not numeric issue id (though I think that works too)
CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
CURLX="POST"
CURL_DATA='{ "fields": { "project": { "key": "'${PROJECT_KEY}'" }, "summary": "PJ Ticket Summary here....", "description": "PJ Creating of an issue using project keys and issue type names using the REST API", "issuetype": { "name": "Bug" } } }'
CURLURL="$JIRASERVERURL/rest/api/2/issue"
curl --silent --show-error --trace-ascii ${CURL_TRACEASCII_OUT} -D- -u "${USERSTRING}" -X ${CURLX} --data "${CURL_DATA}" -H "Content-Type: application/json" ${CURLURL} |& less -inRF


#To test PUT updating issue
USERSTRING="$(grep pjalajas@blackduckcloud.com ~/.pj)" # username:token ; WORKS, with api token, (google auth 2FA enabled)
JIRASERVERURL='https://snps-sig-sup-pjalajas.atlassian.net' # like https://snps-sig-sup-pjalajas.atlassian.net
ISSUE_KEY="AT-1" #human readable jira ticket id, not numeric issue id (though I think that works too)
CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
CURLX="PUT"
CURL_DATA=' { "topicName": "pj topicName" } ' 
CURLURL="$JIRASERVERURL/rest/api/2/issue/${ISSUE_KEY}/properties/com-synopsys-integration-alert"
curl --silent --show-error --trace-ascii ${CURL_TRACEASCII_OUT} -D- -u "${USERSTRING}" -X ${CURLX} --data "${CURL_DATA}" -H "Content-Type: application/json" ${CURLURL} | less -inRF

'


: '
Can send this bundle to customer without this script:
USERSTRING="$(grep pjalajas@blackduckcloud.com ~/.pj)" # username:token ; WORKS, with api token, (google auth 2FA enabled)
JIRASERVERURL='https://snps-sig-sup-pjalajas.atlassian.net' # like https://snps-sig-sup-pjalajas.atlassian.net
ISSUE_KEY="AT-1" #human readable jira ticket id, not numeric issue id (though I think that works too)
CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
CURL_DATA=' '  # don't edit, populated below if needed.
CURLURL="$JIRASERVERURL/rest/api/3/mypermissions?issueKey=${ISSUE_KEY}&permissions=ADD_COMMENTS,ADMINISTER,ADMINISTER_PROJECTS,ASSIGNABLE_USER,ASSIGN_ISSUES,BROWSE_PROJECTS,BULK_CHANGE,CLOSE_ISSUES,CREATE_ATTACHMENTS,CREATE_ISSUES,CREATE_PROJECT,CREATE_SHARED_OBJECTS,DELETE_ALL_ATTACHMENTS,DELETE_ALL_COMMENTS,DELETE_ALL_WORKLOGS,DELETE_ISSUES,DELETE_OWN_ATTACHMENTS,DELETE_OWN_COMMENTS,DELETE_OWN_WORKLOGS,EDIT_ALL_COMMENTS,EDIT_ALL_WORKLOGS,EDIT_ISSUES,EDIT_OWN_COMMENTS,EDIT_OWN_WORKLOGS,LINK_ISSUES,MANAGE_GROUP_FILTER_SUBSCRIPTIONS,MANAGE_SPRINTS_PERMISSION,MANAGE_WATCHERS,MODIFY_REPORTER,MOVE_ISSUES,RESOLVE_ISSUES,SCHEDULE_ISSUES,SET_ISSUE_SECURITY,SYSTEM_ADMIN,TRANSITION_ISSUES,USER_PICKER,VIEW_DEV_TOOLS,VIEW_READONLY_WORKFLOW,VIEW_VOTERS_AND_WATCHERS,WORK_ON_ISSUES"
curl --silent --show-error --trace-ascii ${CURL_TRACEASCII_OUT} -D- -u "${USERSTRING}" -X GET -H "Content-Type: application/json" ${CURLURL} | grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select((.value.havePermission==true) and (.key | contains("_ISSUE")))'

'




: '
2020-11-25 04:06:43.671 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : starting request: https://jirahost.customer.com/jira-test/rest/api/2/issue/HLRSDTEST-12/properties/com-synopsys-integration-alert
2020-11-25 04:06:43.671 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : InternalEntityEclosingRequest : PUT https://jirahost.customer.com/jira-test/rest/api/2/issue/HLRSDTEST-12/properties/com-synopsys-integration-alert HTTP/1.1
2020-11-25 04:06:43.671 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : InternalEntityEclosingRequest headers : 
2020-11-25 04:06:43.671 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Authorization : Basic YW5vb3NoYV9pbnRlcm5hbDphbm9vc2hhX2ludGVybmFs
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : HttpResponseProxy : HttpResponseProxy{HTTP/1.1 403 Forbidden [Server: squid/4.1, Mime-Version: 1.0, Date: Wed, 25 Nov 2020 04:06:43 GMT, Content-Type: text/html;charset=utf-8, Content-Length: 4135, X-Squid-Error: ERR_ACCESS_DENIED 0, X-Cache: MISS from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com, X-Cache-Lookup: NONE from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com:3128, Via: 1.1 dc-pxy-loc-sqd-inf-a1.env.eng.customer.com (squid/4.1), Connection: close] ResponseEntityProxy{[Content-Type: text/html;charset=utf-8,Content-Length: 4135,Chunked: false]}}
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : HttpResponseProxy headers : 
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Server : squid/4.1
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Mime-Version : 1.0
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Date : Wed, 25 Nov 2020 04:06:43 GMT
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Content-Type : text/html;charset=utf-8
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Content-Length : 4135
2020-11-25 04:06:43.793 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header X-Squid-Error : ERR_ACCESS_DENIED 0
2020-11-25 04:06:43.794 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header X-Cache : MISS from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com
2020-11-25 04:06:43.794 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header X-Cache-Lookup : NONE from dc-pxy-loc-sqd-inf-a1.env.eng.customer.com:3128
2020-11-25 04:06:43.794 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Via : 1.1 dc-pxy-loc-sqd-inf-a1.env.eng.customer.com (squid/4.1)
2020-11-25 04:06:43.794 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : Header Connection : close
2020-11-25 04:06:43.794 TRACE 1 --- [nio-8443-exec-6] c.s.i.a.c.j.s.JiraServerRequestDelegator : completed request: https://jirahost.customer.com/jira-test/rest/api/2/issue/HLRSDTEST-12/properties/com-synopsys-integration-alert (123 ms)


'




: '
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0a | grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select((.value.havePermission==true) and (.key | contains("_ISSUE")))'
{"key":"CREATE_ISSUES","value":{"id":"11","key":"CREATE_ISSUES","name":"Create Issues","type":"PROJECT","description":"Ability to create issues.","havePermission":true}}                                                                                                                                   
{"key":"WORK_ON_ISSUES","value":{"id":"20","key":"WORK_ON_ISSUES","name":"Work On Issues","type":"PROJECT","description":"Ability to log work done against an issue. Only useful if Time Tracking is turned on.","havePermission":true}}                                                                    
{"key":"EDIT_ISSUES","value":{"id":"12","key":"EDIT_ISSUES","name":"Edit Issues","type":"PROJECT","description":"Ability to edit issues.","havePermission":true}}                                                                                                                                           
{"key":"ASSIGN_ISSUES","value":{"id":"13","key":"ASSIGN_ISSUES","name":"Assign Issues","type":"PROJECT","description":"Ability to assign issues to other people.","havePermission":true}}                                                                                                                   
{"key":"CLOSE_ISSUES","value":{"id":"18","key":"CLOSE_ISSUES","name":"Close Issues","type":"PROJECT","description":"Ability to close issues. Often useful where your developers resolve issues, and a QA department closes them.","havePermission":true}}                                                   
{"key":"SCHEDULE_ISSUES","value":{"id":"28","key":"SCHEDULE_ISSUES","name":"Schedule Issues","type":"PROJECT","description":"Ability to view or edit an issue's due date.","havePermission":true}}                                                                                                          
{"key":"RESOLVE_ISSUES","value":{"id":"14","key":"RESOLVE_ISSUES","name":"Resolve Issues","type":"PROJECT","description":"Ability to resolve and reopen issues. This includes the ability to set a fix version.","havePermission":true}}                                                                    
{"key":"DELETE_ISSUES","value":{"id":"16","key":"DELETE_ISSUES","name":"Delete Issues","type":"PROJECT","description":"Ability to delete issues.","havePermission":true}}                                                                                                                                   
{"key":"MOVE_ISSUES","value":{"id":"25","key":"MOVE_ISSUES","name":"Move Issues","type":"PROJECT","description":"Ability to move issues between projects or between workflows of the same project (if applicable). Note the user can only move issues to a project they have the create permission for.","havePermission":true}}                                                                                                                                  
{"key":"TRANSITION_ISSUES","value":{"id":"46","key":"TRANSITION_ISSUES","name":"Transition Issues","type":"PROJECT","description":"Ability to transition issues.","havePermission":true}}                                                                                                                   
{"key":"LINK_ISSUES","value":{"id":"21","key":"LINK_ISSUES","name":"Link Issues","type":"PROJECT","description":"Ability to link issues together and create linked issues. Only useful if issue linking is turned on.","havePermission":true}}      

'






: '
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0a | grep '^{' | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) '                                                                                                                                                                                                                                   
{"key":"DELETE_OWN_WORKLOGS","value":{"id":"42","key":"DELETE_OWN_WORKLOGS","name":"Delete Own Worklogs","type":"PROJECT","description":"Ability to delete own worklogs made on issues.","havePermission":true}}
{"key":"VIEW_DEV_TOOLS","value":{"id":"29","key":"VIEW_DEV_TOOLS","name":"View Development Tools","type":"PROJECT","description":"Allows users in a software project to view development-related information on the issue, such as commits, reviews and build information.","havePermission":true}}
{"key":"CREATE_ISSUES","value":{"id":"11","key":"CREATE_ISSUES","name":"Create Issues","type":"PROJECT","description":"Ability to create issues.","havePermission":true}}
{"key":"BULK_CHANGE","value":{"id":"33","key":"BULK_CHANGE","name":"Make bulk changes","type":"GLOBAL","description":"Modify collections of issues at once. For example, resolve multiple issues in one step.","havePermission":true}}
{"key":"WORK_ON_ISSUES","value":{"id":"20","key":"WORK_ON_ISSUES","name":"Work On Issues","type":"PROJECT","description":"Ability to log work done against an issue. Only useful if Time Tracking is turned on.","havePermission":true}}
{"key":"DELETE_OWN_COMMENTS","value":{"id":"37","key":"DELETE_OWN_COMMENTS","name":"Delete Own Comments","type":"PROJECT","description":"Ability to delete own comments made on issues.","havePermission":true}}
{"key":"MODIFY_REPORTER","value":{"id":"30","key":"MODIFY_REPORTER","name":"Modify Reporter","type":"PROJECT","description":"Ability to modify the reporter when creating or editing an issue.","havePermission":true}}
{"key":"MANAGE_WATCHERS","value":{"id":"32","key":"MANAGE_WATCHERS","name":"Manage Watchers","type":"PROJECT","description":"Ability to manage the watchers of an issue.","havePermission":true}}
{"key":"EDIT_ISSUES","value":{"id":"12","key":"EDIT_ISSUES","name":"Edit Issues","type":"PROJECT","description":"Ability to edit issues.","havePermission":true}}
{"key":"VIEW_VOTERS_AND_WATCHERS","value":{"id":"31","key":"VIEW_VOTERS_AND_WATCHERS","name":"View Voters and Watchers","type":"PROJECT","description":"Ability to view the voters and watchers of an issue.","havePermission":true}}
{"key":"ADD_COMMENTS","value":{"id":"15","key":"ADD_COMMENTS","name":"Add Comments","type":"PROJECT","description":"Ability to comment on issues.","havePermission":true}}
{"key":"EDIT_OWN_COMMENTS","value":{"id":"35","key":"EDIT_OWN_COMMENTS","name":"Edit Own Comments","type":"PROJECT","description":"Ability to edit own comments made on issues.","havePermission":true}}
{"key":"ASSIGN_ISSUES","value":{"id":"13","key":"ASSIGN_ISSUES","name":"Assign Issues","type":"PROJECT","description":"Ability to assign issues to other people.","havePermission":true}}
{"key":"BROWSE_PROJECTS","value":{"id":"10","key":"BROWSE_PROJECTS","name":"Browse Projects","type":"PROJECT","description":"Ability to browse projects and the issues within them.","havePermission":true}}
{"key":"DELETE_OWN_ATTACHMENTS","value":{"id":"39","key":"DELETE_OWN_ATTACHMENTS","name":"Delete Own Attachments","type":"PROJECT","description":"Users with this permission may delete own attachments.","havePermission":true}}
{"key":"DELETE_ALL_ATTACHMENTS","value":{"id":"38","key":"DELETE_ALL_ATTACHMENTS","name":"Delete All Attachments","type":"PROJECT","description":"Users with this permission may delete all attachments.","havePermission":true}}
{"key":"CREATE_PROJECT","value":{"id":"-1","key":"CREATE_PROJECT","name":"Create next-gen projects","type":"GLOBAL","description":"Create projects separate from shared configurations and schemes. Next-gen projects don't affect existing projects or shared configurations like workflows, fields or permissions. Only licensed users can create next-gen projects.","havePermission":true}}
{"key":"EDIT_OWN_WORKLOGS","value":{"id":"40","key":"EDIT_OWN_WORKLOGS","name":"Edit Own Worklogs","type":"PROJECT","description":"Ability to edit own worklogs made on issues.","havePermission":true}}
{"key":"EDIT_ALL_WORKLOGS","value":{"id":"41","key":"EDIT_ALL_WORKLOGS","name":"Edit All Worklogs","type":"PROJECT","description":"Ability to edit all worklogs made on issues.","havePermission":true}}
{"key":"CREATE_ATTACHMENTS","value":{"id":"19","key":"CREATE_ATTACHMENTS","name":"Create Attachments","type":"PROJECT","description":"Users with this permission may create attachments.","havePermission":true}}
{"key":"EDIT_ALL_COMMENTS","value":{"id":"34","key":"EDIT_ALL_COMMENTS","name":"Edit All Comments","type":"PROJECT","description":"Ability to edit all comments made on issues.","havePermission":true}}
{"key":"MANAGE_SPRINTS_PERMISSION","value":{"id":"-1","key":"MANAGE_SPRINTS_PERMISSION","name":"Manage sprints","type":"PROJECT","description":"Ability to manage sprints.","havePermission":true}}
{"key":"CLOSE_ISSUES","value":{"id":"18","key":"CLOSE_ISSUES","name":"Close Issues","type":"PROJECT","description":"Ability to close issues. Often useful where your developers resolve issues, and a QA department closes them.","havePermission":true}}
{"key":"SCHEDULE_ISSUES","value":{"id":"28","key":"SCHEDULE_ISSUES","name":"Schedule Issues","type":"PROJECT","description":"Ability to view or edit an issue's due date.","havePermission":true}}
{"key":"CREATE_SHARED_OBJECTS","value":{"id":"22","key":"CREATE_SHARED_OBJECTS","name":"Share dashboards and filters","type":"GLOBAL","description":"Share dashboards and filters with other users.","havePermission":true}}
{"key":"USER_PICKER","value":{"id":"27","key":"USER_PICKER","name":"Browse users and groups","type":"GLOBAL","description":"View and select users or groups from the user picker, and share issues. Users with this permission can see the names of all users and groups on your site.","havePermission":true}}
{"key":"DELETE_ALL_COMMENTS","value":{"id":"36","key":"DELETE_ALL_COMMENTS","name":"Delete All Comments","type":"PROJECT","description":"Ability to delete all comments made on issues.","havePermission":true}}
{"key":"ADMINISTER_PROJECTS","value":{"id":"23","key":"ADMINISTER_PROJECTS","name":"Administer Projects","type":"PROJECT","description":"Ability to administer a project in Jira.","havePermission":true}}
{"key":"RESOLVE_ISSUES","value":{"id":"14","key":"RESOLVE_ISSUES","name":"Resolve Issues","type":"PROJECT","description":"Ability to resolve and reopen issues. This includes the ability to set a fix version.","havePermission":true}}
{"key":"DELETE_ISSUES","value":{"id":"16","key":"DELETE_ISSUES","name":"Delete Issues","type":"PROJECT","description":"Ability to delete issues.","havePermission":true}}
{"key":"MANAGE_GROUP_FILTER_SUBSCRIPTIONS","value":{"id":"24","key":"MANAGE_GROUP_FILTER_SUBSCRIPTIONS","name":"Manage group filter subscriptions","type":"GLOBAL","description":"Create and delete group filter subscriptions.","havePermission":true}}
{"key":"VIEW_READONLY_WORKFLOW","value":{"id":"45","key":"VIEW_READONLY_WORKFLOW","name":"View Read-Only Workflow","type":"PROJECT","description":"Users with this permission may view a read-only version of a workflow.","havePermission":true}}
{"key":"ADMINISTER","value":{"id":"0","key":"ADMINISTER","name":"Administer Jira","type":"GLOBAL","description":"Create and administer projects, issue types, fields, workflows, and schemes for all projects. Users with this permission can perform most administration tasks, except: managing users, importing data, and editing system email settings.","havePermission":true}}
{"key":"MOVE_ISSUES","value":{"id":"25","key":"MOVE_ISSUES","name":"Move Issues","type":"PROJECT","description":"Ability to move issues between projects or between workflows of the same project (if applicable). Note the user can only move issues to a project they have the create permission for.","havePermission":true}}
{"key":"TRANSITION_ISSUES","value":{"id":"46","key":"TRANSITION_ISSUES","name":"Transition Issues","type":"PROJECT","description":"Ability to transition issues.","havePermission":true}}
{"key":"ASSIGNABLE_USER","value":{"id":"17","key":"ASSIGNABLE_USER","name":"Assignable User","type":"PROJECT","description":"Users with this permission may be assigned to issues.","havePermission":true}}
{"key":"LINK_ISSUES","value":{"id":"21","key":"LINK_ISSUES","name":"Link Issues","type":"PROJECT","description":"Ability to link issues together and create linked issues. Only useful if issue linking is turned on.","havePermission":true}}
{"key":"DELETE_ALL_WORKLOGS","value":{"id":"43","key":"DELETE_ALL_WORKLOGS","name":"Delete All Worklogs","type":"PROJECT","description":"Ability to delete all worklogs made on issues.","havePermission":true}}

'








: '
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0a | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | [.key] | .[]'  | head                                                                                                                                                                                                             
DELETE_OWN_WORKLOGS
VIEW_DEV_TOOLS
CREATE_ISSUES
BULK_CHANGE
WORK_ON_ISSUES
DELETE_OWN_COMMENTS
MODIFY_REPORTER
MANAGE_WATCHERS
EDIT_ISSUES
VIEW_VOTERS_AND_WATCHERS
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0a | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==true) | [.key] | .[]' | wc -l
38
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0a | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | select(.value.havePermission==false) | [.key] | .[]' | wc -l
2

'







: '
/rest/api/2/issue/JRA-5475/transitions?expand=transitions.fields&transitionId=241
{
 "update": {},
 "transition": {
 "id": "241"
 },
 "fields": {
 "resolution": {
 "name": "Done"
 }
 }
}
{ "update": {}, "transition": { "id": "31" }}

pj: 
   "id": "31",
      "name": "In Review",


'






: '
0000: { "body": "This is a pj comment that only administrators can see
0040: .", "visibility": { "type": "role", "value": "Administrators" } 
0080: }
0000: HTTP/1.1 400 Bad Request
HTTP/1.1 400 Bad Request
0004: {"errorMessages":[],"errors":{"commentLevel":"You are currently 
0044: not a member of the project role: Administrators."}}
{"errorMessages":[],"errors":{"commentLevel":"You are currently not a member of the project role: Administrators."}}<= Recv data, 5 bytes (0x5)
0000: 0
'











test add comment:  curl -D- -u fred:fred -X POST --data {see below} -H "Content-Type: application/json" http://kelpie9:8081/rest/api/2/issue/QA-31/comment
{
    "body": "This is a comment that only administrators can see.",
    "visibility": {
        "type": "role",
        "value": "Administrators"
    }
}

{ "body": "This is a comment that only administrators can see.", "visibility": { "type": "role", "value": "Administrators" } }

WORKS?:  one liner:  curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:" -X GET -H "Content-Type: application/json" "$JIRASERVERURL/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22' 
bad user returns 400 bad request
bad password returns 401 unauthorized
change json to gson, 415 Unsupported Media Type


works: [pjalajas@sup-pjalajas-hub SynopsysScripts]$ curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:" -X GET -H "Content-Type: application/json" "$JIRASERVERURL/rest/api/2/search?jql=project=%22AT%22' | less -inRF
works: [pjalajas@sup-pjalajas-hub SynopsysScripts]$ curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:" -X GET -H "Content-Type: application/json" "$JIRASERVERURL/rest/api/2/search?jql=project=AT' | less -inRF
"$JIRASERVERURL/rest/api/2/search?jql=project=AT'

: '

WORKS:  one liner:  curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:" -X GET -H "Content-Type: application/json" "$JIRASERVERURL/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22' 

bad?: USERSTRING="Peter Jalajas:"
   good:  $JIRASERVERURL/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22
   good:  $JIRASERVERURL/rest/api/2/search
   bad: "$JIRASERVERURL/rest/api/2/search?jql=project="alert_test"'
   
   {"expand":"names,schema","startAt":0,"maxResults":50,"total":1,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10000","self":"$JIRASERVERURL/rest/api/2/issue/10000","key":"AT-1","fields":{"statuscategorychangedate":"2020-11-24T15:55:41.393-0500","issuetype":{"self":"$JIRASERVERURL/rest/api/2/issuetype/10005","id":"10005","description":"A problem or error.","iconUrl":"$JIRASERVERURL/secure/viewavatar?size=medium&avatarId=10303&avatarType=issuetype","name":"Bug","subtask":false,"avatarId":10303},"timespent":null,"project":{"self":"$JIRASERVERURL/rest/api/2/project/10000","id":"10000","key":"AT","name":"alert_test","projectTypeKey":"software","simplified":false,"avatarUrls":{"48x48":"$JIRASERVERURL/secure/projectavatar?pid=10000&avatarId=10406","24x24":"$JIRASERVERURL/secure/projectavatar?size=small&s=small&pid=10000&avatarId=10406","16x16":"$JIRASERVERURL/secure/projectavatar?size=xsmall&s=xsmall&pid=10000&avatarId=10406","32x32":"$JIRASERVERURL/secure/projectavatar?size=medium&s=medium&pid=10000&avatarId=10406"}},"fixVersions":[],"aggregatetimespent":null,"resolution":null,"resolutiondate":null,"workratio":-1,"lastViewed":"2020-11-24T16:11:50.690-0500","watches":{"self":"$JIRASERVERURL/rest/api/2/issue/AT-1/watchers","watchCount":1,"isWatching":true},"created":"2020-11-24T15:55:41.076-0500","customfield_10020":null,"customfield_10021":null,"customfield_10022":null,"priority":{"self":"$JIRASERVERURL/rest/api/2/priority/3","iconUrl":"$JIRASERVERURL/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"customfield_10023":null,"customfield_10024":null,"customfield_10025":null,"labels":[],"customfield_10016":null,"customfield_10017":null,"customfield_10018":{"hasEpicLinkFieldDependency":false,"showField":false,"nonEditableReason":{"reason":"PLUGIN_LICENSE_ERROR","message":"The Parent Link is only available to Jira Premium users."}},"customfield_10019":"0|hzzzzz:","timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2020-11-24T15:55:41.076-0500","status":{"self":"$JIRASERVERURL/rest/api/2/status/10000","description":"","iconUrl":"$JIRASERVERURL/","name":"To Do","id":"10000","statusCategory":{"self":"$JIRASERVERURL/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}},"components":[],"timeoriginalestimate":null,"description":"test","customfield_10010":null,"customfield_10014":null,"customfield_10015":null,"customfield_10005":null,"customfield_10006":null,"customfield_10007":null,"security":null,"customfield_10008":null,"aggregatetimeestimate":null,"customfield_10009":null,"summary":"test","creator":{"self":"$JIRASERVERURL/rest/api/2/user?accountId=5fbc09d1d670b8006ea85bcd","accountId":"5fbc09d1d670b8006ea85bcd","emailAddress":"pjalajas@blackduckcloud.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","24x24":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","16x16":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","32x32":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png"},"displayName":"Peter Jalajas","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"subtasks":[],"reporter":{"self":"$JIRASERVERURL/rest/api/2/user?accountId=5fbc09d1d670b8006ea85bcd","accountId":"5fbc09d1d670b8006ea85bcd","emailAddress":"pjalajas@blackduckcloud.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","24x24":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","16x16":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","32x32":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png"},"displayName":"Peter Jalajas","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"progress":{"progress":0,"total":0},"votes":{"self":"$JIRASERVERURL/rest/api/2/issue/AT-1/vote
                                                                             
   "$JIRASERVERURL/rest/api/2/search?jql=project="AT"'
   "$JIRASERVERURL/rest/api/2/search?jql=project=AT'
 | less -inRF 
   #-u pjalajas:$(cat ~/.pj2) \
#one liner: curl --trace-ascii - -D- -u pjalajas:$(cat ~/.pj2) -X GET -H "Content-Type: application/json" 'https://jira-sig-test.internal.synopsys.com/rest/api/2/search?jql=project=HUB+order+by+duedate&fields=id,key' | less -inRF 

   'https://jira-sig-test.internal.synopsys.com/rest/api/2/search?jql=project=HUB+order+by+duedate&fields=id,key' \
   -u pjalajas:$(cat ~/.pj2)\
   -u pjalajas:badpassword \
   -o - \
   'https://jira-sig-test.internal.synopsys.com/rest/api/2/search?jql=project=HUB+order+by+duedate&fields=id,key' 2>&1 |& \
   cat 
   #'https://jira-sig-test.internal.synopsys.com/rest/api/2/search?jql=project=HUB+order+by+duedate&fields=id,key'
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash |& cat
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:02 --:--:--     0HTTP/1.1 200 
Date: Tue, 24 Nov 2020 19:35:18 GMT
Server: Apache/2.4.29 (Ubuntu)
X-AREQUESTID: 695x37268x1
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Content-Security-Policy: frame-ancestors 'self'
X-ASEN: SEN-2246295
X-Seraph-LoginReason: OK
X-ASESSIONID: ushp9y
X-AUSERNAME: pjalajas
Cache-Control: no-cache, no-store, no-transform
Content-Type: application/json;charset=UTF-8
Set-Cookie: JSESSIONID=8BFFE0E4EC506F0DE2EFE4EECA5FA375; Path=/; HttpOnly
Set-Cookie: atlassian.xsrf.token=BGY6-VHH5-ENZN-7HYQ_d362b2ffecd6de3a0c622284554bbecba13db523_lin; Path=/
Vary: User-Agent
Transfer-Encoding: chunked

{"expand":"schema,names","startAt":0,"maxResults":50,"total":24804,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146243","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146243","key":"HUB-23036"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146122","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146122","key":"HUB-23022"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146232","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146232","key":"HUB-23033"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146111","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146111","key":"HUB-23020"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146246","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146246","key":"HUB-23039"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146099","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146099","key":"HUB-23018"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146089","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146089","key":"HUB-23013"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145896","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145896","key":"HUB-23004"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145831","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145831","key":"HUB-23003"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145673","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145673","key":"HUB-22987"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145248","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145248","key":"HUB-22966"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145170","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145170","key":"HUB-22965"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145116","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145116","key":"HUB-22962"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145038","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145038","key":"HUB-22952"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144985","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144985","key":"HUB-22949"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144978","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144978","key":"HUB-22947"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144761","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144761","key":"HUB-22943"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144736","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144736","key":"HUB-22942"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144730","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144730","key":"HUB-22941"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144721","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144721","key":"HUB-22939"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144728","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144728","key":"HUB-22940"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144710","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144710","key":"HUB-22937"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144714","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144714","key":"HUB-22938"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144689","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144689","key":"HUB-22936"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144664","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144664","key":"HUB-22934"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144572","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144572","key":"HUB-22931"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144568","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144568","key":"HUB-22929"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144557","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144557","key":"HUB-22926"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144474","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144474","key":"HUB-22918"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144267","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144267","key":"HUB-22907"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144219","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144219","key":"HUB-22902"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144193","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144193","key":"HUB-22901"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144186","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144186","key":"HUB-22900"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144120","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144120","key":"HUB-22898"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144013","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144013","key":"HUB-22891"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144012","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144012","key":"HUB-22890"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144010","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144010","key":"HUB-22888"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143981","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143981","key":"HUB-22886"},{"expand":"operations,versionedRepresen100  9778    0  9778    0     0   3690      0 --:--:--  0:00:02 --:--:--  3689
redFields","id":"1143951","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143951","key":"HUB-22884"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143874","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143874","key":"HUB-22881"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143535","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143535","key":"HUB-22861"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143531","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143531","key":"HUB-22859"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143516","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143516","key":"HUB-22857"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143489","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143489","key":"HUB-22855"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143492","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143492","key":"HUB-22856"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143455","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143455","key":"HUB-22853"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143451","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143451","key":"HUB-22851"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143382","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143382","key":"HUB-22849"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143379","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143379","key":"HUB-22848"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143311","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143311","key":"HUB-22845"}]}[


'

: '

https://jira-sig-test.internal.synopsys.com/rest/api/2/search?jql=project=HUB+order+by+duedate&fields=id,key

{"expand":"schema,names","startAt":0,"maxResults":50,"total":24804,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146243","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146243","key":"HUB-23036"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146122","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146122","key":"HUB-23022"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146232","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146232","key":"HUB-23033"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146111","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146111","key":"HUB-23020"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146246","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146246","key":"HUB-23039"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146099","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146099","key":"HUB-23018"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1146089","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1146089","key":"HUB-23013"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145896","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145896","key":"HUB-23004"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145831","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145831","key":"HUB-23003"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145673","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145673","key":"HUB-22987"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145248","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145248","key":"HUB-22966"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145170","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145170","key":"HUB-22965"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145116","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145116","key":"HUB-22962"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1145038","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1145038","key":"HUB-22952"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144985","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144985","key":"HUB-22949"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144978","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144978","key":"HUB-22947"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144761","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144761","key":"HUB-22943"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144736","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144736","key":"HUB-22942"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144730","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144730","key":"HUB-22941"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144721","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144721","key":"HUB-22939"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144728","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144728","key":"HUB-22940"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144710","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144710","key":"HUB-22937"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144714","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144714","key":"HUB-22938"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144689","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144689","key":"HUB-22936"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144664","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144664","key":"HUB-22934"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144572","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144572","key":"HUB-22931"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144568","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144568","key":"HUB-22929"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144557","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144557","key":"HUB-22926"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144474","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144474","key":"HUB-22918"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144267","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144267","key":"HUB-22907"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144219","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144219","key":"HUB-22902"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144193","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144193","key":"HUB-22901"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144186","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144186","key":"HUB-22900"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144120","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144120","key":"HUB-22898"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144013","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144013","key":"HUB-22891"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144012","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144012","key":"HUB-22890"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1144010","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1144010","key":"HUB-22888"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143981","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143981","key":"HUB-22886"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143951","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143951","key":"HUB-22884"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143874","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143874","key":"HUB-22881"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143535","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143535","key":"HUB-22861"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143531","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143531","key":"HUB-22859"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143516","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143516","key":"HUB-22857"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143489","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143489","key":"HUB-22855"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143492","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143492","key":"HUB-22856"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143455","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143455","key":"HUB-22853"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143451","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143451","key":"HUB-22851"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143382","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143382","key":"HUB-22849"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143379","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143379","key":"HUB-22848"},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"1143311","self":"https://jira-sig-test.internal.synopsys.com/rest/api/2/issue/1143311","key":"HUB-22845"}]}

'


: '
#https://jira-sig-test.internal.synopsys.com/browse/HUB-26359?filter=22304
#HUB-26359

#http://localhost:8080/rest/api/2/issue/createmeta

#curl \
   #-D- \
   #-u charlie:charlie \
   #-X GET \
   #-H "Content-Type: application/json" \
   #'http://localhost:8080/rest/api/2/search?jql=project=QA+order+by+duedate&fields=id,key'
'

: '
curl \
   -D- \
   -u charlie:charlie \
   -X GET \
   -H "Content-Type: application/json" \
   http://localhost:8080/rest/api/2/search?jql=assignee=charlie
'

