#!/usr/bin/bash
#SCRIPT:  /home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertCreateInstance.bash
#AUTHOR:  pjalajas@synopsys.com
#LICENSE:  SPDX Apache-2.0
#SUPPORT: TODO
#DATE:   Thu Nov 12 22:02:37 UTC 2020
#VERSION:  2104250418Z
#CHANGE:  pj renamed script; created external newman collection to create Provider, Channel, Distribution.

#PURPOSE:  USE AT OWN RISK.  For testing only, not safe.  Deletes things.  
#PURPOSE:  Try to automate setting up the simplest possible Synopsys Alert by scriptifying the README.md. Wish me luck. 

#USAGE: Optional: Search this script for CONFIG and edit them.  Defaults to "blackduck" for most names and passwords. 
#USAGE: Run in new empty directory, probably near your Black Duck directory.
#USAGE: bash /home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertREADME.md.bash 2>&1 | tee -a SnpsSigSup_AlertREADME.md.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a).out

#TODO: This is a first working prototype.  Lots of cleanup to do, guardrails to install.

#https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/187564033/Synopsys+Alert
#https://github.com/blackducksoftware/blackduck-alert

#CONFIG
#Until I move them all here, search rest of file for CONFIG, too...
#Compatability: https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/177799187/Black+Duck+Release+Compatibility
#ALERT_VERSION=6.4.3   # CONFIG    not released yet
#ALERT_VERSION=6.4.2   # CONFIG   fails with 2021.2.0? 
  # 2021-04-23 22:59:01.878  WARN 1 --- [nio-8443-exec-5] c.s.i.a.p.b.v.BlackDuckValidator         : User permission failed, cannot read notifications from Black Duck.
  # 2021-04-23 22:59:06.765 ERROR 1 --- [nio-8443-exec-6] c.s.i.a.p.b.a.BlackDuckGlobalTestAction  : Could not perform the authorization request: webserver
ALERT_VERSION=6.4.0   # CONFIG
#BLACKDUCK_HOSTNAME=sup-pjalajas-hub.dc1.lan  # set to "webserver" if you haven't set the BD hub webserver name in the BD webserver .env file
BLACKDUCK_HOSTNAME=webserver  # set to "webserver" if you haven't set the BD hub webserver name in the BD webserver .env file
JIRA_HOSTNAME=snps-sig-sup-pjalajas.atlassian.net # https://snps-sig-sup-pjalajas.atlassian.net/jira/software/c/projects/AT/issues/
grep $BLACKDUCK_HOSTNAME /etc/hosts # to match hub cert SAN name to avoid this ERROR: TODO _____
BLACKDUCK_TOKEN="ZDg1NWZmMDctM2U5Yy00YTMzLWE2ZTUtMjIzMzZjMGFiZWY3OjhkNTcwMTgwLTIzN2ItNDZhMC05ZTRkLTk4YjM2Zjk5OTdjMg=="
JIRA_TOKEN="5tUTpmwRGmuvkXjx95PW450D"
WEBSERVER_IP=10.1.65.171  # appended to /etc/hosts inside container, so can match container cert name/SAN for Black Duck Provider config, https://webserver

#INIT

date --utc 
date
hostname -f
pwd
whoami

#MAIN

# Black Duck Alert On Docker Swarm
#This document describes how to install and upgrade Alert in Docker Swarm.
## Requirements
#- A Docker host with at least 2GB of allocatable memory.
echo
echo TEST: A Docker host with at least 2GB of allocatable memory.
grep -i free /proc/meminfo | grep -e Mem -e Swap
free -g
#MemFree:         1156692 kB
#SwapFree:        1453924 kB

#- Administrative access to the docker host machine. 
echo
echo TEST: Administrative access to the docker host machine. 
sudo hostname

echo "TODO: this is a doc BUG, needs a link or explanation:
- Before installing or upgrading Alert the desired persistent storage volumes must be created for Alert and needs to be either:
    - Node locked.     
    - Backed by an NFS volume or a similar mechanism.
I think it means, just use the alert postgresql container, or something else.  We'll just use the pg container in this simple script."

#read -p "OK? Hit Enter to continue..." x

