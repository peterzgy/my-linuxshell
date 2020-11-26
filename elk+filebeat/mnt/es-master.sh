#########################################################################
# File Name: elastic.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月20日 星期五 11时31分56秒
#########################################################################
#!/bin/bash

# 构建容器
# 映射5601是为Kibana预留的端口
#/etc/localtime:/etc/localtime：宿主机与容器时间同步。
docker run -d -e ES_JAVA_OPTS="-Xms256m -Xmx256m" \
	-p 9200:9200 -p 9300:9300 -p 5601:5601 \
	-v /mnt/es1/master/conf/es-master.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
	-v /mnt/es1/master/data:/usr/share/elasticsearch/data \
	-v /mnt/es1/master/logs:/usr/share/elasticsearch/logs \
	-v /etc/localtime:/etc/localtime \
	--name es-master elasticsearch:7.3.0
