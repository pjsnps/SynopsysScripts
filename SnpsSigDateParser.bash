#/usr/bin/bash
#
#$mloglinedatein :: 2020-08-13 00:00:36,411Z
#2020-08-12T20:00:36.411000000Z Wed


while read line ; do
  echo "input: $line"
  #$mloglinedatein :: 2020-08-13 00:01:36,564Z
  #mloglinedatein="$(echo "$loglinein" | grep -Po "^\[[a-z0-9]{12}\] 20[0-9]{2}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]{3}Z\[GMT\] ")"
     #mstring :: [d5c907168077] 2020-08-13 00:05:36,319Z[GMT] 
      #line="$(echo "$line" | cut -d\  -f2-)"
      line="$(echo "$line" | sed -re 's/Z\[GMT\]/Z/g')"
      line="$(echo "$line" | sed -re 's/,/./g')"
      echo "working: $line"
      echo -n "parsed: "
      date --utc +'%Y-%m-%dT%H:%M:%S.%NZ %a' -d "$line"
      #echo
done

