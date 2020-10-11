IFM2 is a somewhat feeble simple attempt at a poor-man's Individual File Matching using a customer-built Knowledge Base (see KB files herein). 

TODO: copy scripts I used to this git repo.  

Essentially: 
Build KB with like: find src/ -type f | xargs head -c 1024 | cksum | gzip -9 > kb_1024.out.gz
(TODO: see if can make faster with GNU parallel.)
Repeat similar on source code tree and grep kb .gz file(s) for matches.  

Example KB file contents, kb_1024.out.gz:

/bin/lslogins : 2041218741 1024
/bin/dpkg-scansources : 1071909643 1024
/bin/fc-cat : 696955885 1024
/bin/qemu-system-i386 : 3138043667 1024
/bin/mergecap : 1418748294 1024
/bin/qemu-sparc64 : 999254692 1024
/bin/base64 : 2725394728 1024



TODO:  test maybe:  find src/ -type f | xargs gzip -9 | head -c 1024 | cksum | gzip -9 > kb_1024.out.gz
That might give a bigger portion of the source file uniqueness into the same first 1024 bytes?
Else, maybe divide src files into, like quarters, then cat the head x-number of bytes of each of those quarters into cksum? Or like, first x bytes, last x bytes (add some middle bytes).
