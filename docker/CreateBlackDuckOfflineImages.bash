#!/usr/bin/env bash
#https://sig-confluence.internal.synopsys.com/display/SUPPORT/How+To+Create+and+Share+Blackduck+Offline+Images
#Dashboard Customer Support Home Support Processes
#How To Create and Share Blackduck Offline Images
#Created by Sean Heeley, last modified on Mar 26, 2020
#A script to save all of the LATEST versions of the Black Duck Images on your VM. I suggest removing all images, and redownloading the latest files to be safe.
#VERSION:  2006262211Z

#Presumes images tagged. 
#Presumes authenticaion container has correct version? 

#Script hacked upon by pjalajas@synopsys.com May 2020:
#LICENSE: SPDX Apache-2.0
# PJ: very aggressive, use only a your empty test server:
#  docker stack ls
#  docker stack rm hub_2020-4-1
#  docker system prune --all
#  docker images prune --all
#  wget https://github.com/blackducksoftware/hub/archive/v2020.6.0.tar.gz
#  tar xf v2020.6.0.tar.gz
#  date ; hostname ; pwd ; whoami ; docker stack deploy      -c /home/pjalajas/dev/hub/hub-2020.4.1/docker-swarm/docker-compose.yml  hub_2020-4-1_a
#  watch docker ps
#CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS                        PORTS
                 #NAMES
#141c45f755b7        blackducksoftware/blackduck-nginx:1.0.25              "docker-entrypoint.sh"   2 minutes ago       Up About a minute (healthy)   80/tcp
                 #hub_2020-6-0_webserver.1.tll5fp7oeum3gf1jbnf30w8q7
#b1f062f3efdb        blackducksoftware/blackduck-logstash:1.0.6            "/usr/local/bin/dock…"   5 minutes ago       Up 5 minutes (healthy)        4560/tcp, 5044
#/tcp, 9600/tcp   hub_2020-6-0_logstash.1.f3mloqbtio0bxwztyghqwm6cj
#a24d488775cb        blackducksoftware/blackduck-documentation:2020.6.0    "docker-entrypoint.sh"   5 minutes ago       Up 5 minutes (healthy)
                 #hub_2020-6-0_documentation.1.rcus8nns8x5kvv58j0wyvkxuf
#b70c87f6db20        blackducksoftware/blackduck-webapp:2020.6.0           "docker-entrypoint.sh"   5 minutes ago       Up 5 minutes (healthy)
                 #hub_2020-6-0_webapp.1.utlckdmlqwmjunx3mnylulooq
#c57a9123246e        blackducksoftware/blackduck-postgres:1.0.13           "/hub-database.sh po…"   5 minutes ago       Up 5 minutes (healthy)        5432/tcp
                 #hub_2020-6-0_postgres.1.t3xor66jxfeckj7div0nm6f4e
#f0d0e10abba3        blackducksoftware/blackduck-upload-cache:1.0.14       "/opt/blackduck/hub/…"   6 minutes ago       Up 5 minutes (healthy)        8086/tcp, 9443
#/tcp             hub_2020-6-0_uploadcache.1.o016au92kfkpucztq6hgd1zzm
#2798f3b3f0d7        blackducksoftware/blackduck-authentication:2020.6.0   "docker-entrypoint.sh"   6 minutes ago       Up 5 minutes (healthy)
                 #hub_2020-6-0_authentication.1.2vtdoiuub683fpndwwt87t76h
#a67812558b70        blackducksoftware/blackduck-jobrunner:2020.6.0        "docker-entrypoint.s…"   6 minutes ago       Up 6 minutes (healthy)
                 #hub_2020-6-0_jobrunner.1.j6akatyk1xz083x3mmnzcuqxm
#18cce52cbc49        blackducksoftware/blackduck-cfssl:1.0.1               "docker-entrypoint.sh"   6 minutes ago       Up 6 minutes (healthy)        8888/tcp
                 #hub_2020-6-0_cfssl.1.ykv6qtvmskkxlz15xfc1bl2o0
#a7e6c3e391ca        blackducksoftware/blackduck-scan:2020.6.0             "docker-entrypoint.sh"   6 minutes ago       Up 6 minutes (healthy)
                 #hub_2020-6-0_scan.1.kob73v0orwlbzkk4wu40y8g25
#a0689ed95d54        blackducksoftware/blackduck-registration:2020.6.0     "docker-entrypoint.sh"   7 minutes ago       Up 6 minutes (healthy)
                 #hub_2020-6-0_registration.1.u235x40yqg13lvmwkzhduryhp

