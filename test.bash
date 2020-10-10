#/usr/bin/bash
showword() {
  echo $1
}

export -f showword
echo This is a sample message | xargs -d' ' -t -n1 -P2 bash -c 'showword "$@"' _
