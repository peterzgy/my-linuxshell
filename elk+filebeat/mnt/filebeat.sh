#########################################################################
# File Name: filebeat.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月20日 星期五 16时44分13秒
#########################################################################
#!/bin/bash

 
# 构建容器
## --link logstash 将指定容器连接到当前连接，可以设置别名，避免ip方式导致的容器重启动态改变的无法连接情况，logstash 为容器名
docker run -d -v /mnt/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml \
	-v /mnt/omc-dev/logs:/home/project/spring-boot-elasticsearch/logs \
	-v /mnt/filebeat/logs:/usr/share/filebeat/logs \
	-v /mnt/filebeat/data:/usr/share/filebeat/data \
	-v /etc/localtime:/etc/localtime \
	--link logstash --name filebeat docker.elastic.co/beats/filebeat:7.3.0
