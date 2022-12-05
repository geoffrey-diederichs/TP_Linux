#!/bin/bash

while true
do
 if [[ -s /srv/service/urls.txt ]]
 then
  url=$(cat /srv/service/urls.txt | head -n 1)
  /srv/service/dl_yt.sh $(cat /srv/service/urls.txt | head -n 1)

  lines=$(( $(wc /srv/service/urls.txt | cut -d" " -f2) - 1 ))
  if [[ ${lines} -gt 0 ]]
   then
    echo $(cat /srv/service/urls.txt | tail -n ${lines}) > /srv/service/urls.txt
    cat /srv/service/urls.txt
   else
    echo -n > /srv/service/urls.txt
  fi
 fi
 sleep 2
done