echo
echo Removing running Alert stacks...
docker stack rm $(docker stack ls | grep alert_.*Swarm | cut -d ' ' -f 1)
echo
echo sleeping 5 seconds to let the stack remove...
sleep 5s

## Installing Alert
echo Downloading Alert orchestration files...
#wget https://github.com/blackducksoftware/blackduck-alert/releases/download/6.4.2/blackduck-alert-6.4.2-deployment.zip
echo
wget https://github.com/blackducksoftware/blackduck-alert/releases/download/${ALERT_VERSION}/blackduck-alert-${ALERT_VERSION}-deployment.zip

#Deployment files for Docker Swarm are located in the *docker-swarm* directory of the zip file.
#```
#blackduck-alert-<VERSION>-deployment.zip file.
#```
#- Extract the contents of the ZIP file.
echo
echo Extracting the contents of the ZIP file...
#unzip blackduck-alert-6.4.2-deployment.zip -d blackduck-alert-6.4.2-deployment
echo
echo Removing prior files...
rm -rf ./blackduck-alert-${ALERT_VERSION}-deployment
echo
echo unzipping new deployment zip...
unzip blackduck-alert-${ALERT_VERSION}-deployment.zip -d blackduck-alert-${ALERT_VERSION}-deployment
#- For installing with Black Duck the files are located in the *hub* sub-directory.
#- For installing Alert standalone the files are located in the *standalone* sub-directory.
echo Installing Alert standalone, the files are located in the *standalone* sub-directory...

#Multiline comment, just for reference:
: '

  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/hub/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/hub/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/hub/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/hub/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/docker-compose.local-overrides.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/README.md
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/standalone/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/standalone/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/docker-compose.local-overrides.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/README.md
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/Chart.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/_helpers.tpl
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-cfssl.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-environ-configmap.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/postgres.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/postgres-config.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-environ-secret.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/serviceaccount.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/synopsys-alert-6.4.2.tgz
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/values.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/DEVELOPER_README.md
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/README.md
'

echo
echo Removing extra files...
rm -rf ./blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/docker-swarm/hub
rm -rf ./blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/docker-swarm/external-db
rm -rf ./blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/helm
echo
echo Our working files...
find ./blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment -type f -ls
STANDALONE_DOCKER_SWARM_DIR=blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/docker-swarm # no trailing slash
LOCAL_OVERRIDES_FILENAME=blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/docker-swarm/docker-compose.local-overrides.yml # CONFIG
STANDALONE_DOCKER_COMPOSE_FILENAME=blackduck-alert-${ALERT_VERSION}-deployment/blackduck-alert-${ALERT_VERSION}-deployment/docker-swarm/standalone/docker-compose.yml # CONFIG

### Standalone Installation
#This section will walk through the instructions to install Alert in a standalone fashion.

#### Overview

#1. Create ALERT_ENCRYPTION_PASSWORD secret.
#2. Create ALERT_ENCRYPTION_GLOBAL_SALT secret.
#3. Create ALERT_DB_USERNAME secret.
#4. Create ALERT_DB_PASSWORD secret.
#5. Manage certificates.
#6. Modify environment variables.
#7. Deploy the stack.
 
#### Details 
#This section will walk through each step of the installation procedure.

echo
echo Setting STACK_NAME...
STACK_NAME=alert_$(echo $ALERT_VERSION | tr -d \.)_$(date --utc +%m%d%H%MZ)   # CONFIG

#CONFIG:  Edit this YML if needed.  
#Insert these below in LOCAL_OVERRIDES_YML under   alert: environment:
#- JAVA_TOOL_OPTIONS=-Djavax.net.debug=all  # CONFIG
#- ALERT_LOGGING_LEVEL=INFO  # CONFIG #- Set the value to one of the following: #- DEBUG #- ERROR #- INFO #- TRACE #- WARN
LOCAL_OVERRIDES_YML="
version: '3.6'
services:
  alertdb:
    environment:
      - POSTGRES_DB=alertdb
      - POSTGRES_USER_FILE=/run/secrets/ALERT_DB_USERNAME
      - POSTGRES_PASSWORD_FILE=/run/secrets/ALERT_DB_PASSWORD
    secrets:
      - ALERT_DB_USERNAME
      - ALERT_DB_PASSWORD
  alert:
    environment:
      - ALERT_LOGGING_LEVEL=TRACE
      - JAVA_TOOL_OPTIONS='-Djavax.net.debug=all'  
    secrets:
      - ALERT_ENCRYPTION_PASSWORD
      - ALERT_ENCRYPTION_GLOBAL_SALT
      - ALERT_DB_USERNAME
      - ALERT_DB_PASSWORD
      - source: jssecacerts
        target: jssecacerts
        mode: 0664
      - ALERT_TRUST_STORE_PASSWORD
    extra_hosts:
      - \"webserver:$WEBSERVER_IP\" 
