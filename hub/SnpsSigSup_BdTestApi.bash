#!/usr/bin/bash
#SCRIPT: SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash
#AUTHOR: pjalajas@synopsys.com
#DATE:  2020-12-08
#LICENSE: SPDX Apache-2.0
#VERSION: 2012082212Z pj initial

#USAGE: Edit CONFIGs, then:
#USAGE: [pjalajas@sup-pjalajas-hub api]$ bash /home/pjalajas/dev/git/SynopsysScripts/hub/SnpsSigSup_BdTestApi.bash | jq -C | less -inRF            


#CONFIG: #################

BD_TOKEN="ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA=="
BD_URL="https://sup-pjalajas-hub.dc1.lan"  # with httpx, no trailing slash
BD_API_TOKENS_AUTH="/api/tokens/authenticate"  # no trailing slash

#OPTIONAL CONFIGs, depends on how you do BD_API_REQUEST below, separated here for readability
BD_API_REQUEST_LIMIT=10000 # last one set, wins
BD_API_REQUEST_LIMIT=100
BD_API_REQUEST_OFFSET=0 # last one set, wins
BD_API_REQUEST_SORT_FIELD="projectName"
BD_API_REQUEST_SORT_DIRECTION="ASC"
BD_API_REQUEST_CONTENT_TYPE="application/vnd.blackducksoftware.bill-of-materials-6+json"

BD_API_REQUEST="/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=${BD_API_REQUEST_SORT_FIELD}%20${BD_API_REQUEST_SORT_DIRECTION}&offset=${BD_API_REQUEST_OFFSET}&limit=${BD_API_REQUEST_LIMIT}"



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
  ${BD_URL}${BD_API_REQUEST}


#ONE-LINER:  curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST} 

#REFERENCE ###############

: '
#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST --header "Authorization: token ${BD_TOKEN}" "${BD_URL}${BD_API_TOKENS_AUTH}" | jq -r .bearerToken)" --header "Content-Type ${BD_API_REQUEST_CONTENT_TYPE}" ${BD_URL}${BD_API_REQUEST}

#curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 

[pjalajas@sup-pjalajas-hub api]$ curl --silent --insecure --request GET --header "Authorization: Bearer $(curl --silent --insecure --request POST    --header "Authorization: token ODcxYzA0OTAtNmQ4NC00NzhjLTk0MzctYzUwODJlNGMwOGY3OjMyYzk2ZWQ4LTIzZDYtNGVjNi1hZmIxLTNmYWQyZWUzYWNiOA==" 'https://sup-pjalajas-hub.dc1.lan/api/tokens/authenticate' 2> /dev/null |& jq -r .bearerToken)" --header "Content-Type application/vnd.blackducksoftware.bill-of-materials-6+json" https://sup-pjalajas-hub.dc1.lan/api/projects/968c07fc-9252-4528-9ecc-5eb7b2302bfa/versions/22a53d42-f286-4ad8-8efb-0e7341048f5d/components?sort=projectName%20ASC&offset=0&limit=10000 2>/dev/null |& jq -C |& less -inRF 
'
