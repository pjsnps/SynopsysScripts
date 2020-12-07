#!/usr/bin/bash
#SCRIPT: SnpsSigSup_SocatServer.bash
#AUTHOR:  pjalajas@synopsys.com
#LICENSE: SPDX Apache-2.0
#SUPPORT: https://www.synopsys.com/software-integrity/support.html, https://community.synopsys.com/s/, Software-integrity-support@synopsys.com
#DATE:   2020-12-03
#VERSION: 2012040241Z pj add echo to socat server stdout

#USAGE: bash util/SnpsSigSup_SocatServer.bash 1

#NOTE: Make sure SC_LPORT is allowed in iptables on socat server host.


#CONFIG:

SC_LPORT=40002 # socat listen port, send your client to this port, like "curl http://<socathost>:$SC_LPORT"


case $1 in
  1)
    #Just echo 200 back to client, nothing on server side stdout
    socat tcp-listen:${SC_LPORT},reuseaddr,fork "exec:printf \'HTTP/1.1 200 OK\r\n\r\n\'"
    ;;
  2)
    #Echo client input back to client and on server side stdout
    socat -v -T0.05 tcp-l:${SC_LPORT},reuseaddr,fork system:"echo 'HTTP/1.1 200 OK'; echo 'Connection: close'; echo; cat"
   ;;
esac


exit


#REFERENCE
#https://github.com/craSH/socat/blob/master/EXAMPLES

: '

                                                                                                    
^C[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_SocatServer.bash 2
> 2020/12/03 21:55:34.402508  length=324 from=0 to=323
PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-alert HTTP/1.1\r
Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWNwZkQyQnVSNzNIVjV3VVkyNjg1OQ==\r
User-Agent: curl/7.29.0\r
Host: 10.1.65.171:40002\r
Accept: */*\r
Content-Type: application/json\r
Content-Length: 33\r
\r
 { "topicName": "pj topicName" } < 2020/12/03 21:55:34.404857  length=34 from=0 to=33
HTTP/1.1 200 OK
Connection: close
< 2020/12/03 21:55:34.404990  length=1 from=34 to=34

< 2020/12/03 21:55:34.405743  length=324 from=35 to=358
PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-alert HTTP/1.1\r
Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWNwZkQyQnVSNzNIVjV3VVkyNjg1OQ==\r
User-Agent: curl/7.29.0\r
Host: 10.1.65.171:40002\r
Accept: */*\r
Content-Type: application/json\r
Content-Length: 33\r
\r
 { "topicName": "pj topicName" } 
> 2020/12/03 21:56:38.143240  length=324 from=0 to=323
PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-alert HTTP/1.1\r
Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWNwZkQyQnVSNzNIVjV3VVkyNjg1OQ==\r
User-Agent: curl/7.29.0\r
Host: 10.1.65.171:40002\r
Accept: */*\r
Content-Type: application/json\r
Content-Length: 33\r
\r
 { "topicName": "pj topicName" } < 2020/12/03 21:56:38.145711  length=35 from=0 to=34
HTTP/1.1 200 OK
Connection: close

< 2020/12/03 21:56:38.146616  length=324 from=35 to=358
PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-alert HTTP/1.1\r
Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWNwZkQyQnVSNzNIVjV3VVkyNjg1OQ==\r
User-Agent: curl/7.29.0\r
Host: 10.1.65.171:40002\r
Accept: */*\r
Content-Type: application/json\r
Content-Length: 33\r
\r
 { "topicName": "pj topicName" } 

Client side:
[pjalajas@sup-pjalajas-hub SynopsysScripts]$ bash util/SnpsSigSup_TestJira.bash 4 |& cat 
== Info: About to connect() to 10.1.65.171 port 40002 (#0)
== Info:   Trying 10.1.65.171...
== Info: Connected to 10.1.65.171 (10.1.65.171) port 40002 (#0)
== Info: Server auth using Basic with user 'pjalajas@blackduckcloud.com'
=> Send header, 291 bytes (0x123)
0000: PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-a
0040: lert HTTP/1.1
004f: Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWN
008f: wZkQyQnVSNzNIVjV3VVkyNjg1OQ==
00ae: User-Agent: curl/7.29.0
00c7: Host: 10.1.65.171:40002
00e0: Accept: */*
00ed: Content-Type: application/json
010d: Content-Length: 33
0121: 
=> Send data, 33 bytes (0x21)
0000:  { "topicName": "pj topicName" } 
== Info: upload completely sent off: 33 out of 33 bytes
<= Recv header, 16 bytes (0x10)
0000: HTTP/1.1 200 OK.
HTTP/1.1 200 OK
<= Recv header, 18 bytes (0x12)
0000: Connection: close.
Connection: close

<= Recv header, 1 bytes (0x1)
0000: .
<= Recv data, 324 bytes (0x144)
0000: PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-a
0040: lert HTTP/1.1
004f: Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWN
008f: wZkQyQnVSNzNIVjV3VVkyNjg1OQ==
00ae: User-Agent: curl/7.29.0
00c7: Host: 10.1.65.171:40002
00e0: Accept: */*
00ed: Content-Type: application/json
010d: Content-Length: 33
0121: 
0123:  { "topicName": "pj topicName" } 
PUT /rest/api/2/issue/AT-1/properties/com-synopsys-integration-alert HTTP/1.1
Authorization: Basic cGphbGFqYXNAYmxhY2tkdWNrY2xvdWQuY29tOjVzRWNwZkQyQnVSNzNIVjV3VVkyNjg1OQ==
User-Agent: curl/7.29.0
Host: 10.1.65.171:40002
Accept: */*
Content-Type: application/json
Content-Length: 33

 { "topicName": "pj topicName" } == Info: Closing connection 0




'

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
