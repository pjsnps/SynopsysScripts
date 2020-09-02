#!/usb/bin/bash
#GetJsJam2.bash
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#DATE:  2020-09-01
#VERSION: 2009022148Z
#CHANGELOG:  pj add some accept exts, order them.

#PURPOSE:  Retrieve a large number of versions of a large number of open-source projects, for stress-testing Synopsys Black Duck (Hub) or other source code scanners.

#DESCRIPTION:  Note, these are popular (starred, trending), so should have much code-reuse (good for stress testing, maybe good for vuln counts, but haven't seen that yet in testing).  Uses timeout to limit size of single download or number of downloads per project. 

#USAGE: First, populate input file with urls, like maybe with:
# [pjalajas@sup-pjalajas-hub jsjam2]$ for mfilter in stars forks updated ; do wget -O - "https://github.com/topics/javascript?o=desc&s=${mfilter}" |& tr '"<>= ' '\n' |& grep -v -e "/contribute$" -e "/issues" -e "/pulls" -e "^/stargazers/" -e "^/topics/" -e "^/about/" -e "^/site/" -e "^/sponsors/" |& grep "^\(/[a-zA-Z0-9]\+/[a-zA-Z0-9]\+\)" | head -n 1000 |& sort -u | while read line ; do echo "https://github.com${line}" ; done >> javascript-github-projects.out ; done
#Then run this with, like bash GetJsJam2.bash

#TODO:
#Comment on differences between scanning archives, vs expanding them first.  
#
# 1149  20200902T091218EDTWed wget -O - 'https://github.com/topics/javascript?o=desc&s=stars' |& tr '"<>= ' '\n' |& grep -v -e "/contribute$" -e "/issues" -e "/pulls" -e "^/stargazers/" -e "^/topics/" -e "^/about/"  -e "^/site/" -e "^/sponsors/" |& grep "^\(/[a-zA-Z0-9]\+/[a-zA-Z0-9]\+\)" | head -n 1000 |& sort -u | while read line ; do echo "https://github.com${line}" ; done >> javascript-github-projects.out 
#https://github.com/topics/javascript?l=javascript&o=desc&s=stars
#https://github.com/topics/javascript?l=javascript&o=desc&s=forks
#https://github.com/topics/javascript?l=javascript&o=desc&s=updated
#
#LIMIT DOWNLOAD SIZE: If you want to use wget, here is a way to test the size of the file without downloading: wget --spider $URL 2>&1 | awk '/Length/ {print $2}' where $URL is the URL of the file you want to download, of course.  So you can condition your script based on the output. such as: { [ $(wget --spider $URL 2>&1 | awk '/Length/ {print $2}') -lt 20971520 ] && wget $URL; } || echo file to big for limiting the download size to 20 MB.  (the code is ugly, for informational purposes only).
#No need, got enough already.  add Next/More pages from https://github.com/topics/javascript?o=desc&s=stars
#No need, got enough already.  add Trending to get new code: https://github.com/trending/javascript?since=monthly
#No need, got enough already.  add https://hackernoon.com/githubs-top-100-most-valuable-repositories-out-of-96-million-bb48caa9eb0b

#Summary of status: 
#[pjalajas@sup-pjalajas-hub jsjam2]$ date ; date --utc ; hostname -f ; find /home/pjalajas/dev/hub/test/projects/jsjam2/code -type f | wc -l
#Wed Sep  2 11:30:03 EDT 2020
#Wed Sep  2 15:30:03 UTC 2020
#sup-pjalajas-hub.dc1.lan
#463
#[pjalajas@sup-pjalajas-hub jsjam2]$ date ; date --utc ; hostname -f ; du -sh /home/pjalajas/dev/hub/test/projects/jsjam2/code
#Wed Sep  2 11:30:34 EDT 2020
#Wed Sep  2 15:30:34 UTC 2020
#sup-pjalajas-hub.dc1.lan
#8.1G    /home/pjalajas/dev/hub/test/projects/jsjam2/code

