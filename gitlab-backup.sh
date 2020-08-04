#!/bin/bash
#date:20200309
#author:zouguoyin
Bakupdir=/var/opt/gitlab/backups/
Logfile=/backup/logfile.txt
Date=`date +%Y-%m-%d`
gitlab-rake gitlab:backup:create RAILS_ENV=production
if [ $? -eq 0 ];then
    echo "$Date Backup Successful" >> $Logfile
else
    echo "$Date Backup Failed" >> $Logfile
fi
cd $Bakupdir
scp *.tar backup@192.168.106.222:/home/backup/gitbak
rm -rf *
