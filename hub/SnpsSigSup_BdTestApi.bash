#!/usr/bin/bash
#SCRIPT: SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash
#AUTHOR: pjalajas@synopsys.com
#DATE:  2020-12-08
#LICENSE: SPDX Apache-2.0
#VERSION: 2101221704Z
#CHANGELOG: notifications, method variable 

#USAGE: Edit CONFIGs, then:
#USAGE: [pjalajas@sup-pjalajas-hub api]$ bash /home/pjalajas/dev/git/SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash | jq -C | less -inRF            


#CONFIG: #################
#BD_API_METHOD="GET" ; BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/policy-status"
#Request URL: https://sup-pjalajas-2.dc1.lan/api/projects/55d6d2b4-2c28-485d-ab76-8bb6bab9e819/versions/c3780340-f560-455c-a150-c20431a6b728/components/907300e1-d66e-45ef-b77d-a790ed30b4e1/versions/a7d7dfd8-ef3c-4a2b-a04d-5b432eaccb7d/policy-status?limit=100

projectId="7d104f09-3273-448c-81dc-e33a7674da8f"
projectId="55d6d2b4-2c28-485d-ab76-8bb6bab9e819"
projectVersionId="a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b"
projectVersionId="c3780340-f560-455c-a150-c20431a6b728"
componentId="7a54f575-7f1a-4414-9d4d-6bc0e7a9224d"
componentId="907300e1-d66e-45ef-b77d-a790ed30b4e1"
componentVersionId="a69b12a0-c9b9-4f74-ad63-de8bac977b32"
componentVersionId="a7d7dfd8-ef3c-4a2b-a04d-5b432eaccb7d"
scan="598cecc4-0a7e-46e9-96ba-5a63be41ccf1"  # application/vnd.blackducksoftware.scan-4+json
scanId=${scan}
codeLocationId="15d3370b-3b88-4dbc-acdd-e7f86cca8ab5"  # application/vnd.blackducksoftware.scan-4+json

#BD_TOKEN="ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA=="
#BD_TOKEN="MTM3NWQ3Y2MtYTgyNS00ODBjLTkyNGItMzMzNjU0MmFmYzIwOjc4YzM2ZmMzLWYxZDktNDRlYy04ZGFhLTE1OTYwMDYxMjQ1Nw=="
#BD_TOKEN="ZWIyM2YzYjctYTlkOS00NjY3LThkZDktM2QxM2NhMTJhZjA0OjVkNThmMmQ3LTE0MmQtNDA0Zi1iM2YwLTNkNWRjYTM3MmM5YQ=="
BD_TOKEN="NjVhYjVlZDgtNjc4OC00NzY0LTg4NWEtNjk4Y2VkMzgyOWY0OjY5ZmQwMmFhLWVjZTUtNDA1ZS1hYWM2LTYyZmVkM2I0ZGVlZA=="
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
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.scan-4+json"


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
#https://sup-pjalajas-2.dc1.lan/api/scan/598cecc4-0a7e-46e9-96ba-5a63be41ccf1/bom-entries has Scanned File /org/ Matched File args4j-2.0.26.jar
BD_API_REQUEST="/api/scan"  # 404
BD_API_REQUEST="/api/scan/${scan}"  # 404
BD_API_REQUEST="/api/scan-summaries/${scanId}"  # 404
BD_API_REQUEST="/api/codelocations"    #application/vnd.blackducksoftware.scan-4+json          "href": "https://sup-pjalajas-2.dc1.lan/api/codelocations/15d3370b-3b88-4dbc-acdd-e7f86cca8ab5",
BD_API_REQUEST="/api/codelocations/${codeLocationId}/scan-summaries"    #application/vnd.blackducksoftware.scan-4+json               "href": "https://sup-pjalajas-2.dc1.lan/api/scan/598cecc4-0a7e-46e9-96ba-5a63be41ccf1/bom-entries"
BD_API_REQUEST="/api/codelocations/${codeLocationId}/latest-scan-summary"    #application/vnd.blackducksoftware.scan-4+json         "href": "https://sup-pjalajas-2.dc1.lan/api/scan/598cecc4-0a7e-46e9-96ba-5a63be41ccf1/bom-entries"
BD_API_REQUEST="/api/scan/${scanId}/bom-entries"  #  kbFilePaths, not project file paths


############## start pairing requests and types here; copy from api doc request def, add $ to front of {}.
#GET /api/projects/{projectId}/versions/{projectVersionId}/hierarchical-components Accept: application/vnd.blackducksoftware.bill-of-materials-6+json
BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/hierarchical-components" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-6+json" #     "href": "https://sup-pjalajas-2.dc1.lan/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/hierarchical-components",  # returns null
BD_API_REQUEST="/api/codelocations/${codeLocationId}" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.scan-4+json"
BD_API_REQUEST="/api/codelocations/${codeLocationId}/scan-summaries" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.scan-4+json"  # "href": "https://sup-pjalajas-2.dc1.lan/api/scan/598cecc4-0a7e-46e9-96ba-5a63be41ccf1/bom-entries"

