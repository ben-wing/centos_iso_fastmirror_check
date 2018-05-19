#!/bin/bash

#awk -F "/" '{print $3}' ${1} | xargs -n 1 ping -c 3 | tee iso_pings.out
awk -F "/" '{
print $3, $1"//"$3, $0;
}' ${1} > iso_url_head.lst

count=1
while read urls;
do
  declare -a a="(${urls})";
  echo domain-${a[0]}
 # echo root=${a[1]}
 # echo full=${a[2]}
  robots_file="iso_robots/${a[0]}--robots.txt"
  curl -I -X HEAD ${a[1]}/robots.txt | tee ${robots_file}.HEAD | egrep "^HTTP" | grep 200 > /dev/null
  if [[ $? -eq 0 ]]; then 
    curl ${a[1]}/robots.txt > $robots_file  
    echo robots.txt is a 200
  fi
  unset a
  ((count++))
  ##if [[ $count -eq 3 ]]; then
    ##exit
  ##fi
done < iso_url_head.lst

exit