#  TODO:  Do you have to enter registration key?  
#  bash ./CreateBlackDuckOfflineImages.bash |& cat -A |& tee -a /tmp/CreateBlackDuckOfflineImages.bash_$(hostname -f)_$(date --utc +%Y%m%d_%H%M%SZ_%a).out |& less -inRF
  
#From 2020.4.1 Release Notes, under Version 2020.4.0
# Container versions
#n blackducksoftware/blackduck-postgres:1.0.13
#n blackducksoftware/blackduck-authentication:2020.4.0
#n blackducksoftware/blackduck-webapp:2020.4.0
#n blackducksoftware/blackduck-scan:2020.4.0
#n blackducksoftware/blackduck-jobrunner:2020.4.0
#n blackducksoftware/blackduck-cfssl:1.0.1
#n blackducksoftware/blackduck-logstash:1.0.6
#n blackducksoftware/blackduck-registration:2020.4.0
#n blackducksoftware/blackduck-nginx:1.0.23
#n blackducksoftware/blackduck-documentation:2020.4.0
#n blackducksoftware/blackduck-upload-cache:1.0.13
#n sigsynopsys/bdba-worker:2020.03
#n blackducksoftware/rabbitmq:1.0.3



#Declare arrays
declare -a image=(
"authentication"
"cfssl"
"documentation"
"jobrunner"
"logstash"
"nginx"
"postgres"
"registration"
"scan"
"webapp"
"upload-cache"
)
  
#declare -a version=(
#$(docker image ls | grep 'authentication' | awk '{print $2}')
#$(docker image ls | grep 'cfssl' | awk '{print $2}')
#$(docker image ls | grep 'documentation' | awk '{print $2}')
#$(docker image ls | grep 'jobrunner' | awk '{print $2}')
#$(docker image ls | grep 'logstash' | awk '{print $2}')
#$(docker image ls | grep 'nginx' | awk '{print $2}')
#$(docker image ls | grep 'postgres' | awk '{print $2}')
#$(docker image ls | grep 'registration' | awk '{print $2}')
#$(docker image ls | grep 'scan' | awk '{print $2}')
#$(docker image ls | grep 'webapp' | awk '{print $2}')
#$(docker image ls | grep 'upload-cache' | awk '{print $2}')
#)

#Because if images don't have versions...(TODO: get from docker image inspect)
declare -a version=(
$(docker container ls | grep authentication | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep cfssl | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep documentation | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep jobrunner | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep logstash | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep nginx | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep postgres | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep registration | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep scan | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep webapp | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
$(docker container ls | grep upload-cache | tr -s \  | cut -d\  -f1-2 | cut -d\: -f2)
)

#echo ${version[@]}
#echo ${version[*]}
  
#Make a new directory
rm -rf HubImages-${version[0]}
mkdir -p HubImages-${version[0]}
cd HubImages-${version[0]}

#Save Images
counter=0
    for container in "${image[@]}"
        do
            for containerversion in "${version[$counter]}"
                do
                    #docker image tag 2be94dde1263 blackducksoftware/blackduck-authentication:2020.4.1       # no ":" implies "latest" 
                    docker container ls | grep ${container} 
                    docker image ls | grep ${container} 
                    imageid=$(docker image ls | grep ${container} | tr -s ' ' | cut -d\  -f 3)
                         #REPOSITORY                                   TAG                 IMAGE ID            CREATED             SIZE
                         #blackducksoftware/blackduck-authentication   2020.4.1            2be94dde1263        3 days ago          305MB
                         #blackducksoftware/blackduck-nginx            <none>              a28acd47fd3a        2 weeks ago         54.4MB
                    echo "Forcing adding tags to \$imageid : $imageid, \$containerversion : ${containerversion}, \$container : ${container}, \$version : ${version[$counter]}, \$containerid : ${containerid}, if needed ... " # TODO test first
                    docker image tag ${imageid} blackducksoftware/blackduck-${container}:${containerversion}
                    echo "Saving Container: "$container" Version:" $containerversion
                    docker image save -o $container.tar blackducksoftware/blackduck-$container:$containerversion
            done
        let counter=counter+1
    done
  
#Create Manageable archive
cd ..
echo 'Archiving files...'
tar -czvf HubImages-${version[0]}.tar.gz HubImages-${version[0]}
  
#Cleanup
echo 'Cleaning up...'
rm -rf HubImages-${version[0]}
  
#Success
echo 'Successfully saved Black Duck version: '${version[0]}
echo


exit

#REFERENCE
