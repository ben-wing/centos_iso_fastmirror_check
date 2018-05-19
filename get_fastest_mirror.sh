#!/bin/bash

# 1593  2018-03-12 14:28:19 awk -F "/" '{print $3}' centos.mirrors | xargs -n 1 ping -c 3 | tee centos.mirrors.response
# 1659  2018-03-12 14:57:11 awk -F '=' '($1 ~ /^rtt/) {split($2, times, "/"); print times[2];}' centos.mirrors.response | sort -nr

#mirror_list
# from the centos infrastructure there is an implication that not all mirrors include the ISOs (see URL below)
# from testing with cURL HEAD check of 200 codes, i found that 123 of 130 mirrors include the ISO
# (I did not actually attempt to download from all 130 mirrors)
# my inital testing was to use get_ping_performance to compare the 2 lists for the best performance.
# turns out (as you might hope) the full mirror list actually includes all isoredirect mirrors, so this is skipped

# specific ISO list?
#wget http://isoredirect.centos.org/centos/7/isos/x86_64/ -O isoredirect.index.html
#python get_iso_urls.py isoredirect.index.html > iso_url.lst
#awk -F "/" '{ print $3, $1"//"$3, $0; }' ${1} > iso_url_head.lst
#./get_ping_performance.sh iso



# csv, might not have ISOs
#wget https://www.centos.org/download/full-mirrorlist.csv
#sed -n '/^"Region/p; /^"US"/p' full-mirrorlist.csv > us-mirrorlist.csv
sed -n '/^"US"/p' full-mirrorlist.csv > us-mirrorlist.csv
awk -F '","' '{print $5"7/isos/x86_64/"}' us-mirrorlist.csv > mirror_unvalidated_url.lst
while read url
do
  #echo $url
  continue
  curl -s -I -X HEAD $url | egrep "^HTTP" | grep 200 > /dev/null
  if [[ $? -eq 0 ]]; then
    #echo success
    #TODO rebuild this URL from logic at the end of get_ping_performance.sh
    #TODO add as aditional curlping test?
    curl -s -I -X HEAD ${url}CentOS-7-x86_64-Minimal-1804.iso | egrep "^HTTP" | grep 200 > /dev/null
    if [[ $? -eq 0 ]]; then
      #echo validated
      echo $url >> mirror_url.lst
    fi
  fi
done < mirror_url.lst

awk -F "/" '{ print $3, $1"//"$3, $0; }' mirror_url.lst  > mirror_url_head.lst

./get_ping_performance.sh mirror
