#!/usb/bin/bash
#GetJsJam2.bash
#AUTHOR: pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#DATE:  2020-09-01
#VERSION: 2009021312Z # add github trending, change input file name

#PURPOSE:  Retrieve a large number of version of a large number of open-source for stress testing Synopsys Black Duck (Hub) or other source code scanners.

#set -x
#cat 50-popular-javascript-open-source-projects-on-github-in-2018.out | \
cat javascript-github-projects.out | \
head -n 5000 | \
while read url
do
 
  echo processing $url # like https://github.com/1j01/jspaint

  #first, get the master zip; that covers projects that have no releases
  #https://github.com/1j01/jspaint
  #https://codeload.github.com/1j01/jspaint/zip/master/jspaint-master.zip
  mtail=$(echo $url | cut -d/ -f4,5)
  echo $mtail # like 1j01/jspaint
  curl -k -s -C - --create-dirs -o ./github.com/${mtail}/zip/master/master.zip "https://codeload.github.com/${mtail}/zip/master" # no trailing slashes, downloads zip

  #second, get a page of releases .zip and .gz files, and link to next "after" page of more releases 
  #curl -k -s "${url}/releases" | cat -A | tr ' ,<>;()"#'  '\n' | grep -e "/archive/" -e "after=" | grep -v -e "bit.ly" | sed -re 's#%3A%2F%2F#://#g' -e 's#/$##g' | sort -u 
  # 2344  15/07/20 22:32:01: wget --mirror --no-parent  --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
  #wget --mirror --no-parent --continue --reject sha1,sha512,md5,gif,txt,asc,html,*html*,readme 'https://archive.apache.org/dist/tomcat/'
  #works: wget --mirror --no-parent --continue --accept zip,gz "${url}/releases" # can't no-clobber
  #The Apache Commons Compress library defines an API for working with ar, cpio, Unix dump, tar, zip, gzip, XZ, Pack200, bzip2, 7z, arj, lzma, snappy, DEFLATE, lz4, Brotli, Zstandard, DEFLATE64 and Z files.
  #works: wget --no-verbose --mirror --no-parent --continue --accept zip,gz,ar,tar,7z,bzip,bzip2,xz,dmg,egg,rar,gzip,Z,cpio,jar,war,ear "${url}/releases" # can't no-clobber
  wget --quiet --mirror --no-parent --continue --accept zip,gz,ar,tar,7z,bzip,bzip2,xz,dmg,egg,rar,gzip,Z,cpio,jar,war,ear "${url}/releases" # can't no-clobber
  sleep 10s 
done


exit
#TODO: use git to download?  no, want the archives for storage considerations?

#REFERENCE
./github.com/521dimensions
./github.com/521dimensions/amplitudejs
./github.com/521dimensions/amplitudejs/releases
./github.com/521dimensions/amplitudejs/releases/download
./github.com/521dimensions/amplitudejs/releases/download/v4.0.0
./github.com/521dimensions/amplitudejs/releases/download/v4.0.0/v4.0.0.zip
./github.com/521dimensions/amplitudejs/archive
./github.com/521dimensions/amplitudejs/archive/v4.1.0.zip
./github.com/521dimensions/amplitudejs/archive/v3.3.0.zip
./github.com/521dimensions/amplitudejs/archive/v5.0.1.tar.gz

if no releases: 
https://codeload.github.com/1j01/jspaint/zip/master/jspaint-master.zip

                                                                      
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
