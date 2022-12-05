Geoffrey Diederichs Ynov B1b

# TP 3 : We do a little scripting
# 0. Un premier script
```bash=
[rocky@linuxTP3 /]$ cat /srv/test.sh 
#!/bin/bash
# Simple test script

echo "Connecté actuellement avec l'utilisateur $(whoami)."

[rocky@linuxTP3 /]$ ls -al /srv/test.sh 
-rwxr-xr-x. 1 rocky root 94 Nov 28 14:57 /srv/test.sh

[rocky@linuxTP3 /]$ /srv/test.sh 
Connecté actuellement avec l'utilisateur rocky.
```
```bash=
[rocky@linuxTP3 /]$ cd /srv
[rocky@linuxTP3 srv]$ ./test.sh 
Connecté actuellement avec l'utilisateur rocky.
```
# I. Script carte d'identité
[idcard.sh](./scripts/idcard/idcard.sh)
```bash=
[rocky@linuxTP3 idcard]$ pwd
/srv/idcard

[rocky@linuxTP3 idcard]$ ls -la
total 4
drwxr-xr-x. 2 root  root   23 Dec  5 11:52 .
drwxr-xr-x. 6 root  root   71 Nov 29 15:54 ..
-rwxr-xr-x. 1 rocky root 1359 Dec  5 11:49 idcard.sh

[rocky@linuxTP3 idcard]$ sudo ./idcard.sh 
Machine name : linuxTP3
OS Rocky Linux release 9.0 (Blue Onyx) and kernel version is 5.14.0-70.30.1.el9_0.x86_64
IP : 10.0.2.15/24
RAM : 702Mi memory available on 960Mi total memory
Disk : 7.0G space left
Top 5 process by RAM usage :
 - /usr/sbin/NetworkManager --no-daemon
 - /usr/lib/systemd/systemd --switched-root --system --deserialize 18
 - /usr/lib/systemd/systemd --user
 - sshd: rocky [priv]
 - sshd: rocky [priv]
Listening ports :
 - 323 UDP : chronyd
 - 22 TCP : sshd
Here is your random cat : ./cat.jpeg

[rocky@linuxTP3 idcard]$ ls -la
total 32
drwxr-xr-x. 2 root  root    39 Dec  5 11:52 .
drwxr-xr-x. 6 root  root    71 Nov 29 15:54 ..
-rw-r--r--. 1 root  root 27532 Dec  5 11:52 cat.jpeg
-rwxr-xr-x. 1 rocky root  1359 Dec  5 11:49 idcard.sh

[rocky@linuxTP3 idcard]$ file cat.jpeg 
cat.jpeg: JPEG image data, JFIF standard 1.01, resolution (DPI), density 72x72, segment length 16, baseline, precision 8, 600x601, components 3
```
# II. Script youtube-dl
[yt.sh](./scripts/youtube-dl/yt.sh)
[download.log](./scripts/youtube-dl/download.log)
```bash=
[rocky@linuxTP3 yt]$ pwd
/srv/yt

[rocky@linuxTP3 yt]$ ls -la
total 4
drwxr-xr-x. 2 rocky root  19 Dec  5 12:22 .
drwxr-xr-x. 5 root  root  60 Dec  5 12:11 ..
-rwxr-xr-x. 1 rocky root 729 Dec  5 12:14 yt.sh

[rocky@linuxTP3 yt]$ ls -la /var/log/yt
ls: cannot access '/var/log/yt': No such file or directory

[rocky@linuxTP3 yt]$ ./yt.sh https://www.youtube.com/watch?v=TK4N5W22Gts

[rocky@linuxTP3 yt]$ ls -la
total 4
drwxr-xr-x. 2 rocky root  19 Dec  5 12:22 .
drwxr-xr-x. 5 root  root  60 Dec  5 12:11 ..
-rwxr-xr-x. 1 rocky root 729 Dec  5 12:14 yt.sh

[rocky@linuxTP3 yt]$ mkdir downloads

[rocky@linuxTP3 yt]$ sudo mkdir /var/log/yt

[rocky@linuxTP3 yt]$ sudo chown rocky /var/log/yt

[rocky@linuxTP3 yt]$ ./yt.sh https://www.youtube.com/watch?v=TK4N5W22Gts
Video https://www.youtube.com/watch?v=TK4N5W22Gts was downloaded.
File path : /srv/yt/downloads/2 Second Video/2 Second Video.mp4

[rocky@linuxTP3 yt]$ ls -la downloads/
total 0
drwxr-xr-x. 3 rocky rocky 28 Dec  5 12:26  .
drwxr-xr-x. 3 rocky root  36 Dec  5 12:26  ..
drwxr-xr-x. 2 rocky rocky 32 Dec  5 12:26 '2 Second Video'

[rocky@linuxTP3 yt]$ ls -la downloads/2\ Second\ Video/
total 56
drwxr-xr-x. 2 rocky rocky    32 Dec  5 12:26  .
drwxr-xr-x. 3 rocky rocky    28 Dec  5 12:26  ..
-rw-r--r--. 1 rocky rocky 53390 Dec  5 10:58 '2 Second Video.mp4'

[rocky@linuxTP3 ~]$ cat /var/log/yt/download.log 
[2022/12/05 12:45:17] Video https://www.youtube.com/watch?v=TK4N5W22Gts was downloaded. File Path : /srv/yt/downloads/2 Second Video/2 Second Video.mp4
```
# III. MAKE IT A SERVICE
```bash=
[rocky@linuxTP3 yt]$ sudo systemctl status yt
○ yt.service - "Downloads youtube videos from the url in /srv/service/urls.txt"
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: inactive (dead)

Dec 05 12:51:03 linuxTP3 systemd[1]: Started "Downloads youtube videos from the url in /srv/service/url>
Dec 05 12:55:56 linuxTP3 yt-v2.sh[4559]: https://www.youtube.com/watch?v=jhFDyDgMVUI
Dec 05 12:56:43 linuxTP3 systemd[1]: Stopping "Downloads youtube videos from the url in /srv/service/ur>
Dec 05 12:56:43 linuxTP3 systemd[1]: yt.service: Deactivated successfully.
Dec 05 12:56:43 linuxTP3 systemd[1]: Stopped "Downloads youtube videos from the url in /srv/service/url>
Dec 05 12:56:43 linuxTP3 systemd[1]: yt.service: Consumed 6.050s CPU time.
```
```bash=
[rocky@linuxTP3 ~]$ cat /srv/service/urls.txt

[rocky@linuxTP3 yt]$ sudo systemctl start yt

[rocky@linuxTP3 yt]$ sudo systemctl status yt
● yt.service - "Downloads youtube videos from the url in /srv/service/urls.txt"
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-12-05 13:02:41 CET; 1s ago
   Main PID: 4816 (yt-v2.sh)
      Tasks: 2 (limit: 5906)
     Memory: 560.0K
        CPU: 7ms
     CGroup: /system.slice/yt.service
             ├─4816 /bin/bash /srv/service/yt-v2.sh
             └─4817 sleep 2

Dec 05 13:02:41 linuxTP3 systemd[1]: Started "Downloads youtube videos from the url in /srv/service/url>
lines 1-12/12 (END)
```
```bash=
[rocky@linuxTP3 ~]$ cat /srv/service/urls.txt 
https://www.youtube.com/watch?v=TK4N5W22Gts
https://www.youtube.com/watch?v=jhFDyDgMVUI

[rocky@linuxTP3 ~]$ ls -la /srv/service/downloads/
total 72
drwxr-xr-x. 2 rocky rocky    60 Dec  5 13:03  .
drwxr-xr-x. 3 rocky root     86 Dec  5 13:03  ..
-rw-r--r--. 1 rocky rocky 53390 Dec  5 10:58 '2 Second Video.mp4'
-rw-r--r--. 1 rocky rocky 14942 Oct 11 01:33 'One Second Video.mp4'

[rocky@linuxTP3 ~]$ cat /srv/service/urls.txt 

[rocky@linuxTP3 yt]$ sudo systemctl status yt
● yt.service - "Downloads youtube videos from the url in /srv/service/urls.txt"
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-12-05 13:02:41 CET; 2min 41s ago
   Main PID: 4816 (yt-v2.sh)
      Tasks: 2 (limit: 5906)
     Memory: 660.0K
        CPU: 6.058s
     CGroup: /system.slice/yt.service
             ├─4816 /bin/bash /srv/service/yt-v2.sh
             └─4963 sleep 2

Dec 05 13:02:41 linuxTP3 systemd[1]: Started "Downloads youtube videos from the url in /srv/service/url>
Dec 05 13:03:30 linuxTP3 yt-v2.sh[4870]: https://www.youtube.com/watch?v=jhFDyDgMVUI
```
```bash=
[rocky@linuxTP3 yt]$ journalctl -xe -u yt
[...]
Dec 05 13:02:41 linuxTP3 systemd[1]: Started "Downloads youtube videos from the url in /srv/service/url>
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit yt.service has finished successfully.
░░ 
░░ The job identifier is 1633.
Dec 05 13:03:30 linuxTP3 yt-v2.sh[4870]: https://www.youtube.com/watch?v=jhFDyDgMVUI
```
