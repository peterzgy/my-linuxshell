#########################################################################
# File Name: logstash.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月20日 星期五 16时13分17秒
#########################################################################
#!/bin/bash

# 构建容器
# xpack.monitoring.enabled 打开X-Pack的安全和监视服务
# xpack.monitoring.elasticsearch.hosts 设置ES地址，172.17.0.2为es-master容器ip
# docker允许在容器启动时执行一些命令，logsatsh -f 表示通过指定配置文件运行logstash，/usr/share/logstash/config/logstash-sample.conf是容器内的目录文件
 
docker run -p 5044:5044 -d \
	-v /mnt/logstash-filebeat.conf:/usr/share/logstash/config/logstash-sample.conf \
	-v /etc/localtime:/etc/localtime \
	-e elasticsearch.hosts=http://172.17.0.2:9200 \
	-e xpack.monitoring.enabled=true \
	-e xpack.monitoring.elasticsearch.hosts=http://172.17.0.2:9200 \
	--name logstash logstash:7.3.1 -f /usr/share/logstash/config/logstash-sample.conf