secrets:
  ALERT_ENCRYPTION_PASSWORD:
    external: true
    name: ${STACK_NAME}_ALERT_ENCRYPTION_PASSWORD
  ALERT_ENCRYPTION_GLOBAL_SALT:
    external: true
    name: ${STACK_NAME}_ALERT_ENCRYPTION_GLOBAL_SALT
  ALERT_DB_USERNAME:
    external: true
    name: ${STACK_NAME}_ALERT_DB_USERNAME
  ALERT_DB_PASSWORD:
    external: true
    name: ${STACK_NAME}_ALERT_DB_PASSWORD
  jssecacerts:
    external: true
    name: ${STACK_NAME}_jssecacerts
  ALERT_TRUST_STORE_PASSWORD:
    external: true
    name: ${STACK_NAME}_ALERT_TRUST_STORE_PASSWORD
"
echo "$LOCAL_OVERRIDES_YML" > $LOCAL_OVERRIDES_FILENAME


echo
echo Creating docker secrets for Alert...
##### 1. Create ALERT_ENCRYPTION_PASSWORD secret.
#- Create a docker secret containing the encryption password for Alert.
    #docker secret create <STACK_NAME>_ALERT_ENCRYPTION_PASSWORD <FILE_CONTAINING_PASSWORD>
    FILE_CONTAINING_ENCRYPTION_PASSWORD=file_containing_encryption_password
    echo "blackduck" > $FILE_CONTAINING_ENCRYPTION_PASSWORD
    docker secret create ${STACK_NAME}_ALERT_ENCRYPTION_PASSWORD $FILE_CONTAINING_ENCRYPTION_PASSWORD

##### 2. Create ALERT_ENCRYPTION_GLOBAL_SALT secret.
#- Create a docker secret containing the encryption salt for Alert.
    #docker secret create <STACK_NAME>_ALERT_ENCRYPTION_GLOBAL_SALT <FILE_CONTAINING_SALT>
    FILE_CONTAINING_SALT=file_containing_salt  # CONFIG
    echo "blackduck" > $FILE_CONTAINING_SALT # CONFIG
    docker secret create ${STACK_NAME}_ALERT_ENCRYPTION_GLOBAL_SALT $FILE_CONTAINING_SALT

##### 3. Create ALERT_DB_USERNAME secret.
#- Create a docker secret containing the database username for Alert.
    #docker secret create <STACK_NAME>_ALERT_DB_USERNAME <FILE_CONTAINING_USER_NAME>
    FILE_CONTAINING_DB_USER_NAME=file_containing_db_user_name # CONFIG
    echo "blackduck" > $FILE_CONTAINING_DB_USER_NAME # CONFIG
    docker secret create ${STACK_NAME}_ALERT_DB_USERNAME $FILE_CONTAINING_DB_USER_NAME
    
##### 4. Create ALERT_DB_PASSWORD secret.
#- Create a docker secret containing the database password for Alert.
    #docker secret create <STACK_NAME>_ALERT_DB_PASSWORD <FILE_CONTAINING_PASSWORD>
    FILE_CONTAINING_DB_PASSWORD=file_containing_db_password
    echo "blackduck" > $FILE_CONTAINING_DB_PASSWORD
    docker secret create ${STACK_NAME}_ALERT_DB_PASSWORD $FILE_CONTAINING_DB_PASSWORD





