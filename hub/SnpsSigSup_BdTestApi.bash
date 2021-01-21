#!/usr/bin/bash
#SCRIPT: SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash
#AUTHOR: pjalajas@synopsys.com
#DATE:  2020-12-08
#LICENSE: SPDX Apache-2.0
#VERSION: 2012082212Z pj initial

#USAGE: Edit CONFIGs, then:
#USAGE: [pjalajas@sup-pjalajas-hub api]$ bash /home/pjalajas/dev/git/SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash | jq -C | less -inRF            


#CONFIG: #################
projectId="7d104f09-3273-448c-81dc-e33a7674da8f"
projectVersionId="a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b"
componentId="7a54f575-7f1a-4414-9d4d-6bc0e7a9224d"
componentVersionId="a69b12a0-c9b9-4f74-ad63-de8bac977b32"

#BD_TOKEN="ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA=="
BD_TOKEN="MTM3NWQ3Y2MtYTgyNS00ODBjLTkyNGItMzMzNjU0MmFmYzIwOjc4YzM2ZmMzLWYxZDktNDRlYy04ZGFhLTE1OTYwMDYxMjQ1Nw=="
#BD_URL="https://sup-pjalajas-hub.dc1.lan"  # with httpx, no trailing slash
BD_URL="https://sup-pjalajas-2.dc1.lan"  # with httpx, no trailing slash
BD_API_TOKENS_AUTH="/api/tokens/authenticate"  # no trailing slash

#OPTIONAL CONFIGs, depends on how you do BD_API_REQUEST below, separated here for readability
BD_API_REQUEST_LIMIT=10000 # last one set, wins
BD_API_REQUEST_LIMIT=100
BD_API_REQUEST_OFFSET=0 # last one set, wins
BD_API_REQUEST_SORT_FIELD="projectName"
BD_API_REQUEST_SORT_DIRECTION="ASC"
#BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-6+json"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-4+json"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.notification-4+json"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.policy-4+json"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-6+json"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.component-detail-5+json"

#BD_API_REQUEST="/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=${BD_API_REQUEST_SORT_FIELD}%20${BD_API_REQUEST_SORT_DIRECTION}&offset=${BD_API_REQUEST_OFFSET}&limit=${BD_API_REQUEST_LIMIT}"
#BD_API_REQUEST="/api/policy-rules/19f96ec7-1f9c-40ec-91f3-52e3ac6f57c5"
# BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/policy-status"
BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/component-versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/comments"
#GOOD: BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components"
BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32"
BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/policy-status"
BD_API_REQUEST="/api/notifications"
BD_API_REQUEST="/api/notifications/77e57866-3e99-4d09-b5f6-9ce602802c9e"

#Matched File Representation, { "totalCount" : 1, "items" : [ { "filePath" : { "path" : "/path/to/file", "archiveContext" : "", "compositePathContext" : "/path/to/file#", "fileName" : "file" 
#                GET /api/projects/{projectId}/versions/{projectVersionId}/components/{componentId}/versions/{componentVersionId}/matched-files
#BD_API_REQUEST="GET /api/projects/{projectId}/versions/{projectVersionId}/components/{componentId}/versions/{componentVersionId}/origins/{componentOriginId}/matched-files"
#404: BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/origins/${componentOriginId}/matched-files"
#404: BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/origins"
#BD_API_REQUEST="/api/components/${componentId}/versions/${componentVersionId}/origins"
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/matched-files" # returns uris
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}"
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/matched-files"
#if an origin is assigned to the BOM component, you have to use the /api/project/{}/versions/{}/components/{}/versions/{}/origins/{}/matched-files endpoint https://sup-pjalajas-2.dc1.lan/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/version[…]rigins/cbc69970-a71e-431c-bd98-6a2226bcfcac/matched-files
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/origins"
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}"
BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/origins/cbc69970-a71e-431c-bd98-6a2226bcfcac/matched-files"
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/origins/cbc69970-a71e-431c-bd98-6a2226bcfcac/matched-files"

echo $BD_API_REQUEST_CONTENT_TYPE
echo $BD_API_REQUEST


#MAIN: ################

curl --silent --insecure \
  --request GET \
  --header "Authorization: Bearer $(\
    curl --silent --insecure \
      --request POST \
      --header "Authorization: token ${BD_TOKEN}" \
      "${BD_URL}${BD_API_TOKENS_AUTH}" | \
      jq -r .bearerToken \
      )" \
  --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" \
  ${BD_URL}${BD_API_REQUEST} \
  | jq -C '.'

exit
#REFERENCE ###############

: '
  #-u "sysadmin:blackduck" \
# --header "Authorization: token ${BD_TOKEN}" \
#ONE-LINER:  curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST} 
#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST}

#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 

[pjalajas@sup-pjalajas-hub api]$ curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 
'
