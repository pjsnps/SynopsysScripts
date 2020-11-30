#!/usr/bin/bash
#SCRIPT: util/SnpsSigSup_TestJira.bash
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-11-24
#VERSION: 2011301749Z
#LICENSE: SPDX Apache-2.0
#SUPPORT:  TODO
#CHANGELOG: 2011301749Z pj add command line case/options, tests


#[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0 | grep "^{" | sed -re 's/<= Recv data//g' | jq -C '.' | head
#USAGE: bash util/SnpsSigSup_TestJira.bash 0 |& grep "^{" |& jq -C '.' |& less -inRF                                                                                                                                                                                                                                                                                                                        
#USAGE: bash SnpsSigSup_TestJira.bash 1 |& less -inRF                                               

#USAGE 1 = return first page of project tickets
#USAGE 2 = add a comment


#TODO: remove progress output (by faking output to terminal; thought I did that...)

#[pjalajas@sup-pjalajas-hub SynopsysScripts]$ echo 5sEcpfD2BuR73HV5wUY26859
#5sEcpfD2BuR73HV5wUY26859
#snps-sig-sup-pjalajas.atlassian.net
USERSTRING="$(grep pjalajas@blackduckcloud.com ~/.pj)" # WORK, with api token, (google auth 2FA enabled)

case "$1" in
"0")
  #Get full list of all available user perms
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  #CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/mypermissions'
  #API v3 WORKS:  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/permissions'
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/permissions' 
  ;;
"0a")
  #Get list of user perms for a jira issue/ticket... 
  #[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 0 | grep "^{" | sed -re 's/<= Recv data.*//g' | jq -r -c '.permissions | to_entries[] | .key' | tr '\n' ','
  # ADD_COMMENTS,ADMINISTER,ADMINISTER_PROJECTS,ASSIGNABLE_USER,ASSIGN_ISSUES,BROWSE_PROJECTS,BULK_CHANGE,CLOSE_ISSUES,CREATE_ATTACHMENTS,CREATE_ISSUES,CREATE_PROJECT,CREATE_SHARED_OBJECTS,DELETE_ALL_ATTACHMENTS,DELETE_ALL_COMMENTS,DELETE_ALL_WORKLOGS,DELETE_ISSUES,DELETE_OWN_ATTACHMENTS,DELETE_OWN_COMMENTS,DELETE_OWN_WORKLOGS,EDIT_ALL_COMMENTS,EDIT_ALL_WORKLOGS,EDIT_ISSUES,EDIT_OWN_COMMENTS,EDIT_OWN_WORKLOGS,LINK_ISSUES,MANAGE_GROUP_FILTER_SUBSCRIPTIONS,MANAGE_SPRINTS_PERMISSION,MANAGE_WATCHERS,MODIFY_REPORTER,MOVE_ISSUES,RESOLVE_ISSUES,SCHEDULE_ISSUES,SET_ISSUE_SECURITY,SYSTEM_ADMIN,TRANSITION_ISSUES,USER_PICKER,VIEW_DEV_TOOLS,VIEW_READONLY_WORKFLOW,VIEW_VOTERS_AND_WATCHERS,WORK_ON_ISSUES,
  
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  #WORKS:  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/mypermissions?permissions=BROWSE_PROJECTS%2CEDIT_ISSUES'
  #CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/mypermissions?permissions=BROWSE_PROJECTS%2CEDIT_ISSUES'
  #CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/3/mypermissions?permissions=BROWSE_PROJECTS%2CEDIT_ISSUES'
  ;;
"1")
  #See jira project
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project=AT'
 ;;
"1a")
  #See jira issue/ticket
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1'
 ;;
"2")
  #Add comment 
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="POST"
  CURL_DATA='{ "body": "This is a pj comment" }'
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/comment'
  ;;
"2a")
  #Add comment, set visibility
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="POST"
  CURL_DATA='{ "body": "This is a pj comment that only administrators can see.", "visibility": { "type": "role", "value": "Administrators" } }'
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/comment'
  ;;
"3")
  #Show available transition info
  CURL_TRACEASCII_OUT="-"  # could be /dev/null or a file
  CURLX="GET"
  CURL_DATA=' '
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/transitions'
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
  CURLURL='https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/transitions'
 ;;
esac 

curl \
   --silent --show-error \
   --trace-ascii ${CURL_TRACEASCII_OUT} \
   -D- \
   -u "${USERSTRING}" \
   -X "${CURLX}" \
   --data "${CURL_DATA}" \
   -H "Content-Type: application/json" \
   "${CURLURL}"


exit 





#       -D, --dump-header <file>


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











#REFERENCE
test add comment:  curl -D- -u fred:fred -X POST --data {see below} -H "Content-Type: application/json" http://kelpie9:8081/rest/api/2/issue/QA-31/comment
{
    "body": "This is a comment that only administrators can see.",
    "visibility": {
        "type": "role",
        "value": "Administrators"
    }
}

