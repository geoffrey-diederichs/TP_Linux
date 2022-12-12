Ynov 2022 Informatique B1b

TP4 Linux

Geoffrey Diederichs

# Partie 1 : Partitionnement du serveur de stockage
🌞 **Partitionner le disque à l'aide de LVM**
```bash=
[rocky@storage ~]$ lsblk | grep sdb
sdb           8:16   0    2G  0 disk 

[rocky@storage ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

[rocky@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created

[rocky@storage ~]$ sudo lvcreate -l 100%FREE storage -n storage_lv
  Logical volume "storage_lv" created.

[rocky@storage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcf8adaf8-c247572d_ PVID ifZvwLqiQ4ZeMeNCHG02LltYS8tXzOM6 last seen on /dev/sda2 not found.
  LV         VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  storage_lv storage -wi-a----- <2.00g       
```
🌞 **Formater la partition**
```bash=
[rocky@storage ~]$ sudo mkfs -t ext4 /dev/storage/storage_lv 
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 8bf33d96-6970-4f15-91f4-e45545264424
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 
```
🌞 **Monter la partition**
```bash=
[rocky@storage ~]$ sudo mkdir /storage

[rocky@storage ~]$ sudo mount /dev/storage/storage_lv /storage/

[rocky@storage ~]$ df -h | grep storage
/dev/mapper/storage-storage_lv  2.0G   24K  1.9G   1% /storage

[rocky@storage ~]$ sudo fallocate -l 5242880 /storage/test

[rocky@storage ~]$ sudo df -h | grep storage
/dev/mapper/storage-storage_lv  2.0G  5.1M  1.9G   1% /storage

[rocky@storage ~]$ sudo nano /storage/test

[rocky@storage ~]$ sudo cat /storage/test
test
```
```bash=
[rocky@storage ~]$ sudo cat /etc/fstab | grep storage
/dev/storage/storage_lv /storage ext4 defaults 0 0

[rocky@storage ~]$ sudo umount /dev/storage/storage_lv 

[rocky@storage ~]$ df -h | grep storage

[rocky@storage ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/storage                 : successfully mounted

[rocky@storage ~]$ df -h | grep storage
/dev/mapper/storage-storage_lv  2.0G   24K  1.9G   1% /storage
```
# Partie 2 : Serveur de partage de fichiers
🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**
```bash=
[rocky@web ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:6d:40:da brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 86147sec preferred_lft 86147sec
    inet6 fe80::a00:27ff:fe6d:40da/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:90:28:ef brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.120/24 brd 192.168.56.255 scope global dynamic noprefixroute enp0s8
       valid_lft 347sec preferred_lft 347sec
    inet6 fe80::7598:32cc:e961:7b1d/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
```bash=
[rocky@storage ~]$ sudo dnf -y install nfs-utils

[rocky@storage ~]$ sudo mkdir /storage/site_web_1

[rocky@storage ~]$ sudo mkdir /storage/site_web_2

[rocky@storage ~]$ sudo chown nobody /storage/site_web_1

[rocky@storage ~]$ sudo chown nobody /storage/site_web_2

[rocky@storage ~]$ ls -la /storage/
total 28
drwxr-xr-x.  5 root   root  4096 Dec 11 16:04 .
dr-xr-xr-x. 19 root   root   250 Dec 11 15:18 ..
drwx------.  2 root   root 16384 Dec 11 15:16 lost+found
drwxr-xr-x.  2 nobody root  4096 Dec 11 16:04 site_web_1
drwxr-xr-x.  2 nobody root  4096 Dec 11 16:04 site_web_2

[rocky@storage ~]$ sudo cat /etc/exports
/storage/site_web_1 192.168.56.120(rw)
/storage/site_web_2 192.168.56.120(rw)

