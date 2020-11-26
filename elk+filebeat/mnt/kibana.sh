#########################################################################
# File Name: kibana.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月20日 星期五 15时16分38秒
#########################################################################
#!/bin/bash

# 构建容器
## --network=container 表示共享容器网络
docker run -it -d \
	-v /mnt/kibana.yml:/usr/share/kibana/config/kibana.yml \
	-v /etc/localtime:/etc/localtime \
	-e ELASTICSEARCH_URL=http://172.17.0.2:9200 \
	--network=container:93749e752742 \
	--name kibana docker.elastic.co/kibana/kibana:7.3.0