##### 5. Manage certificates.	
#Using Custom Certificate TrustStore
#Custom java TrustStore file for the Alert server to communicate over SSL to external systems.
echo
echo Creating Custom java TrustStore file for the Alert server to communicate over SSL to external systems...
echo TODO:  try to move this to newman api collection request.
#You can import certificates via the Alert UI if you log in as a system administrator. This is the preferred option. You may follow these instructions to supply a TrustStore on application startup.
#Must have a valid JKS trust store file that can be used as the TrustStore for Alert. If certificate errors arise, then this is the TrustStore where certificates will need to be imported to resolve those issues.
#Only one of the following secrets needs to be created. If both are created, then jssecacerts secret will take precedence and be used by Alert.
#Create the secret. Only create one of the following secrets.
#jssecacerts - The java TrustStore file with any custom certificates imported.
#docker secret create <STACK_NAME>_jssecacerts <PATH_TO_TRUST_STORE_FILE>	

echo Creating new truststore...
echo TODO: import Black Duck and Jira certificates into new truststore...

PATH_TO_TRUST_STORE_FILE=${STANDALONE_DOCKER_SWARM_DIR}/jssecacerts # CONFIG
rm $PATH_TO_TRUST_STORE_FILE
TRUSTSTORE_PASSWORD=changeit # CONFIG

echo Importing Black Duck and Jira certificates into Alert truststore...
#sudo keytool -import -alias sup-pjalajas-hub.dc1.lan -file cert_chain.crt -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.el7_9.x86_64/jre/lib/security/jssecacerts -storepass changeit -noprompt
#echo true | openssl s_client \
  #-host $BLACKDUCK_HOSTNAME \
  #-port 443 -showcerts 2>/dev/null | \
  #openssl x509 | \
  #> ${BLACKDUCK_HOSTNAME}.pem
#sudo keytool -import \
  #-alias $BLACKDUCK_HOSTNAME \
  #-file ${BLACKDUCK_HOSTNAME}.pem \
  #-keystore $PATH_TO_TRUST_STORE_FILE \
  #-storepass $TRUSTSTORE_PASSWORD \
  #-noprompt
#rm jssecacerts ; echo true | openssl s_client -host sup-pjalajas-hub.dc1.lan -port 443 -showcerts | keytool -import -alias sup-pjalajas-hub.dc1.lan -keystore jssecacerts -storepass changeit -noprompt
#rm jssecacerts ; echo true | openssl s_client -host webserver -port 443 -showcerts | keytool -import -alias webserver -keystore jssecacerts -storepass changeit -noprompt
rm $PATH_TO_TRUST_STORE_FILE 
#echo true | \
#  openssl s_client -host webserver -port 443 -showcerts | \
#  keytool -import -alias webserver -keystore $PATH_TO_TRUST_STORE_FILE -storepass changeit -noprompt -storetype jks
#keytool -list -keystore $PATH_TO_TRUST_STORE_FILE -storepass changeit
echo true | \
  openssl s_client \
    -host $BLACKDUCK_HOSTNAME \
    -port 443 \
    -showcerts | \
  keytool \
    -import \
    -alias $BLACKDUCK_HOSTNAME \
    -keystore $PATH_TO_TRUST_STORE_FILE \
    -storepass $TRUSTSTORE_PASSWORD \
    -noprompt \
    -storetype jks
keytool \
    -list \
    -keystore $PATH_TO_TRUST_STORE_FILE \
    -storepass $TRUSTSTORE_PASSWORD
echo true | \
  openssl s_client \
    -host $JIRA_HOSTNAME \
    -port 443 \
    -showcerts | \
  keytool \
    -import \
    -alias $JIRA_HOSTNAME \
    -keystore $PATH_TO_TRUST_STORE_FILE \
    -storepass $TRUSTSTORE_PASSWORD \
    -noprompt \
    -storetype jks
keytool \
    -list \
    -keystore $PATH_TO_TRUST_STORE_FILE \
    -storepass $TRUSTSTORE_PASSWORD

echo
echo Creating a docker secret containing the path to the trust store...
docker secret create ${STACK_NAME}_jssecacerts $PATH_TO_TRUST_STORE_FILE	
#Create a docker secret containing the password for the trust store.
echo
echo Creating a docker secret containing the password for the trust store...
FILE_CONTAINING_TRUST_STORE_PASSWORD=file_containing_trust_store_password
echo $TRUSTSTORE_PASSWORD > $FILE_CONTAINING_TRUST_STORE_PASSWORD
#docker secret create <STACK_NAME>_ALERT_TRUST_STORE_PASSWORD <FILE_CONTAINING_PASSWORD>	
docker secret create ${STACK_NAME}_ALERT_TRUST_STORE_PASSWORD $FILE_CONTAINING_TRUST_STORE_PASSWORD








