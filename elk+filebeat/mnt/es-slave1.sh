#########################################################################
# File Name: elastic-slave.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月20日 星期五 11时40分23秒
#########################################################################
#!/bin/bash

# 构建容器
docker run -d -e ES_JAVA_OPTS="-Xms256m -Xmx256m" \
	-p 9201:9200 -p 9301:9300 \
	-v /mnt/es1/slave1/conf/es-slave1.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
	-v /mnt/es1/slave1/data:/usr/share/elasticsearch/data \
	-v /mnt/es1/slave1/logs:/usr/share/elasticsearch/logs \
	-v /etc/localtime:/etc/localtime \
	--name es-slave1 elasticsearch:7.3.0
