#!/bin/bash

if [[ -d /var/log/yt/ ]]
then
 if [[ -z ${1} ]]
 then
  exit
 else
  if [[ -d /srv/yt/downloads/ ]]
  then	
   youtube-dl ${1} -f mp4 -o /srv/yt/downloads/video --write-info-json 1> /dev/null
   title=$(grep -oP '(?<="fulltitle": ")[^"]*' /srv/yt/downloads/video.info.json)
   mkdir /srv/yt/downloads/"${title}" 2> /dev/null
   mv /srv/yt/downloads/video /srv/yt/downloads/"${title}"/"${title}".mp4
   rm /srv/yt/downloads/video*

   echo "Video ${1} was downloaded."
   echo "File path : /srv/yt/downloads/${title}/${title}.mp4"
  else
   exit
  fi
 fi
 date=$(date "+%Y/%m/%d %T")
 echo "[${date}] Video ${1} was downloaded. File Path : /srv/yt/downloads/${title}/${title}.mp4" >> /var/log/yt/download.log
else
 exit
fi
