#!/usr/bin/bash


SC_LPORT=40002 # socat listen port
socat tcp-listen:${SC_LPORT},reuseaddr,fork "exec:printf \'HTTP/1.1 200 OK\r\n\r\n\'"


exit
#REFERENCE

: '

socat tcp-listen:40002,reuseaddr,fork \
   "exec:printf \'HTTP/1.1 200 OK\r\n\r\n\'"

SC_LPORT=40002 # socat listen port
socat tcp-listen:${SC_LPORT},reuseaddr,fork "exec:printf \'HTTP/1.1 200 OK\r\n\r\n\'"

[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 4 |& less -inRF
== Info: About to connect() to 127.0.0.1 port 40002 (#0)
== Info:   Trying 127.0.0.1...
== Info: Connected to 127.0.0.1 (127.0.0.1) port 40002 (#0)
== Info: Server auth using Basic with user 'pjalajas@blackduckcloud.com'
=> Send header, 289 bytes (0x121)
0000: PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-a
0040: lert HTTP/1.1
004f: Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWN
008f: wZkQyQnVSNzNIVjV3VVkyNjg1OQ==
00ae: User-Agent: curl/7.29.0
00c7: Host: 127.0.0.1:40002
00de: Accept: */*
00eb: Content-Type: application/json
010b: Content-Length: 33
011f: 
=> Send data, 33 bytes (0x21)
0000:  { "topicName": "pj topicName" } 
== Info: upload completely sent off: 33 out of 33 bytes
<= Recv header, 17 bytes (0x11)
0000: HTTP/1.1 200 OK
HTTP/1.1 200 OK
== Info: no chunk, no close, no size. Assume close to signal end

<= Recv header, 2 bytes (0x2)
0000: 
<= Recv data, 0 bytes (0x0)
== Info: Closing connection 0


#socat tcp-listen:12345,reuseaddr,fork \
   #"exec:printf \'HTTP/1.0 200 OK\r\n\r\n\'"

'
