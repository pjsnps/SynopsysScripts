#!/usr/bin/bash
#SCRIPT: SnpsSigSup_BdGetOfflineImages.bash
#AUTHOR: pjalajas@synopsys.com et al.
#DATE: 2020-11-18
#VERSION: 2011190104Z TODO xargs
#LICENSE: SPDX Apache-2.0

#CREDIT: pkgimgs.sh Alex Sullivan July 23rd 2020 at 3:09 PM, from original work of sheeley@synopsys.com

#USAGE SnpsSigSup_BdGetOfflineImages.bash 2020.8.2

#TODO: multithread with xargs, pull and tar.

#Pull version images
version=$1 # command line first position

echo Getting list of images info...
if [ "$version" == '' ]
then
        echo No version specified, will download latest...
	imgs="$(curl --silent https://raw.githubusercontent.com/blackducksoftware/hub/master/docker-swarm/docker-compose.yml | grep image | awk {'print $2'})"
fi
if [ "$version" != '' ]
then
        echo Version $version specified, will download version $version...
	imgs="$(curl --silent https://raw.githubusercontent.com/blackducksoftware/hub/v$version/docker-swarm/docker-compose.yml | grep image | awk {'print $2'})" 
fi
if [ "$version" == '' ]
then
  version="$(echo "$imgs" | grep webapp | cut -d: -f2)"
  echo Latest version is $version
fi

echo
echo Pulling these images...
echo "${imgs}"
echo
echo "$imgs" | while read line ; do docker pull $line ; echo ; done # TODO xargs
#echo Pulled these images...
#docker image ls | grep "blackducksoftware/blackduck.*$version"
#echo
#wait


#A script to save all of the LATEST versions of the Black Duck Images on your VM. I suggest removing all images, and redownloading the latest files to be safe.
  

#Declare arrays
#declare -a image=(
#"authentication"
#"cfssl"
#"documentation"
#"jobrunner"
#"logstash"
#"nginx"
#"postgres"
#"registration"
#"scan"
#"webapp"
#"zookeeper"
#"upload-cache"
#)
#BAD breaks with image names with 2 - : declare -a image=($(echo "$imgs" | sed -re 's#^.*-#"#g' -e 's#:.*$#"#g' | xargs))
declare -a image=($(echo "$imgs" | sed -re 's#^.*/#"#g' -e 's#:.*$#"#g' | xargs))

#declare -a version=(
#$(cat imgs | grep 'authentication' | cut -d':' -f2)
#$(cat imgs | grep 'cfssl' | cut -d':' -f2)
#$(cat imgs | grep 'documentation' | cut -d':' -f2)
#$(cat imgs | grep 'jobrunner' | cut -d':' -f2)
#$(cat imgs | grep 'logstash' | cut -d':' -f2)
#$(cat imgs | grep 'nginx' | cut -d':' -f2)
#$(cat imgs | grep 'postgres' | cut -d':' -f2)
#$(cat imgs | grep 'registration' | cut -d':' -f2)
#$(cat imgs | grep 'scan' | cut -d':' -f2)
#$(cat imgs | grep 'webapp' | cut -d':' -f2)
#$(cat imgs | grep 'zookeeper' | cut -d':' -f2)
#$(cat imgs | grep 'upload-cache' | cut -d':' -f2)
#)
 

declare -a a_version=($(echo "$imgs" | sed -re 's#^.*:#"#g' -e 's#$#"#g' | xargs))

#echo a_version array: ${a_version[@]} 


echo -e "${image[@]}\n${a_version[@]}" | sed -re 's/blackduck-//g' |column -t
echo

#Make a new directory
#mkdir HubImages-${version[0]}
rm -rf BlackDuckImages-${version} 
mkdir BlackDuckImages-${version} 
  
#cd HubImages-${version[0]}
cd BlackDuckImages-${version}
#Save Images
echo Saving images...
counter=0
    for container in "${image[@]}"
        do
            for containerversion in "${a_version[$counter]}"
                do
                    echo "Saving Container: "$container" Version:" $containerversion
                    #docker image save -o $container.tar blackducksoftware/blackduck-$container:$containerversion
                    docker image save -o $container.tar blackducksoftware/$container:$containerversion  # TODO xargs
            done
        let counter=counter+1
    done
echo
cd ..
echo 'Archiving files...'
#Create Manageable archive
#tar -czvf HubImages-${version[0]}.tar.gz HubImages-${version[0]}
tar -czvf BlackDuckImages-${version}.tar.gz BlackDuckImages-${version}   # TODO xargs
echo
  
#Cleanup
echo 'Cleaning up...'
#rm -rf HubImages-${version[0]}
rm -rf BlackDuckImages-${version}
#rm imgs
  
#Success
echo
echo 'Successfully saved offline images for Black Duck version: '${version}
echo

#REFERENCE

#Push to sharepile:
# 1770  20201118T193304ESTWed date ; date --utc  ; hostname -f ; pwd ; whoami ; lftp -p 990 -u "ue22fd33eb,$(cat ~/.pj)" -e "mput ./BlackDuckImages-2020.* -O SNPS-BD/Support/HUB/OfflineImages ; quit ; " ftps://synopsyssf.sharefileftp.com
 #1771  20201118T194349ESTWed date ; date --utc  ; hostname -f ; pwd ; whoami ; lftp -p 990 -u "ue22fd33eb,$(cat ~/.pj)" -e "rels SNPS-BD/Support/HUB/OfflineImages ; quit ; " ftps://synopsyssf.sharefileftp.com

#To load:
#When the customer has the images, they will need to enter the extracted archive, which will contain all of the images saved as .tar files. A customer can load them all at once by using the command:
#ls | while read image; do docker load -i $image; done # xargs? 