############## start pairing methods, requests and types here; copy from api doc request def, add $ to front of {}.
#POST /api/scan/data Accept: application/vnd.blackducksoftware.bdio+json Accept: application/ld+json
#GET /api/notifications Accept: application/vnd.blackducksoftware.notification-4+json
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/notifications" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.notification-4+json"
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/notifications" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.notification-4+json"
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/notifications?filter=notificationType:policy_override" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.notification-4+json"
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/notifications-filters?filterKey=notificationType" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.notification-4+json"  # Lists notificationType's
#GET /api/projects/{projectId}/versions/{projectVersionId}/components/{componentId}/versions/{componentVersionId}/policy-status Accept: application/vnd.blackducksoftware.bill-of-materials-6+json
#BD_API_METHOD="GET" ; BD_API_REQUEST="/api/projects/7d104f09-3273-448c-81dc-e33a7674da8f/versions/a145ed5a-a241-47a2-8ff7-2aa1a8fecb7b/components/7a54f575-7f1a-4414-9d4d-6bc0e7a9224d/versions/a69b12a0-c9b9-4f74-ad63-de8bac977b32/policy-status"
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/policy-status" ; BD_API_REQUEST_CONTENT_TYPE="content-type: application/vnd.blackducksoftware.internal-1+json"
BD_API_METHOD="GET" ; BD_API_REQUEST="/api/projects/${projectId}/versions/${projectVersionId}/components/${componentId}/versions/${componentVersionId}/policy-status" ; BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-6+json"

# INIT


#MAIN: ################

echo BD_API_METHOD=$BD_API_METHOD
echo BD_API_REQUEST_CONTENT_TYPE=$BD_API_REQUEST_CONTENT_TYPE
echo BD_API_REQUEST=$BD_API_REQUEST

curl --silent --insecure \
  --request $BD_API_METHOD \
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
{"approvalStatus":"IN_VIOLATION_OVERRIDDEN","policyRuleViolationViews":[{"policyRuleView":{"name":"pj policy","enabled":true,"overridable":true,"severity":"UNSPECIFIED","expression":{"operator":"AND","expressions":[{"name":"SINGLE_VERSION","operation":"EQ","parameters":{"values":["https://sup-pjalajas-2.dc1.lan/api/components/907300e1-d66e-45ef-b77d-a790ed30b4e1"],"data":[{"componentName":"Bouncy Castle","componentUrl":"https://sup-pjalajas-2.dc1.lan/api/components/907300e1-d66e-45ef-b77d-a790ed30b4e1"}]},"displayName":"Component","developerScanExpression":true}]},"category":"UNCATEGORIZED","createdAt":"2021-02-10T20:58:37.003Z","createdBy":"sysadmin","createdByUser":"https://sup-pjalajas-2.dc1.lan/api/users/00000000-0000-0000-0001-000000000001","updatedAt":"2021-02-10T20:58:37.003Z","updatedBy":"sysadmin","updatedByUser":"https://sup-pjalajas-2.dc1.lan/api/users/00000000-0000-0000-0001-000000000001","_meta":{"allow":["DELETE","GET","PUT"],"href":"https://sup-pjalajas-2.dc1.lan/api/policy-rules/9e9a990c-bcab-4636-95be-53bf582a9cdf","links":[]}},"approvalStatus":"IN_VIOLATION_OVERRIDDEN","approvalStatusUrl":"https://sup-pjalajas-2.dc1.lan/api/projects/55d6d2b4-2c28-485d-ab76-8bb6bab9e819/versions/c3780340-f560-455c-a150-c20431a6b728/components/907300e1-d66e-45ef-b77d-a790ed30b4e1/versions/a7d7dfd8-ef3c-4a2b-a04d-5b432eaccb7d/policy-rules/9e9a990c-bcab-4636-95be-53bf582a9cdf/policy-status","overriddenBy":[{"user":"https://sup-pjalajas-2.dc1.lan/api/users/00000000-0000-0000-0001-000000000001","name":"sysadmin"}],"updatedBy":[{"user":"https://sup-pjalajas-2.dc1.lan/api/users/00000000-0000-0000-0001-000000000001","name":"sysadmin","comment":"pjalajaspolicyoverridecomment","updatedAt":"2021-02-10T20:59:39.376Z"}]}],"_meta":{"allow":["GET","PUT"],"href":"https://sup-pjalajas-2.dc1.lan/api/projects/55d6d2b4-2c28-485d-ab76-8bb6bab9e819/versions/c3780340-f560-455c-a150-c20431a6b728/components/907300e1-d66e-45ef-b77d-a790ed30b4e1/versions/a7d7dfd8-ef3c-4a2b-a04d-5b432eaccb7d/policy-status"}}
'

: '
  #-u "sysadmin:blackduck" \
# --header "Authorization: token ${BD_TOKEN}" \
#ONE-LINER:  curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST} 
#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST}

#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 

[pjalajas@sup-pjalajas-hub api]$ curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 
'