{ "body": "This is a comment that only administrators can see.", "visibility": { "type": "role", "value": "Administrators" } }

WORKS?:  one liner:  curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:5sEcpfD2BuR73HV5wUY26859" -X GET -H "Content-Type: application/json" 'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22' 
bad user returns 400 bad request
bad password returns 401 unauthorized
change json to gson, 415 Unsupported Media Type


works: [pjalajas@sup-pjalajas-hub SynopsysScripts]$ curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:5sEcpfD2BuR73HV5wUY26859" -X GET -H "Content-Type: application/json" 'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project=%22AT%22' | less -inRF
works: [pjalajas@sup-pjalajas-hub SynopsysScripts]$ curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:5sEcpfD2BuR73HV5wUY26859" -X GET -H "Content-Type: application/json" 'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project=AT' | less -inRF
'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project=AT'

: '

WORKS:  one liner:  curl --trace-ascii - -D- -u "pjalajas@blackduckcloud.com:5sEcpfD2BuR73HV5wUY26859" -X GET -H "Content-Type: application/json" 'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22' 

bad?: USERSTRING="Peter Jalajas:5sEcpfD2BuR73HV5wUY26859"
   good:  https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=assignee=%22Peter%20Jalajas%22
   good:  https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search
   bad: 'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project="alert_test"'
   
   {"expand":"names,schema","startAt":0,"maxResults":50,"total":1,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10000","self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/10000","key":"AT-1","fields":{"statuscategorychangedate":"2020-11-24T15:55:41.393-0500","issuetype":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issuetype/10005","id":"10005","description":"A problem or error.","iconUrl":"https://snps-sig-sup-pjalajas.atlassian.net/secure/viewavatar?size=medium&avatarId=10303&avatarType=issuetype","name":"Bug","subtask":false,"avatarId":10303},"timespent":null,"project":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/project/10000","id":"10000","key":"AT","name":"alert_test","projectTypeKey":"software","simplified":false,"avatarUrls":{"48x48":"https://snps-sig-sup-pjalajas.atlassian.net/secure/projectavatar?pid=10000&avatarId=10406","24x24":"https://snps-sig-sup-pjalajas.atlassian.net/secure/projectavatar?size=small&s=small&pid=10000&avatarId=10406","16x16":"https://snps-sig-sup-pjalajas.atlassian.net/secure/projectavatar?size=xsmall&s=xsmall&pid=10000&avatarId=10406","32x32":"https://snps-sig-sup-pjalajas.atlassian.net/secure/projectavatar?size=medium&s=medium&pid=10000&avatarId=10406"}},"fixVersions":[],"aggregatetimespent":null,"resolution":null,"resolutiondate":null,"workratio":-1,"lastViewed":"2020-11-24T16:11:50.690-0500","watches":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/watchers","watchCount":1,"isWatching":true},"created":"2020-11-24T15:55:41.076-0500","customfield_10020":null,"customfield_10021":null,"customfield_10022":null,"priority":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/priority/3","iconUrl":"https://snps-sig-sup-pjalajas.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"customfield_10023":null,"customfield_10024":null,"customfield_10025":null,"labels":[],"customfield_10016":null,"customfield_10017":null,"customfield_10018":{"hasEpicLinkFieldDependency":false,"showField":false,"nonEditableReason":{"reason":"PLUGIN_LICENSE_ERROR","message":"The Parent Link is only available to Jira Premium users."}},"customfield_10019":"0|hzzzzz:","timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2020-11-24T15:55:41.076-0500","status":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/status/10000","description":"","iconUrl":"https://snps-sig-sup-pjalajas.atlassian.net/","name":"To Do","id":"10000","statusCategory":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}},"components":[],"timeoriginalestimate":null,"description":"test","customfield_10010":null,"customfield_10014":null,"customfield_10015":null,"customfield_10005":null,"customfield_10006":null,"customfield_10007":null,"security":null,"customfield_10008":null,"aggregatetimeestimate":null,"customfield_10009":null,"summary":"test","creator":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/user?accountId=5fbc09d1d670b8006ea85bcd","accountId":"5fbc09d1d670b8006ea85bcd","emailAddress":"pjalajas@blackduckcloud.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","24x24":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","16x16":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","32x32":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png"},"displayName":"Peter Jalajas","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"subtasks":[],"reporter":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/user?accountId=5fbc09d1d670b8006ea85bcd","accountId":"5fbc09d1d670b8006ea85bcd","emailAddress":"pjalajas@blackduckcloud.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","24x24":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","16x16":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png","32x32":"https://secure.gravatar.com/avatar/931c6c19284200c63aafb944ea48dfaa?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FPJ-0.png"},"displayName":"Peter Jalajas","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"progress":{"progress":0,"total":0},"votes":{"self":"https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/issue/AT-1/vote
                                                                             
   'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project="AT"'
   'https://snps-sig-sup-pjalajas.atlassian.net/rest/api/2/search?jql=project=AT'
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

