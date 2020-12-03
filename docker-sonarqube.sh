
#########################################################################
# File Name: docker-sonarqube.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月3日 星期四 14时22分15秒
#########################################################################
#!/bin/bash

help(){
        echo "Usage:"
        echo "sh docker-sonarqube.sh"
        echo "描述：使用docker搭建sonarqube+postgresql代码质量管理平台"
        exit 1
}
status='Flase'
while getopts 'h' OPT;do
        case $OPT in
                'h'|'?') help
        esac
done


docker pull postgresql:latest
#创建工作目录
mkdir -p `pwd`/postgres/postgresql
mkdir -p `pwd`/postgres/data
#创建网络
docker network create sonarqube-tier
#启动数据库
docker run --name postgres -d -p 5432:5432 --net sonarqube-tier \
-v `pwd`/postgres/postgresql:/var/lib/postgresql \
-v `pwd`/postgres/data:/var/lib/postgresql/data \
-v /etc/localtime:/etc/localtime:ro \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=sonar \
-e POSTGRES_DB=sonar \
-e TZ=Asia/Shanghai \
--restart always \
--privileged=true \
--network-alias postgres \
postgres:latest

#安装 sonarQube
docker pull sonarqube:7.4-community
#创建工作目录
mkdir -p `pwd`/sonarqube
#修改系统参数
echo "vm.max_map_count=262144" > /etc/sysctl.conf && sysctl -p
#运行一个test容器
docker run -d --name sonartest sonarqube:7.4-community  && sleep 5
#将容器内重要文件复制到宿主机
docker cp sonartest:/opt/sonarqube/conf `pwd`/sonarqube
docker cp sonartest:/opt/sonarqube/data `pwd`/sonarqube
docker cp sonartest:/opt/sonarqube/logs `pwd`/sonarqube
docker cp sonartest:/opt/sonarqube/extensions `pwd`/sonarqube
#然后删除此容器
docker stop sonartest && docker rm sonartest
#修改文件夹权限
chmod -R 777 `pwd`/sonarqube/

#创建容器并运行
docker run -d --name sonar -p 9000:9000 \
-e ALLOW_EMPTY_PASSWORD=yes \
-e SONARQUBE_DATABASE_USER=sonar \
-e SONARQUBE_DATABASE_NAME=sonar \
-e SONARQUBE_DATABASE_PASSWORD=sonar \
-e SONARQUBE_JDBC_URL="jdbc:postgresql://postgres:5432/sonar" \
--net sonarqube-tier \
--privileged=true \
--restart always \
-v `pwd`/sonarqube/logs:/opt/sonarqube/logs \
-v `pwd`/sonarqube/conf:/opt/sonarqube/conf \
-v `pwd`/sonarqube/data:/opt/sonarqube/data \
-v `pwd`/sonarqube/extensions:/opt/sonarqube/extensions\
sonarqube:7.4-community

#汉化，中文语言包下载地址：https://github.com/SonarQubeCommunity/sonar-l10n-zh/tags 。
#找到自己版本对应的中文包。 将 jar 包放入 `pwd`/sonarqube/extensions/plugins ，重启 sonarqube。
#访问http://ip:9000，账号：admin 密码：admin。
status='True'
if [[ "$status" -eq 'True' ]];then
        echo -e "搭建完成\n访问http://IP:9000;默认用户名:admin;默认密码：admin"
fi

