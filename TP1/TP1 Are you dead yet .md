Geoffrey DIEDERICHS B1b

# TP1 : Are you dead yet ?

Hasher le disque dur :
```bash=
$ sudo chmod ugo+wx /dev/sda1
$ sudo sha1sum /dev/sda > /dev/sda
```

Supprimer bash :
```bash=
$ sudo chmod +w /bin/bash
$ sudo rm /bin/bash
```

Supprimer les mots de passes : 
```bash=
$ sudo rm /etc/shadow
```

Autant tout supprimer en fait : 
```bash=
$ sudo rm --no-preserve-root -rf / 2> /dev/null
```

Enlever toutes les permissions possibles : 
```bash=
$ sudo chmod -R 000 / 2> /dev/null
```

Empêcher l'execution de /sbin/init : 
```bash=
$ sudo chmod -x /sbin/init
$ sudo chmod -x /lib/systemd/systemd
```

Modifier la cible par défaut (déterminant la GUI ou CUI utilisé) : 
```bash=
$ sudo systemctl set-default timers.target
```

