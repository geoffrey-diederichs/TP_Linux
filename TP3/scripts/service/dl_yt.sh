#!/bin/bash

youtube-dl ${1} -f mp4 -o /srv/service/video --write-info-json 1> /dev/null
title=$(grep -oP '(?<="fulltitle": ")[^"]*' /srv/service/video.info.json)
mv /srv/service/video /srv/service/downloads/"${title}".mp4
rm /srv/service/video*
