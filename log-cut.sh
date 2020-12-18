#########################################################################
# File Name: log-cut.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月18日 星期五 13时58分19秒
#########################################################################
#!/bin/bash

set -euo pipefail
Date=`date -d '-1 day' '+%Y-%m-%d'`
source_log_path=/home/ebs/soft/nginx/logs

cd ${source_log_path}  && mkdir -p logs/$Date
#cd /var/log/nginx  &&   mkdir logs/$Date
for i in $(ls *.log)
do
	gzip -c $i  > logs/$Date/"$i"_"$Date".gz
	echo " " > $i
	find logs/ -ctime +7 | xargs rm -rf
done