#### 6. Modify environment variables.
#- Set the required environment variable ALERT_HOSTNAME. See [Alert Hostname Variable](#alert-hostname-variable)
echo
echo Setting the required environment variable ALERT_HOSTNAME. # See [Alert Hostname Variable](#alert-hostname-variable)
export ALERT_HOSTNAME=$(hostname -f)  # CONFIG
echo
echo ALERT_HOSTNAME=$ALERT_HOSTNAME 





##### 7. Deploy the stack.
    #docker stack deploy -c <PATH>/docker-swarm/standalone/docker-compose.yml -c <PATH>/docker-swarm/docker-compose.local-overrides.yml <STACK_NAME>
    echo
    echo Deploying alert...
    docker stack deploy -c $STANDALONE_DOCKER_COMPOSE_FILENAME -c $LOCAL_OVERRIDES_FILENAME $STACK_NAME




  
echo
echo "Watch deployment with 
watch docker ps \| grep alert"
echo -e "\nIn a couple of minutes, run these:
echo true | openssl s_client -connect ${ALERT_HOSTNAME}:8443
curl --trace-ascii - --insecure https://${ALERT_HOSTNAME}:8443/alert
Then open your browser to https://${ALERT_HOSTNAME}:8443/alert and login with sysadmin / blackduck to continue the installation.  
Here's your BLACKDUCK_TOKEN: $BLACKDUCK_TOKEN
Your JIRA_TOKEN: $JIRA_TOKEN
"
echo
echo -e "help:
https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/187564033/Synopsys+Alert
https://github.com/blackducksoftware/blackduck-alert

You may now run newman collections to create Providers, Channels, and Distributions:
[pjalajas@sup-pjalajas-hub alert]$ newman run --insecure /home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertCreateProviderChannelDistribution_collection.json 
"



exit
#REFERENCE


######
[pjalajas@sup-pjalajas-hub alert]$ newman run --insecure /home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertCreateProviderChannelDistribution_collection.json 
newman

Alert

→ Authenticate
  POST https://sup-pjalajas-hub.dc1.lan:8443/alert/api/login [204 No Content, 457B, 5.4s]
  ✓  Status code is 204

→ Create Provider Black Duck
  POST https://sup-pjalajas-hub.dc1.lan:8443/alert/api/configuration [201 Created, 833B, 287ms]
  ✓  Status code is 201 Created

→ Create Channel Jira Cloud
  POST https://sup-pjalajas-hub.dc1.lan:8443/alert/api/configuration [201 Created, 830B, 40ms]
  ✓  Status code is 201 Created

→ Create Distribution Black Duck Jira
  POST https://sup-pjalajas-hub.dc1.lan:8443/alert/api/configuration/job [201 Created, 1.78KB, 54ms]
  ✓  Status code is 201 Created

┌─────────────────────────┬────────────────────┬───────────────────┐
│                         │           executed │            failed │
├─────────────────────────┼────────────────────┼───────────────────┤
│              iterations │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│                requests │                  4 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│            test-scripts │                  8 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│      prerequest-scripts │                  4 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│              assertions │                  4 │                 0 │
├─────────────────────────┴────────────────────┴───────────────────┤
│ total run duration: 6s                                           │
├──────────────────────────────────────────────────────────────────┤
│ total data received: 2.33KB (approx)                             │
├──────────────────────────────────────────────────────────────────┤
│ average response time: 1467ms [min: 40ms, max: 5.4s, s.d.: 2.3s] │
└──────────────────────────────────────────────────────────────────┘



Example output:

[pjalajas@sup-pjalajas-hub alert]$ bash /home/pjalajas/Documents/dev/git/SynopsysScripts/integrations/SnpsSigSup_AlertREADME.md.bash 2>&1 | tee -a SnpsSigSup_AlertREADME.md.bash_$(hostname -f)_$(date --utc +%Y%m%d%H%M%SZ%a).out
Fri Apr 23 04:09:21 UTC 2021
Fri Apr 23 00:09:21 EDT 2021
sup-pjalajas-hub.dc1.lan
/home/pjalajas/dev/hub/integrations/alert
pjalajas
Removing service alert_642_04230405Z_alert
Removing service alert_642_04230405Z_alertdb
Removing service alert_642_04230405Z_cfssl
Removing network alert_642_04230405Z_default
TEST: A Docker host with at least 2GB of allocatable memory.
MemFree:          430960 kB
SwapFree:         259972 kB
              total        used        free      shared  buff/cache   available
Mem:             39          11           0           2          27          24
Swap:             1           1           0
TEST: Administrative access to the docker host machine.
sup-pjalajas-hub.dc1.lan
TODO: this is a doc BUG, needs a link or explanation:
- Before installing or upgrading Alert the desired persistent storage volumes must be created for Alert and needs to be either:
    - Node locked.
    - Backed by an NFS volume or a similar mechanism.

Downloading Alert orchestration files
--2021-04-23 00:09:22--  https://github.com/blackducksoftware/blackduck-alert/releases/download/6.4.2/blackduck-alert-6.4.2-deployment.zip
Resolving github.com (github.com)... 140.82.114.3
Connecting to github.com (github.com)|140.82.114.3|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://github-releases.githubusercontent.com/105032211/cce3a900-9b90-11eb-801e-eac4bb7ec89b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210423%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210423T040922Z&X-Amz-Expires=300&X-Amz-Signature=7feada49ead18b59ed5aca8bbcd67d1df07ae78213ba4b4ab5f5afaee121d7b2&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=105032211&response-content-disposition=attachment%3B%20filename%3Dblackduck-alert-6.4.2-deployment.zip&response-content-type=application%2Foctet-stream [following]
--2021-04-23 00:09:22--  https://github-releases.githubusercontent.com/105032211/cce3a900-9b90-11eb-801e-eac4bb7ec89b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210423%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210423T040922Z&X-Amz-Expires=300&X-Amz-Signature=7feada49ead18b59ed5aca8bbcd67d1df07ae78213ba4b4ab5f5afaee121d7b2&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=105032211&response-content-disposition=attachment%3B%20filename%3Dblackduck-alert-6.4.2-deployment.zip&response-content-type=application%2Foctet-stream
Resolving github-releases.githubusercontent.com (github-releases.githubusercontent.com)... 185.199.108.154, 185.199.110.154, 185.199.111.154, ...
Connecting to github-releases.githubusercontent.com (github-releases.githubusercontent.com)|185.199.108.154|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 53784 (53K) [application/octet-stream]
Saving to: ‘blackduck-alert-6.4.2-deployment.zip.9’

     0K .......... .......... .......... .......... .......... 95%  507K 0s
    50K ..                                                    100% 50.9M=0.1s

2021-04-23 00:09:23 (533 KB/s) - ‘blackduck-alert-6.4.2-deployment.zip.9’ saved [53784/53784]

Extracting the contents of the ZIP file.
Archive:  blackduck-alert-6.4.2-deployment.zip
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/hub/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/hub/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/hub/blackduck-alert.env
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/hub/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/hub/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/hub/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/docker-compose.local-overrides.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/README.md
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/standalone/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/standalone/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/external-db/standalone/blackduck-alert.env
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/docker-compose.local-overrides.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/README.md
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/docker-compose.yml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/blackduck-alert.env
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/Chart.yaml
   creating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/_helpers.tpl
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-cfssl.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-environ-configmap.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/postgres.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/postgres-config.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert-environ-secret.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/alert.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/templates/serviceaccount.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/synopsys-alert-6.4.2.tgz
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/values.yaml
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/DEVELOPER_README.md
  inflating: blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/helm/synopsys-alert/README.md
