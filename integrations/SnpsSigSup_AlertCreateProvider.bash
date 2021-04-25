#/bin/bash
#/home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertCreateProvider.bash
#Create Synopsys Alert Provider
  #Request URL: https://webserver:8443/alert/api/configuration
  #Request Method: POST
  #Status Code: 201 
  #Remote Address: 10.1.65.171:80
  #accept: application/json
  #Cookie: ALERT_SESSION_ID=09967E72E01BC0AB85D6B4C5DD479DDB
  #x-csrf-token: cd93bd4c-dd4c-43d9-86c0-76284a69f516
  #Response: Content-Type: application/json

#CONFIG

ALERT_HOSTNAME=webserver
site_url="https://${ALERT_HOSTNAME}:8443" # no trailing slash
username="sysadmin"
password="blackduck"
cookie_path=/tmp/cookie # no trailing slash
BLACKDUCK_URL=https://webserver   # like https://webserver
BLACKDUCK_API_KEY="ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg=="
PROVIDER_COMMON_CONFIG_NAME=provider_$(date --utc +%H%M%SZ)

#INIT

login_url="$site_url/alert/api/login" # no trailing slash
rm $cookie_path
request_endpoint=/alert/api/configuration # no trailing slash
action_url="${site_url}${request_endpoint}" # no trailing slash
METHOD=POST
ACCEPT="application/json"
#data={"context":"GLOBAL","descriptorName":"provider_blackduck","keyToValues":{"provider.common.config.enabled":{"values":["true"],"isSet":true},"provider.common.config.name":{"values":["$PROVIDER_COMMON_CONFIG_NAME"],"isSet":false},"blackduck.url":{"values":["$BLACKDUCK_URL"],"isSet":false},"blackduck.api.key":{"values":["$BLACKDUCK_API_KEY"],"isSet":false},"blackduck.timeout":{"values":["300"],"isSet":true}}}
:'          "bodySize": 483,
          "postData": {
            "mimeType": "application/json",
            "text": "{\"context\":\"GLOBAL\",\"descriptorName\":\"provider_blackduck\",\"keyToValues\":{\"provider.common.config.enabled\":{\"values\":[\"true\"],\"isSet\":true},\"provider.common.config.name\":{\"values\":[\"provider_04242238E\"],\"isSet\":false},\"blackduck.url\":{\"values\":[\"https://webserver\"],\"isSet\":false},\"blackduck.api.key\":{\"values\":[\"ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg==\"],\"isSet\":false},\"blackduck.timeout\":{\"values\":[\"300\"],\"isSet\":true}}}"
          }
        },
'
data="{\"context\":\"GLOBAL\",\"descriptorName\":\"provider_blackduck\",\"keyToValues\":{\"provider.common.config.enabled\":{\"values\":[\"true\"],\"isSet\":true},\"provider.common.config.name\":{\"values\":[\"provider_04242244E\"],\"isSet\":false},\"blackduck.url\":{\"values\":[\"https://webserver\"],\"isSet\":false},\"blackduck.api.key\":{\"values\":[\"ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg==\"],\"isSet\":false},\"blackduck.timeout\":{\"values\":[\"300\"],\"isSet\":true}}}"
data="{\"context\":\"GLOBAL\",\"descriptorName\":\"provider_blackduck\",\"keyToValues\":{\"provider.common.config.enabled\":{\"values\":[\"true\"],\"isSet\":true},\"provider.common.config.name\":{\"values\":[\"provider_04242248E\"],\"isSet\":false},\"blackduck.url\":{\"values\":[\"https://webserver\"],\"isSet\":false},\"blackduck.api.key\":{\"values\":[\"ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg==\"],\"isSet\":false},\"blackduck.timeout\":{\"values\":[\"300\"],\"isSet\":true}}}"
json={"context":"GLOBAL","descriptorName":"provider_blackduck","keyToValues":{"provider.common.config.enabled":{"values":["true"],"isSet":true},"provider.common.config.name":{"values":["provider_04242310E"],"isSet":false},"blackduck.url":{"values":["https://webserver"],"isSet":false},"blackduck.api.key":{"values":["ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg=="],"isSet":false},"blackduck.timeout":{"values":["300"],"isSet":true}}}