#CONFIG

#set -x
#cat 50-popular-javascript-open-source-projects-on-github-in-2018.out | \
INPUTFILE=javascript-github-projects.out
OUTPUTDIR="/home/pjalajas/dev/hub/test/projects/jsjam2/code" # no trailing slash
SLEEP=10s # no space before unit
HEADCOUNT=1000 # number of github projects to process (many gz versions per project may be downloaded)

#MAIN

#Use grep -v to remove huge or otherwise undesired files
#cat javascript-github-projects.out | \
cat "${INPUTFILE}" | \
  grep -v -e "/electron/" | \
  sort -u | \
  sort -R | \
  head -n $HEADCOUNT | \
while read url
do
 
  echo
  echo processing $url # like https://github.com/1j01/jspaint

  mtail=$(echo $url | cut -d/ -f4,5)
  #echo $mtail # like 1j01/jspaint
  #https://github.com/1j01/jspaint


  #first, get the master zip; that covers projects that have no releases
  #https://codeload.github.com/1j01/jspaint/zip/master/jspaint-master.zip
  #not needed, get enough with wget below:  curl -k -s -C - --create-dirs -o ${OUTPUTDIR}/github.com/${mtail}/zip/master/master.zip "https://codeload.github.com/${mtail}/zip/master" # no trailing slashes, downloads zip
  timeout 10s curl -k -s -C - --create-dirs -o ${OUTPUTDIR}/github.com/${mtail}/zip/master/master.zip "https://codeload.github.com/${mtail}/zip/master" # no trailing slashes, downloads zip

  #second, get a page of releases .zip and .gz files, and link to next "after" page of more releases 
  #curl -k -s "${url}/releases" | cat -A | tr ' ,<>;()"#'  '\n' | grep -e "/archive/" -e "after=" | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | sort -u 
  # 2344  15/07/20 22:32:01: wget --mirror --no-parent  --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
  #No need to limit project archives from a single project because of release download page pagination limits it to about 10 recent versions.
  timeout 60s wget --directory-prefix=${OUTPUTDIR} --no-verbose --mirror --no-parent --continue --accept gz "${url}/releases" # can't no-clobber

  #give it a reset...try to avoid getting blocked
  
  echo
  echo sleeping $SLEEP
  echo
  sleep $SLEEP 

done |& while read line ; do echo "$(date --utc +%Y%m%dT%H:%M:%SZ\ %a) : $line" ; done


exit
#TODO: use git to download?  no, want the archives for storage considerations?

#REFERENCE



[pjalajas@sup-pjalajas-hub jsjam2]$ date ; date --utc ; hostname -f ; pwd ; whoami ; find /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/ -type f -iname "a*" | xargs du -shc                                                                                                                                                                                                                 
Wed Sep  2 10:20:23 EDT 2020
Wed Sep  2 14:20:23 UTC 2020
sup-pjalajas-hub.dc1.lan
/home/pjalajas/dev/git/SynopsysScripts/jsjam2
pjalajas
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0/atom-amd64.tar.gz
169M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0/atom-mac-symbols.zip
174M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0/atom-x64-windows.zip
182M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0-beta0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0-beta0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0-beta0/atom-mac-symbols.zip
176M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0-beta0/atom-x64-windows.zip
184M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0-beta0/atom-mac.zip
174M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.46.0/atom-amd64.tar.gz
185M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.46.0/atom-windows.zip
212K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.46.0/atom-mac-symbols.zip
193M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.46.0/atom-x64-windows.zip
181M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.46.0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0-beta0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0-beta0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0-beta0/atom-mac-symbols.zip
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0-beta0/atom-x64-windows.zip
183M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0-beta0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0/atom-mac-symbols.zip
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0/atom-x64-windows.zip
183M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0-beta0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0-beta0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0-beta0/atom-mac-symbols.zip
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0-beta0/atom-x64-windows.zip
183M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.48.0-beta0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.51.0-beta0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.51.0-beta0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.51.0-beta0/atom-mac-symbols.zip
176M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.51.0-beta0/atom-x64-windows.zip
184M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.51.0-beta0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0/atom-mac-symbols.zip
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0/atom-x64-windows.zip
183M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.49.0/atom-mac.zip
177M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0/atom-amd64.tar.gz
170M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0/atom-mac-symbols.zip
176M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0/atom-x64-windows.zip
183M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.50.0/atom-mac.zip
175M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0-beta0/atom-amd64.tar.gz
168M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0-beta0/atom-windows.zip
192K    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0-beta0/atom-mac-symbols.zip
174M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0-beta0/atom-x64-windows.zip
182M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/atom/atom/releases/download/v1.47.0-beta0/atom-mac.zip
149M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/SeleniumHQ/selenium/archive/atoms-20181002.tar.gz
153M    /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/SeleniumHQ/selenium/archive/atoms-20181002.zip
7.2G    total