[rocky@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.

[rocky@storage ~]$ sudo systemctl start nfs-server

[rocky@storage ~]$ sudo systemctl status  nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Sun 2022-12-11 16:07:24 CET; 3s ago
    Process: 11428 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 11429 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11446 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gsspr>
   Main PID: 11446 (code=exited, status=0/SUCCESS)
        CPU: 42ms

Dec 11 16:07:24 storage.tp4.linux systemd[1]: Starting NFS server and services...
Dec 11 16:07:24 storage.tp4.linux systemd[1]: Finished NFS server and services.

[rocky@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success

[rocky@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success

[rocky@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success

[rocky@storage ~]$ sudo firewall-cmd --reload
success

[rocky@storage ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:6d:40:da brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 85752sec preferred_lft 85752sec
    inet6 fe80::a00:27ff:fe6d:40da/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:de:51:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.119/24 brd 192.168.56.255 scope global dynamic noprefixroute enp0s8
       valid_lft 552sec preferred_lft 552sec
    inet6 fe80::ff75:7e36:ce5e:37ad/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**
```bash=
[rocky@web ~]$ sudo mkdir -p /var/www/site_web_1

[rocky@web ~]$ sudo mkdir -p /var/www/site_web_2

[rocky@web ~]$ ls -la /var/www/
total 4
drwxr-xr-x.  4 root root   42 Dec 11 16:13 .
drwxr-xr-x. 20 root root 4096 Dec 11 16:13 ..
drwxr-xr-x.  2 root root    6 Dec 11 16:13 site_web_1
drwxr-xr-x.  2 root root    6 Dec 11 16:13 site_web_2

[rocky@web ~]$ sudo mount 192.168.56.119:/storage/site_web_1/ /var/www/site_web_1/

[rocky@web ~]$ sudo mount 192.168.56.119:/storage/site_web_2/ /var/www/site_web_2/

[rocky@web ~]$ df -h | grep storage
192.168.56.119:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
192.168.56.119:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2

[rocky@web ~]$ sudo cat /etc/fstab | grep storage
192.168.56.119:/storage/site_web_1 /var/www/site_web_1/ nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.56.119:/storage/site_web_2 /var/www/site_web_2/ nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0

[rocky@web ~]$ sudo umount 192.168.56.119:/storage/site_web_1 ; sudo umount 192.168.56.119:/storage/site_web_2

[rocky@web ~]$ df -h | grep storage

[rocky@web ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs: timeout set for Sun Dec 11 16:35:15 2022
mount.nfs: trying text-based options 'nolock,intr,tcp,actimeo=1800,vers=4.2,addr=192.168.56.119,clientaddr=192.168.56.120'
/var/www/site_web_1/     : successfully mounted
mount.nfs: timeout set for Sun Dec 11 16:35:15 2022
mount.nfs: trying text-based options 'nolock,intr,tcp,actimeo=1800,vers=4.2,addr=192.168.56.119,clientaddr=192.168.56.120'
/var/www/site_web_2/     : successfully mounted

[rocky@web ~]$ df -h | grep storage
192.168.56.119:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
192.168.56.119:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
```
```bash=
[rocky@storage ~]$ sudo touch /storage/site_web_1/test1

[rocky@storage ~]$ sudo touch /storage/site_web_2/test2
```
```bash=
[rocky@web ~]$ sudo ls -R /var/www/
/var/www/:
site_web_1  site_web_2

/var/www/site_web_1:
test1

/var/www/site_web_2:
test2
```
# Partie 3 : Serveur web
## 2. Install
```bash=
[rocky@web ~]$ sudo dnf -y install nginx
Last metadata expiration check: 0:33:14 ago on Sun 11 Dec 2022 04:02:24 PM CET.
Package nginx-1:1.20.1-13.el9.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```
## 3. Analyse
```bash=
[rocky@web ~]$ sudo systemctl start nginx

[rocky@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Sun 2022-12-11 16:36:59 CET; 4s ago
    Process: 2549 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2550 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2551 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2552 (nginx)
      Tasks: 2 (limit: 5906)
     Memory: 1.9M
        CPU: 37ms
     CGroup: /system.slice/nginx.service
             ├─2552 "nginx: master process /usr/sbin/nginx"
             └─2553 "nginx: worker process"

Dec 11 16:36:59 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 11 16:36:59 web.tp4.linux nginx[2550]: nginx: the configuration file /etc/nginx/nginx.conf syntax is>
Dec 11 16:36:59 web.tp4.linux nginx[2550]: nginx: configuration file /etc/nginx/nginx.conf test is succe>
Dec 11 16:36:59 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
🌞 **Analysez le service NGINX**
```bash=
[rocky@web ~]$ ps -ef | grep nginx
root        2552       1  0 16:36 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       2553    2552  0 16:36 ?        00:00:00 nginx: worker process
rocky       2564     835  0 16:38 pts/0    00:00:00 grep --color=auto nginx

[rocky@web ~]$ sudo ss -ltpn | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2828,fd=6),("nginx",pid=2827,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=2828,fd=7),("nginx",pid=2827,fd=7))

[rocky@web ~]$ ls -al /usr/share/nginx/html/index.html 
lrwxrwxrwx. 1 root root 25 Oct 31 16:37 /usr/share/nginx/html/index.html -> ../../testpage/index.html
```
Utilisateur : nginx.
Authorisations sur le fichier : read, write, execute.
## 4. Visite du service web
🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**
```bash=
[rocky@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
Warning: ALREADY_ENABLED: 80:tcp
success

[rocky@web ~]$ sudo firewall-cmd --reload
success
```
🌞 **Accéder au site web**
```bash=
[rocky@web ~]$ curl http://localhost | head -n 15
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
        height: 100%;
        width: 100%;
      }  
        body {
  background: rgb(20,72,50);
100  7620  100  7620    0     0   413k      0 --:--:-- --:--:-- --:--:--  413k
```
```bash=
geoffrey@geoffrey:~$ curl http://192.168.56.120 | head -n 15
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
        height: 100%;
        width: 100%;
      }  
        body {
  background: rgb(20,72,50);
```
🌞 **Vérifier les logs d'accès**
```bash=
[rocky@web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
::1 - - [11/Dec/2022:16:54:53 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
::1 - - [11/Dec/2022:16:54:58 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
::1 - - [11/Dec/2022:16:55:12 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```
## 5. Modif de la conf du serveur web
🌞 **Changer le port d'écoute**
```bash=
[rocky@web ~]$ sudo cat /etc/nginx/nginx.conf | grep "listen" | grep -v "#"
        listen       8080;
        listen       [::]:8080;
        
[rocky@web ~]$ sudo systemctl restart nginx

[rocky@web ~]$ sudo ss -ltpn | grep nginx
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=2886,fd=6),("nginx",pid=2885,fd=6))
LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=2886,fd=7),("nginx",pid=2885,fd=7))

[rocky@web ~]$ sudo firewall-cmd --permanent --remove-port=80/tcp
success

[rocky@web ~]$ sudo firewall-cmd --permanent --add-port=8080/tcp
success

[rocky@web ~]$ sudo firewall-cmd --reload
success

[rocky@web ~]$ curl http://localhost:8080 | head -n 15
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
        height: 100%;
        width: 100%;
      }  
        body {
  background: rgb(20,72,50);
100  7620  100  7620    0     0   372k      0 --:--:-- --:--:-- --:--:--  372k
curl: (23) Failed writing body
```
```bash=
geoffrey@geoffrey:~$ curl http://192.168.56.120:8080 | head -n 15
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
        height: 100%;
        width: 100%;
      }  
        body {
  background: rgb(20,72,50);
```
🌞 **Changer l'utilisateur qui lance le service**
```bash=
[rocky@web ~]$ sudo useradd -d /home/web web

[rocky@web ~]$ sudo passwd web

[rocky@web ~]$ sudo cat /etc/passwd | grep web:
web:x:1001:1001::/home/web:/bin/bash

[rocky@web ~]$ sudo cat /etc/shadow | grep web
web:$6$M7nmXQuBvT6isLwk$q8ZOioLjIhBp67ineHyRDoC816V7fq/qrMnF22zm3MsUzqHRthVKtz0N0tm0w2ZZFu5VfN0v/pqplE4TBskvw1:19337:0:99999:7:::
```
```bash=
[rocky@web ~]$ sudo cat /etc/nginx/nginx.conf | grep user | grep -v "'"
user web;

[rocky@web ~]$ sudo systemctl reload nginx

[rocky@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Sun 2022-12-11 17:05:25 CET; 11min ago
    Process: 2882 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2883 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2884 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
    Process: 3037 ExecReload=/usr/sbin/nginx -s reload (code=exited, status=0/SUCCESS)
   Main PID: 2885 (nginx)
      Tasks: 2 (limit: 5906)
     Memory: 2.0M
        CPU: 49ms
     CGroup: /system.slice/nginx.service
             ├─2885 "nginx: master process /usr/sbin/nginx"
             └─3038 "nginx: worker process"

Dec 11 17:05:25 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 11 17:05:25 web.tp4.linux nginx[2883]: nginx: the configuration file /etc/nginx/nginx.conf syntax is>
Dec 11 17:05:25 web.tp4.linux nginx[2883]: nginx: configuration file /etc/nginx/nginx.conf test is succe>
Dec 11 17:05:25 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
Dec 11 17:16:32 web.tp4.linux systemd[1]: Reloading The nginx HTTP and reverse proxy server...
Dec 11 17:16:32 web.tp4.linux systemd[1]: Reloaded The nginx HTTP and reverse proxy server.

[rocky@web ~]$ sudo ps -ef | grep nginx
root        2885       1  0 17:05 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         3038    2885  0 17:16 ?        00:00:00 nginx: worker process
rocky       3046     835  0 17:17 pts/0    00:00:00 grep --color=auto nginx

[rocky@web ~]$ curl http://localhost:8080 | head -n 15
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
<!doctype html>    0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
        height: 100%;
        width: 100%;
      }  
        body {
  background: rgb(20,72,50);
100  7620  100  7620    0     0   531k      0 --:--:-- --:--:-- --:--:--  572k
```
🌞 **Changer l'emplacement de la racine Web**
```bash=
[rocky@web ~]$ sudo cat /var/www/site_web_1/index.html
get hacked

[rocky@web ~]$ sudo cat /etc/nginx/nginx.conf | grep root | grep -v "#"
        root         /var/www/site_web_1/;

[rocky@web ~]$ sudo systemctl reload nginx

[rocky@web ~]$ curl http://localhost:8080
get hacked
```
## 6. Deux sites web sur un seul serveur
🌞 **Repérez dans le fichier de conf**
```bash=
[rocky@web ~]$ sudo cat /etc/nginx/nginx.conf | grep " include" | grep "*" | grep -v "#"
    include /etc/nginx/conf.d/*.conf;

```
🌞 **Créez le fichier de configuration pour le premier site**
```bash=
[rocky@web ~]$ sudo cat /etc/nginx/nginx.conf | grep server | grep -v "#"

[rocky@web ~]$ sudo cat /etc/nginx/conf.d/site_web_1.conf 
    server {
        listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
🌞 **Créez le fichier de configuration pour le deuxième site**
```bash=
[rocky@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf 
    server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
    
[rocky@web ~]$ sudo cat /var/www/site_web_2/index.html 
nope, just jk

[rocky@web ~]$ sudo firewall-cmd --permanent --add-port=8888/tcp
success

[rocky@web ~]$ sudo firewall-cmd --reload
success
```
🌞 **Prouvez que les deux sites sont disponibles**
```bash=
[rocky@web ~]$ sudo systemctl reload nginx

[rocky@web ~]$ curl http://localhost:8080
get hacked

[rocky@web ~]$ curl http://localhost:8888
nope, just jk
```
```bash=
geoffrey@geoffrey:~$ curl http://192.168.56.120:8080
get hacked

geoffrey@geoffrey:~$ curl http://192.168.56.120:8888
nope, just jk
```