# Manage creds
# Get token and construct the cookie, save the returned token.
echo
echo Getting token and cookie before login... TODO pick better endpoint
#0056: Cookie: ALERT_SESSION_ID=A04BDAD390CA1338E5868CE415CDE7CA
#0000: X-CSRF-TOKEN: c69cca4e-42b7-4d52-94c0-1cf43bb4fa50    # only seen after login at Alert
#curl --trace-ascii - --insecure -b $cookie_path -c $cookie_path --request GET "$site_url/alert/api/certificates" -s
echo
echo Logging in with token and cookie...
#curl --insecure --trace-ascii - -H "Content-Type: application/json" -b $cookie_path -c $cookie_path -d "{\"alertUsername\":\"$username\", \"alertPassword\":\"$password\"}" "$login_url" -s

#TODO extract above creds code to an include file, and then call it here

# Send POST to you custom action URL. With the token in header "X-CSRF-Token: $token"
echo
echo Sending custom action with the token, $action_url ...
#curl --insecure --trace-ascii - -H "X-CSRF-Token: $token" -b $cookie_path -c $cookie_path -d "$data" -X GET "$action_url" -s
#curl --trace-ascii - --insecure --silent -H "X-CSRF-Token: $token" -H "Content-Type: application/json" -b $cookie_path -c $cookie_path -d "$data" -X $METHOD "$action_url"
curl --trace-ascii - --insecure --silent -H "X-CSRF-Token: c9951af0-fb7a-4e29-8dae-7f996a7d3015" -H "Content-Type: application/json" -b $cookie_path -c $cookie_path -d "$data" -X $METHOD "$action_url"
#######

exit

#REFERENCE

POST /alert/api/configuration HTTP/1.1
Connection: keep-alive
sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"
accept: application/json
x-csrf-token: c9951af0-fb7a-4e29-8dae-7f996a7d3015
sec-ch-ua-mobile: ?0
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36
content-type: application/json
Origin: https://webserver:8443
Sec-Fetch-Site: same-origin
Sec-Fetch-Mode: cors
Sec-Fetch-Dest: empty
Referer: https://webserver:8443/alert/providers/blackduck
Accept-Language: en-US,en;q=0.9
Cookie: ALERT_SESSION_ID=56669F1B3DB313748099D0BEF91C8D5B; ALERT_SESSION_ID=386A2C7B2775160AA23387E49BD9D095
Authorization: Basic c3lzYWRtaW46YmxhY2tkdWNr
Postman-Token: 57a1db9b-1692-4527-a979-64f81dd6ae1c
Host: webserver:8443
Accept-Encoding: gzip, deflate, br
Content-Length: 483
{"context":"GLOBAL","descriptorName":"provider_blackduck","keyToValues":{"provider.common.config.enabled":{"values":["true"],"isSet":true},"provider.common.config.name":{"values":["provider_04242310E"],"isSet":false},"blackduck.url":{"values":["https://webserver"],"isSet":false},"blackduck.api.key":{"values":["ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg=="],"isSet":false},"blackduck.timeout":{"values":["300"],"isSet":true}}}
HTTP/1.1 201 Created
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
X-Frame-Options: DENY
Content-Type: application/json
Transfer-Encoding: chunked
Date: Sun, 25 Apr 2021 03:11:21 GMT
{"id":"20","keyToValues":{"blackduck.api.key":{"values":[],"isSet":true},"provider.common.config.enabled":{"values":["true"],"isSet":true},"blackduck.url":{"values":["https://webserver"],"isSet":true},"blackduck.timeout":{"values":["300"],"isSet":true},"provider.common.config.name":{"values":["provider_04242310E"],"isSet":true}},"descriptorName":"provider_blackduck","context":"GLOBAL","createdAt":"2021-04-25 03:11 (UTC)","lastUpdated":"2021-04-25 03:11 (UTC)"}


#TEST:
#Request URL: https://webserver:8443/alert/api/configuration/test
#Request Method: POST
#Status Code: 200 
#Remote Address: 10.1.65.171:80
#Request:
#accept: application/json
#content-type: application/json
#{"context":"GLOBAL","descriptorName":"provider_blackduck","keyToValues":{"provider.common.config.enabled":{"values":["true"],"isSet":true},"provider.common.config.name":{"values":["pjProviderConfig"],"isSet":true},"blackduck.url":{"values":["https://webserver"],"isSet":true},"blackduck.api.key":{"values":[],"isSet":true},"blackduck.timeout":{"values":["300"],"isSet":true}},"id":"16"} 
#Response:
#Content-Type: application/json
#{"message":"Successfully sent test message.","errors":{},"hasErrors":false}
