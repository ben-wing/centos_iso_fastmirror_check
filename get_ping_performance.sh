#!/bin/bash

#TODO check args that $1 is present and either iso or mirror

i_or_m=$1

pingdir=${i_or_m}_pings
url_list=${i_or_m}_url.lst
head_list=${i_or_m}_url_head.lst
curlpingdir=${i_or_m}_curl_pings


mkdir -p ${pingdir}

count=1
while read urls;
do
  declare -a a="(${urls})";
  echo domain-${a[0]}
  domain=${a[0]}
  
  output_file=${pingdir}/${domain}--stat.out
  ping -c 10 -q ${domain} &>  $output_file & 
  #((count++))
  #if [[ $count -eq 3 ]]; then
    #exit
  #fi
done < ${head_list}

echo ------------------------------
#TODO turn this into a loop to check every 5 sec rather than wait arbitrary length and die with no recourse
sleep 30
domains=$( wc -l ${head_list} | cut -d ' ' -f 1 )
pings=$( grep statistics ${pingdir}/*.out | wc -l | cut -d ' ' -f 1 )

if [[ $domains -ne $pings ]]; then 
  echo ping not done after 15 sec
  exit 2
fi

#egrep "^rtt" ${pingdir}/*.out | awk -F '/' '{split($2,domain,"--"); print $6, $NF, domain[1]; for (i=1; i<=NF; i++) { print i " = " $i }}' | head -n 13
ping_host=$( egrep "^rtt" ${pingdir}/*.out | awk -F '/' '{split($2,domain,"--"); print $6, $NF, domain[1]; }' | sort -n -k 1n -k 2n | head -n 2 | awk 'BEGIN{ avg = 0; mdev=0} {
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

#TODO can we include avg ping time
echo fastest host is $ping_host

echo 
#echo could not ping these domains
grep "0 received, 100%" ${pingdir}/*.out | cut -d '/' -f 2 | cut -d '-' -f 1 > ${i_or_m}_curl_ping.lst
echo $ping_host >> ${i_or_m}_curl_ping.lst

#TODO turn curl into a function so it can be backgrounded and follow the ping section
mkdir -p ${curlpingdir}
file_date=$(date '+%Y%m%d')
while read domain
do
  curl_url=$(grep $domain ${url_list} )
  for cnt in {1..5}
  do 
    curl -w "%{time_total}\n" -so /dev/null ${curl_url} >> ${curlpingdir}/${domain}_${file_date}.out
    echo -n .
  done
done < ${i_or_m}_curl_ping.lst
echo .

for domain in ${curlpingdir}/*.out
do
  avg=$(awk 'BEGIN{s=0} {s+=$1} END{print s/NR}' ${domain} )
  echo -n .
  echo $avg >> ${domain}
done
echo .


min=10000
mindomain="non"
for domain in ${curlpingdir}/*.out
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

fast_url=$(grep ${mindomain} ${url_list} )
curl -s ${fast_url} -o ${i_or_m}_fastest.html

append_url=$(python get_minimal_url.py ${i_or_m}_fastest.html)

echo ${fast_url}${append_url}

exit

