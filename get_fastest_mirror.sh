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
#optional
#./get_iso_robots.sh ?
#./get_ping_performance.sh iso

function usage() {
  echo "Usage: $0 country ISO"
  echo '  country should be one of the "Region" available within full-mirrorlist.csv'
  echo '  ISO is one of the types of ISOs available "Minimal, DVD, Everything, etc.'
}


if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

country=$1
ISO=$2
case $ISO in
  Minimal|Everything|DVD|LiveGNOME|LiveKDE|NetInstall)
    true
    ;;
  *)
    usage
    echo "Unknown ISO name - $ISO"
    exit 1
esac
  
# csv, might not have ISOs
wget -q https://www.centos.org/download/full-mirrorlist.csv -O full-mirrorlist.csv
egrep "^\"$country\"" full-mirrorlist.csv > us-mirrorlist.csv
if [[ $( wc -l us-mirrorlist.csv | cut -d ' ' -f 1 ) -eq 0 ]]; then
  usage
  echo "No country/region found - $country"
  exit 1
fi

#NOTE hardcoded path to version 7 ISOs
awk -F '","' '($5 ~ /^http/) {print $5"7/isos/x86_64/"}' us-mirrorlist.csv > mirror_unvalidated_url.lst

mirror_html_dir=mirror_htmls
mkdir -p ${mirror_html_dir}
while read url
do
  #echo $url
  curl -s -I -X HEAD $url | egrep "^HTTP" | grep 200 > /dev/null
  if [[ $? -eq 0 ]]; then
    #echo success

    if [[ -z "$append_url" ]];
    then 
      domain=$( echo $url | awk -F "/" '{print $3}' )
      output_html=${mirror_html_dir}/${domain}.html
      curl -s $url -o ${output_html}
      append_url=$(python get_minimal_url.py ${output_html} $ISO)
      echo looking for ISO _ ${append_url} _
    fi

    #TODO add as aditional curlping test?
    curl -s -I -X HEAD ${url}${append_url} | egrep "^HTTP" | grep 200 > /dev/null

    if [[ $? -eq 0 ]]; then
      #echo validated
      echo $url >> mirror_url.lst
    fi
  fi
done < mirror_unvalidated_url.lst

awk -F "/" '{ print $3, $1"//"$3, $0; }' mirror_url.lst  > mirror_url_head.lst

./get_ping_performance.sh mirror $ISO

#TODO cleanup downloaded content