Installing Alert standalone, the files are located in the *standalone* sub-directory.
7603214    4 drwxr-xr-x   3 pjalajas users        4096 Apr 23 00:09 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment
7603226    4 drwxrwxr-x   3 pjalajas users        4096 Apr 23 00:09 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm
7606126    4 drwxrwxr-x   2 pjalajas users        4096 Apr 12 13:07 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone
7606128    8 -rw-rw-r--   1 pjalajas users        4940 Apr 12 13:07 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/blackduck-alert.env
7606127    4 -rw-------   1 pjalajas users        1842 Apr 12 13:07 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/standalone/docker-compose.yml
7606125   36 -rw-rw-r--   1 pjalajas users       36594 Apr 12 13:07 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/README.md
7606123    8 -rw-rw-r--   1 pjalajas users        8057 Apr 12 13:07 ./blackduck-alert-6.4.2-deployment/blackduck-alert-6.4.2-deployment/docker-swarm/docker-compose.local-overrides.yml
Creating a docker secret containing the encryption password for Alert.
4n68ich5wosftav1p6ppdrs47
j8iyzp6dik4g73k0xkfeixfl2
hmqgzrnvkgknnktnj43435ek4
44bvbs17qd2mbl9zye7dh1scw
Setting the required environment variable ALERT_HOSTNAME.
Creating network alert_642_04230409Z_default
Creating service alert_642_04230409Z_alert
Creating service alert_642_04230409Z_alertdb
Creating service alert_642_04230409Z_cfssl
In a minute or so, run these:


echo true | openssl s_client -connect sup-pjalajas-hub.dc1.lan:8443
curl --trace-ascii - --insecure https://sup-pjalajas-hub.dc1.lan8443/alert


Then open your browser to https://sup-pjalajas-hub.dc1.lan8443/alert and login with sysadmin / blackduck to continue the installation.


https://github.com/blackducksoftware/blackduck-alert/blob/6.4.2/deployment/docker-swarm/README.md











### Alert Logging Level Variable
#To change the logging level of Alert add the following environment variable to the deployment. 
#- Editing overrides file: 
    #```yaml
    #alert:
        #environment: 
           #- ALERT_LOGGING_LEVEL=DEBUG
    #```
#
#- Set the value to one of the following: 
    #- DEBUG
    #- ERROR
    #- INFO
    #- TRACE
    #- WARN

### Changing Memory Settings
If Alert should be using more memory than its default settings, then this section describes what must be changed in order to allocate more memory.

For this advanced setting, since there are more than just environment variables that need to be set, edit the `docker-compose.local-overrides.yml` file.

- Overrides File Changes.
    - Define the `ALERT_MAX_HEAP_SIZE` environment variable:
    ```yaml
        alert:
            environment:
                - ALERT_HOSTNAME=localhost
                - ALERT_MAX_HEAP_SIZE=<NEW_HEAP_SIZE>
    ```
    - Define the container memory limit. Add the deploy section to the alert service description.
    ```yaml
        alert:
            deploy:
                resources:
                    limits: {memory: <NEW_HEAP_SIZE + 256M>}
                    reservations: {memory: <NEW_HEAP_SIZE + 256M>}: 
    ```
    - Replace <NEW_HEAP_SIZE> with the heap size to be used.
    Note: 
        The ALERT_MAX_HEAP_SIZE and the container deploy.resources settings should not be exactly the same.  
        The container deploy.resources setting is the maximum memory allocated to the container.  
        Additional memory does not get allocated to it.  
        The maximum heap size in Java is the maximum size of the heap in the Java virtual machine (JVM), but the JVM also uses additional memory.  
        Therefore, the ALERT_MAX_HEAP_SIZE environment variable must be less than the amount defined in the mem_limit which is set for the container. 
        Synopsys recommends setting the deploy.resources using the following formula: ALERT_MAX_HEAP_SIZE + 256M.
        ```bash
            ALERT_MAX_HEAP_SIZE = 4096M
            limits = ALERT_MAX_HEAP_SIZE + 256M = 4352M
            reservations = ALERT_MAX_HEAP_SIZE + 256M = 4352M
        ```
                
Example: 
- Change the memory limit from 2G to 4G.
```yaml
    alert:
        environment:
            - ALERT_HOSTNAME=localhost
            - ALERT_MAX_HEAP_SIZE=4096M
        deploy:
            resources:
                limits: {memory: 4352M}
                reservations: {memory: 4352M}
```

Note: Work with your IT staff if necessary to verify the configured memory is available on the host machine.
