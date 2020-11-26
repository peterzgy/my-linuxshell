
#!/bin/bash
#Denyhosts SHELL SCRIPT
#author:zouguoyin

cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"=" $1;}' >/root/Denyhosts.txt
DEFINE="10"
for i in `cat /root/Denyhosts.txt`
do
        IP=`echo $i|awk -F= '{print $1}'`
        NUM=`echo $i|awk -F= '{print $2}'`
        if [ $NUM -gt $DEFINE ]
        then
                ipExists=`grep $IP /etc/hosts.deny |grep -v grep |wc -l`
                if [ $ipExists -lt 1 ]
                then
                echo "sshd:$IP" >> /etc/hosts.deny
                fi
        fi
done
