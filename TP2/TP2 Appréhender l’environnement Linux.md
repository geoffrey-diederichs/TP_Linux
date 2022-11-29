# TP2 : Appréhender l'environnement Linux
# I. Service SSH
## 1. Analyse du service
🌞 **S'assurer que le service `sshd` est démarré**
```bash=
$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-11-22 15:33:15 CET; 2min 19s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 688 (sshd)
      Tasks: 1 (limit: 5906)
     Memory: 5.6M
        CPU: 121ms
     CGroup: /system.slice/sshd.service
             └─688 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Nov 22 15:33:15 linuxTP2 systemd[1]: Starting OpenSSH server daemon...
Nov 22 15:33:15 linuxTP2 sshd[688]: Server listening on 0.0.0.0 port 22.
Nov 22 15:33:15 linuxTP2 sshd[688]: Server listening on :: port 22.
Nov 22 15:33:15 linuxTP2 systemd[1]: Started OpenSSH server daemon.
Nov 22 15:33:34 linuxTP2 sshd[854]: Accepted password for rocky from 192.168.56.1 port 53938 ssh2
Nov 22 15:33:34 linuxTP2 sshd[854]: pam_unix(sshd:session): session opened for user rocky(uid=1000) by (uid=0)
```
🌞 **Analyser les processus liés au service SSH**
```bash=
$ ps -ef | grep sshd
root         688       1  0 15:33 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         854     688  0 15:33 ?        00:00:00 sshd: rocky [priv]
rocky        858     854  0 15:33 ?        00:00:00 sshd: rocky@pts/0
rocky        893     859  0 15:36 pts/0    00:00:00 grep --color=auto sshd
```
🌞 **Déterminer le port sur lequel écoute le service SSH**
```bash=
$ sudo ss -alnp | grep ssh
u_dgr UNCONN 0      0                                               * 19524                  * 11720 users:(("sshd",pid=858,fd=3),("sshd",pid=854,fd=3))                                          
tcp   LISTEN 0      128                                       0.0.0.0:22               0.0.0.0:*     users:(("sshd",pid=688,fd=3))                                                                
tcp   LISTEN 0      128                                          [::]:22                  [::]:*     users:(("sshd",pid=688,fd=4)) 
```
🌞 **Consulter les logs du service SSH**
```bash=
[rocky@linuxTP2 ~]$ sudo cat /var/log/secure | tail
Nov 22 15:50:51 linuxTP2 sudo[1012]: pam_unix(sudo:session): session closed for user root
Nov 22 15:50:54 linuxTP2 sudo[1016]:   rocky : TTY=pts/0 ; PWD=/home/rocky ; USER=root ; COMMAND=/bin/cat /var/log/secure
Nov 22 15:50:54 linuxTP2 sudo[1016]: pam_unix(sudo:session): session opened for user root(uid=0) by rocky(uid=1000)
Nov 22 15:50:54 linuxTP2 sudo[1016]: pam_unix(sudo:session): session closed for user root
Nov 22 15:51:33 linuxTP2 sudo[1020]:   rocky : TTY=pts/0 ; PWD=/home/rocky ; USER=root ; COMMAND=/bin/cat /var/log/secure
Nov 22 15:51:33 linuxTP2 sudo[1020]: pam_unix(sudo:session): session opened for user root(uid=0) by rocky(uid=1000)
Nov 22 15:51:33 linuxTP2 sudo[1020]: pam_unix(sudo:session): session closed for user root
Nov 22 15:51:37 linuxTP2 sudo[1025]:   rocky : TTY=pts/0 ; PWD=/home/rocky ; USER=root ; COMMAND=/bin/cat /var/log/secure
Nov 22 15:51:37 linuxTP2 sudo[1025]: pam_unix(sudo:session): session opened for user root(uid=0) by rocky(uid=1000)
Nov 22 15:51:37 linuxTP2 sudo[1025]: pam_unix(sudo:session): session closed for user root
```
```bash=
$ sudo cat /var/log/secure | grep sshd | tail
Nov 22 15:21:59 localhost sshd[688]: Server listening on :: port 22.
Nov 22 15:30:48 localhost sshd[886]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=192.168.56.1  user=rocky
Nov 22 15:30:50 localhost sshd[886]: Failed password for rocky from 192.168.56.1 port 59490 ssh2
Nov 22 15:30:53 localhost sshd[886]: Accepted password for rocky from 192.168.56.1 port 59490 ssh2
Nov 22 15:30:53 localhost sshd[886]: pam_unix(sshd:session): session opened for user rocky(uid=1000) by (uid=0)
Nov 22 15:33:15 linuxTP2 sshd[688]: Server listening on 0.0.0.0 port 22.
Nov 22 15:33:15 linuxTP2 sshd[688]: Server listening on :: port 22.
Nov 22 15:33:34 linuxTP2 sshd[854]: Accepted password for rocky from 192.168.56.1 port 53938 ssh2
Nov 22 15:33:34 linuxTP2 sshd[854]: pam_unix(sshd:session): session opened for user rocky(uid=1000) by (uid=0)
Nov 22 15:35:15 linuxTP2 sudo[881]:   rocky : TTY=pts/0 ; PWD=/home/rocky ; USER=root ; COMMAND=/bin/systemctl status sshd
```
## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**
```bash=
$ sudo cat /etc/ssh/sshd_config
#	$OpenBSD: sshd_config,v 1.104 2021/07/02 05:11:21 dtucker Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.
[...]
```
🌞 **Modifier le fichier de conf**

