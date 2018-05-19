#!/bin/bash

#awk -F "/" '{print $3}' ${1} | xargs -n 1 ping -c 3 | tee iso_pings.out
#awk -F "/" '{ print $3, $1"//"$3, $0; }' ${1} > iso_url_head.lst

mkdir -p iso_pings

count=1
while read urls;
do
  declare -a a="(${urls})";
  echo domain-${a[0]}
  domain=${a[0]}
  
  output_file=iso_pings/${domain}--stat.out
  #TODO
  #ping -c 10 -q ${domain} &>  $output_file & 
  #((count++))
  #if [[ $count -eq 3 ]]; then
    #exit
  #fi
done < iso_url_head.lst

echo ------------------------------
#TODO
#sleep 15
domains=$( wc -l iso_url_head.lst | cut -d ' ' -f 1 )
pings=$( grep statistics iso_pings/*.out | wc -l | cut -d ' ' -f 1 )

if [[ $domains -ne $pings ]]; then 
  echo ping not done after 15 sec
  exit 2
fi

#egrep "^rtt" iso_pings/*.out | awk -F '/' '{split($2,domain,"--"); print $6, $NF, domain[1]; for (i=1; i<=NF; i++) { print i " = " $i }}' | head -n 13
ping_host=$( egrep "^rtt" iso_pings/*.out | awk -F '/' '{split($2,domain,"--"); print $6, $NF, domain[1]; }' | sort -n -k 1n -k 2n | head -n 2 | awk 'BEGIN{ avg = 0; mdev=0} {
#print "average = " avg ", one = "$1 " -- " $4
if ( NR == 1) {
  print $4
}
if ( avg == $1 && mdev=$2 && NR == 2) {
  exit 1
}
avg=$1
mdev=$2
}' )

if [[ $? = 1 ]]; then 
  echo WARN detected multiple rows with same ping and std dev
  echo proceeding with 1st only, but you might have better performance from another
fi

echo fastest host is $ping_host

echo 
#echo could not ping these domains
grep "0 received, 100%" iso_pings/*.out | cut -d '/' -f 2 | cut -d '-' -f 1 > iso_curl_ping.lst
echo $ping_host >> iso_curl_ping.lst

mkdir -p iso_curl_pings
file_date=$(date '+%Y%m%d')
while read domain
do
  curl_url=$(grep $domain iso_url.lst )
  for cnt in {1..5}
  do 
    #curl -w "%{time_total}\n" -so /dev/null ${curl_url} >> iso_curl_pings/${domain}_${file_date}.out
    echo -n .
  done
done < iso_curl_ping.lst
echo .

for domain in iso_curl_pings/*.out
do
  avg=$(awk 'BEGIN{s=0} {s+=$1} END{print s/NR}' ${domain} )
  echo -n .
  #echo $avg >> ${domain}
done
echo .


min=10000
mindomain="non"
for domain in iso_curl_pings/*.out
do
  domain_min=$( tail -n 1 $domain)
  if [[ $( echo "$min < ${domain_min}" | bc) -eq 0 ]]; then 
    mindomain=$domain
    min=${domain_min}
  fi
done

mindomain=${mindomain##*/}
mindomain=${mindomain%%_*} 
echo fastest domain from curlping is ${mindomain}, average curl is $min

fast_url=$(grep ${mindomain} iso_url.lst )
curl -s ${fast_url} -o iso_fastest.html

append_url=$(python get_minimal_url.py iso_fastest.html)

echo ${fast_url}${append_url}

exit

