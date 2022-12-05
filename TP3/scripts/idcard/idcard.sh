#!/bin/bash

echo "Machine name : $(hostname)"
echo "OS $(cat /etc/redhat-release) and kernel version is $(uname -r)"
echo "IP : $(ip a | grep "inet " | grep "brd" | cut -d " " -f6 | head -n 1)"
echo "RAM : $(free -h | grep "Mem" | cut -d" " -f26) memory available on $(free -h | grep "Mem" | cut -d" " -f12) total memory"
echo "Disk : $(df -h --total | grep total | cut -d" " -f21) space left" 

echo "Top 5 process by RAM usage :"
for i in $(seq 2 6)
do
 process=$(ps -e -o command= --sort=-%mem | head -n ${i} | tail -n 1)
 echo " - ${process}"
done

echo "Listening ports :"
for i in $(seq 1 $(ss -lnH4pu | tr -s " " | wc -l))
do
 port=$(ss -lnH4pu | tr -s " " | cut -d" " -f4 | cut -d":" -f2 | head -n ${i} | tail -n 1)
 process=$(ss -lnHu4p | tr -s " " | cut -d" " -f6 | cut -d":" -f2 | cut -d'"' -f2 | head -n ${i} | tail -n 1)
 echo " - ${port} UDP : ${process}"
done
for i in $(seq 1 $(ss -lnH4pt | tr -s " " | wc -l))
do
 port=$(ss -lnH4pt | tr -s " " | cut -d" " -f4 | cut -d":" -f2 | head -n ${i} | tail -n 1)
 process=$(ss -lnHt4p | tr -s " " | cut -d" " -f6 | cut -d":" -f2 | cut -d'"' -f2 | head -n ${i} | tail -n 1)
 echo " - ${port} TCP : ${process}"
done

curl https://cataas.com/cat -o /cat 2> /dev/null
fileName=cat.$(file /cat | cut -d" " -f2 | tr '[:upper:]' '[:lower:]')
mv /cat ${fileName}
echo Here is your random cat : ./${fileName}