```bash=
$ sudo cat /etc/ssh/sshd_config | grep "Port "
Port 29476
$ sudo firewall-cmd --remove-port=22/tcp --permanent
Warning: NOT_ENABLED: 22:tcp
success
$ sudo firewall-cmd --add-port=29476/tcp --permanent
success
$ sudo firewall-cmd --reload
$ sudo firewall-cmd --list-port
29476/tcp
$ sudo firewall-cmd --list-all | grep " ports:"
  ports: 29476/tcp
```
🌞 **Redémarrer le service**
```bash=
$ sudo systemctl restart sshd
```
🌞 **Effectuer une connexion SSH sur le nouveau port**
```bash=
$ sudo ss -antp | grep ssh
LISTEN 0      128           0.0.0.0:29476      0.0.0.0:*     users:(("sshd",pid=1180,fd=3))                       
ESTAB  0      0      192.168.56.114:29476 192.168.56.1:54818 users:(("sshd",pid=1189,fd=4),("sshd",pid=1185,fd=4))
LISTEN 0      128              [::]:29476         [::]:*     users:(("sshd",pid=1180,fd=4)) 
```
# II. Service HTTP
## 1. Mise en place
🌞 **Installer le serveur NGINX**
```bash=
$ sudo dnf install nginx
```
🌞 **Démarrer le service NGINX**
```bash=
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd --reload
$ sudo systemctl enable nginx
$ sudo systemctl start nginx
$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-11-22 16:13:32 CET; 1min 36s ago
    Process: 1438 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1439 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1440 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1441 (nginx)
      Tasks: 2 (limit: 5906)
     Memory: 1.9M
        CPU: 18ms
     CGroup: /system.slice/nginx.service
             ├─1441 "nginx: master process /usr/sbin/nginx"
             └─1442 "nginx: worker process"

Nov 22 16:13:32 linuxTP2 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Nov 22 16:13:32 linuxTP2 nginx[1439]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Nov 22 16:13:32 linuxTP2 nginx[1439]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 22 16:13:32 linuxTP2 systemd[1]: Started The nginx HTTP and reverse proxy server.
```
🌞 **Déterminer sur quel port tourne NGINX**
Port : 80
```bash=
$ sudo ss -antp | grep nginx
LISTEN 0      511           0.0.0.0:80         0.0.0.0:*     users:(("nginx",pid=1442,fd=6),("nginx",pid=1441,fd=6))
LISTEN 0      511              [::]:80            [::]:*     users:(("nginx",pid=1442,fd=7),("nginx",pid=1441,fd=7))
```
🌞 **Déterminer les processus liés à l'exécution de NGINX**
```bash=
$ ps -ef | grep nginx
root        1441       1  0 16:13 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1442    1441  0 16:13 ?        00:00:00 nginx: worker process
rocky       1489    1190  0 16:19 pts/0    00:00:00 grep --color=auto nginx
```
🌞 **Euh wait**
```bash=
$ curl 192.168.56.114:80 | head -7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  3881k      0 --:--:-- --:--:-- --:--:-- 7441k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">

```
## 2. Analyser la conf de NGINX
🌞 **Déterminer le path du fichier de configuration de NGINX**
```bash=
$ sudo ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 May 16  2022 /etc/nginx/nginx.conf
```
🌞 **Trouver dans le fichier de conf**
```bash=
$ cat /etc/nginx/nginx.conf | grep -v "#" | grep "server {" -A 16 
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
```bash=
$ cat /etc/nginx/nginx.conf | grep "include /" | grep "conf.d"
    include /etc/nginx/conf.d/*.conf;
```
## 3. Déployer un nouveau site web

🌞 **Créer un site web**
```bash=
$ cat /var/www/tp2_linux/index.html
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Adapter la conf NGINX**
```bash=
$  cat /etc/nginx/nginx.conf | grep -v "#" | grep "server {"

$ sudo firewall-cmd --add-port=21208/tcp

$ sudo systemctl restart nginx    
```
🌞 **Visitez votre super site web**
```bash=
$ curl 192.168.56.114:21208
<h1>MEOW mon premier serveur web</h1>
```
# III. Your own services
## 1. Au cas où vous auriez oublié
```bash=
[rocky@linuxTP2 ~]$ sudo firewall-cmd --add-port=8888/tcp
[rocky@linuxTP2 ~]$ nc -l 8888
hello
```
```bash=
geoffrey@geoffrey:~$ nc 192.168.56.114 8888
hello
```
## 2. Analyse des services existants
🌞 **Afficher le fichier de service SSH**
```bash=
$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```
🌞 **Afficher le fichier de service NGINX**

```bash=
$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```
## 3. Création de service
🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**
```bash=
$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 16993
```
🌞 **Indiquer au système qu'on a modifié les fichiers de service**
```bash=
$ sudo systemctl daemon-reload
```
🌞 **Démarrer notre service de ouf**
```bash=
$ sudo firewall-cmd --add-port=16993/tcp --permanent
$ sudo firewall-cmd --reload
$ sudo systemctl start tp2_nc
```
🌞 **Vérifier que ça fonctionne**
```bash=
[rocky@linuxTP2 ~]$ systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Tue 2022-11-22 17:30:00 CET; 41s ago
   Main PID: 1840 (nc)
      Tasks: 1 (limit: 5906)
     Memory: 780.0K
        CPU: 6ms
     CGroup: /system.slice/tp2_nc.service
             └─1840 /usr/bin/nc -l 16993

Nov 22 17:30:00 linuxTP2 systemd[1]: Started Super netcat tout fou.

[rocky@linuxTP2 ~]$ sudo ss -antp | grep nc
LISTEN 0      10            0.0.0.0:16993      0.0.0.0:*     users:(("nc",pid=1840,fd=4))                           
LISTEN 0      10               [::]:16993         [::]:*     users:(("nc",pid=1840,fd=3))  
```
```bash=
geoffrey@geoffrey:~$ nc 192.168.56.114 16993
hello
```
```bash=
[rocky@linuxTP2 ~]$ sudo systemctl status tp2_nc
○ tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: inactive (dead)

Nov 29 11:56:43 linuxTP2 systemd[1]: Started Super netcat tout fou.
Nov 29 11:57:13 linuxTP2 nc[957]: hello
Nov 29 11:57:15 linuxTP2 systemd[1]: tp2_nc.service: Deactivated successfully.
```
🌞 **Les logs de votre service**
```bash=
[rocky@linuxTP2 ~]$ sudo systemctl status tp2_nc | grep Started
Nov 29 11:56:43 linuxTP2 systemd[1]: Started Super netcat tout fou.
```
```bash=
[rocky@linuxTP2 ~]$ sudo systemctl status tp2_nc | grep " nc"
Nov 29 11:57:13 linuxTP2 nc[957]: hello
```
```bash=
[rocky@linuxTP2 ~]$ sudo systemctl status tp2_nc | grep Deactivated
Nov 29 11:57:15 linuxTP2 systemd[1]: tp2_nc.service: Deactivated successfully.
```
🌞 **Affiner la définition du service**
```bash=
[rocky@linuxTP2 ~]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 16993
Restart=always
[rocky@linuxTP2 ~]$ sudo systemctl daemon-reload
```
```bash=
[rocky@linuxTP2 ~]$ systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Tue 2022-11-29 12:11:17 CET; 1min 51s ago
   Main PID: 942 (nc)
      Tasks: 1 (limit: 5906)
     Memory: 788.0K
        CPU: 4ms
     CGroup: /system.slice/tp2_nc.service
             └─942 /usr/bin/nc -l 16993

Nov 29 12:11:17 linuxTP2 systemd[1]: Started Super netcat tout fou.
```
```bash=
geoffrey@geoffrey:~$ nc 192.168.56.114 16993
test
```
```bash=
[rocky@linuxTP2 ~]$ sudo journalctl -xe -u tp2_nc | grep Started | tail -n1
Nov 29 12:13:36 linuxTP2 systemd[1]: Started Super netcat tout fou.
[rocky@linuxTP2 ~]$ sudo journalctl -xe -u tp2_nc | grep " nc" | tail -n1
Nov 29 12:13:34 linuxTP2 nc[942]: test
[rocky@linuxTP2 ~]$ sudo journalctl -xe -u tp2_nc | grep "Deactivated" | tail -n1
Nov 29 12:13:35 linuxTP2 systemd[1]: tp2_nc.service: Deactivated successfully.
[rocky@linuxTP2 ~]$ sudo journalctl -xe -u tp2_nc | grep "Started" | tail -n1
Nov 29 12:13:36 linuxTP2 systemd[1]: Started Super netcat tout fou.
[rocky@linuxTP2 ~]$ systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Tue 2022-11-29 12:13:36 CET; 3min 32s ago
   Main PID: 982 (nc)
      Tasks: 1 (limit: 5906)
     Memory: 780.0K
        CPU: 5ms
     CGroup: /system.slice/tp2_nc.service
             └─982 /usr/bin/nc -l 16993

Nov 29 12:13:36 linuxTP2 systemd[1]: Started Super netcat tout fou.
```