[pjalajas@sup-pjalajas-hub jsjam2]$ date ; date --utc ; hostname -f ; pwd ; whoami ; du -sh /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/                                                                                                                                                                                                                                                   
Wed Sep  2 10:18:26 EDT 2020
Wed Sep  2 14:18:26 UTC 2020
sup-pjalajas-hub.dc1.lan
/home/pjalajas/dev/git/SynopsysScripts/jsjam2
pjalajas
28G     /home/pjalajas/dev/hub/test/projects/jsjam2/code/github.com/

[pjalajas@sup-pjalajas-hub dev]$ curl -k -s https://github.com/facebook/react/releases | cat -A | tr ' ,<>;()"#'  '\n' | grep -e "/archive/" -e "after=" | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | sort -u 
/facebook/react/archive/status.tar.gz
/facebook/react/archive/status.zip
/facebook/react/archive/v0.0.0-d7382b6c4.tar.gz
/facebook/react/archive/v0.0.0-d7382b6c4.zip
/facebook/react/archive/v0.0.0-experimental-8b155d261.tar.gz
/facebook/react/archive/v0.0.0-experimental-8b155d261.zip
/facebook/react/archive/v0.0.0-experimental-aae83a4b9.tar.gz
/facebook/react/archive/v0.0.0-experimental-aae83a4b9.zip
/facebook/react/archive/v0.0.0-experimental-d7382b6c4.tar.gz
/facebook/react/archive/v0.0.0-experimental-d7382b6c4.zip
/facebook/react/archive/v16.10.2.tar.gz
/facebook/react/archive/v16.10.2.zip
/facebook/react/archive/v16.11.0.tar.gz
/facebook/react/archive/v16.11.0.zip
/facebook/react/archive/v16.12.0.tar.gz
/facebook/react/archive/v16.12.0.zip
/facebook/react/archive/v16.13.0.tar.gz
/facebook/react/archive/v16.13.0.zip
/facebook/react/archive/v16.13.1.tar.gz
/facebook/react/archive/v16.13.1.zip
https://github.com/facebook/react/releases?after=v16.10.2



  <div data-pjax class="paginate-container">
    <div class="pagination"><span class="disabled">Previous</span><a rel="nofollow" href="https://github.com/facebook/react/releases?after=v16.10.2">Next</a></div>
  </div>

[pjalajas@sup-pjalajas-hub dev]$ curl -k -s https://github.com/facebook/react/releases | cat -A | tr ' ,<>;=()"#'  '\n' | grep "/archive/" | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | sort -u 
/facebook/react/archive/status.tar.gz
/facebook/react/archive/status.zip
/facebook/react/archive/v0.0.0-d7382b6c4.tar.gz
/facebook/react/archive/v0.0.0-d7382b6c4.zip
/facebook/react/archive/v0.0.0-experimental-8b155d261.tar.gz
/facebook/react/archive/v0.0.0-experimental-8b155d261.zip
/facebook/react/archive/v0.0.0-experimental-aae83a4b9.tar.gz
/facebook/react/archive/v0.0.0-experimental-aae83a4b9.zip
/facebook/react/archive/v0.0.0-experimental-d7382b6c4.tar.gz
/facebook/react/archive/v0.0.0-experimental-d7382b6c4.zip
/facebook/react/archive/v16.10.2.tar.gz
/facebook/react/archive/v16.10.2.zip
/facebook/react/archive/v16.11.0.tar.gz
/facebook/react/archive/v16.11.0.zip
/facebook/react/archive/v16.12.0.tar.gz
/facebook/react/archive/v16.12.0.zip
/facebook/react/archive/v16.13.0.tar.gz
/facebook/react/archive/v16.13.0.zip
/facebook/react/archive/v16.13.1.tar.gz
/facebook/react/archive/v16.13.1.zip


https://github.com/facebook/react/archive/v16.13.1.zip
https://github.com/facebook/react/archive/v16.13.1.tar.gz

[pjalajas@sup-pjalajas-hub dev]$ curl -k -s https://hackernoon.com/50-popular-javascript-open-source-projects-on-github-in-2018-469c11b48b8d | cat -A | tr ' ,<>;=()"#'  '\n' | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | grep 'https://github.com/' | head -n 100 | sort -u | wc -l
51

[pjalajas@sup-pjalajas-hub dev]$ vi GetJsJam2.bash
[pjalajas@sup-pjalajas-hub dev]$ curl -k -s https://hackernoon.com/50-popular-javascript-open-source-projects-on-github-in-2018-469c11b48b8d | cat -A | tr ' ,<>;=()"#'  '\n' | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | grep 'https://github.com/' | head -n 100 | sort -u > 50-popular-javascript-open-source-projects-on-github-in-2018.out
[pjalajas@sup-pjalajas-hub dev]$ wc -l 50-popular-javascript-open-source-projects-on-github-in-2018.out 
51 50-popular-javascript-open-source-projects-on-github-in-2018.out


https://github.com/1j01/jspaint
https://github.com/521dimensions/amplitudejs
https://github.com/ai/nanoid
https://github.com/antvis/g2
https://github.com/ApoorvSaxena/lozad.js
https://github.com/bfirsh/jsnes
https://github.com/buttercup/buttercup-desktop
https://github.com/Canner/slate-md-editor
https://github.com/captbaritone/webamp
https://github.com/d3/d3
https://github.com/developit/greenlet
https://github.com/developit/workerize
https://github.com/drcmda/react-spring
https://github.com/facebook/prepack
https://github.com/facebook/react
https://github.com/glidejs/glide
https://github.com/GoogleChromeLabs/jsvu
https://github.com/GoogleChrome/puppeteer
https://github.com/GoogleChrome/workbox
https://github.com/ianstormtaylor/superstruct
https://github.com/intoli/remote-browser
https://github.com/jeromeetienne/AR.js
https://github.com/marktext/marktext
https://github.com/Microsoft/vscode
https://github.com/moment/luxon
https://github.com/neovim/neovim
https://github.com/nodejs/node
https://github.com/nuxt/consola
https://github.com/Okazari/Rythm.js
https://github.com/onivim/oni
https://github.com/parcel-bundler/parcel
https://github.com/Popmotion/popmotion
https://github.com/prettier/prettier
https://github.com/pshihn/rough
https://github.com/reactioncommerce/reaction
https://github.com/russellgoldenberg/scrollama
https://github.com/SeleniumHQ/selenium
https://github.com/SheetJS/js-xlsx
https://github.com/Shopify/draggable
https://github.com/sigalor/whatsapp-web-reveng
https://github.com/stimulusjs/stimulus
https://github.com/tensorflow/tfjs-core
https://github.com/Tonejs/Tone.js
https://github.com/uber/luma.gl
https://github.com/vuejs/vue
https://github.com/vuejs/vuepress
https://github.com/wallabyjs/quokka
https://github.com/webpackmonitor/webpackmonitor
https://github.com/withspectrum/spectrum
https://github.com/Yoctol/bottender
https://github.com/zouhir/jarvis
