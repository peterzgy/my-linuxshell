#!/bin/bash
#author:zouguoyin
#用法：BUILD_ID=DONTKILLME && sh ~/scripts/jenkins-deploy-shell.sh
#APP_NAME=$1
APP_NAME=${JOB_NAME}
# APP_VERSION=$2
APP_VERSION=0.0.1
#APP_PORT=$3
APP_PORT=$(awk -v var=${APP_NAME}   '$1==var{print $2}' /home/ebs/scripts/port.txt)
echo "端口是${APP_PORT}"
#PACKAGE_DIR=${APP_NAME}-${APP_VERSION}
#PACKAGE_DIR=ebs-pay-center
#DEFAULT_APP_VERSION=0.0.1
DEFAULT_APP_VERSION=*
PACKAGE_NAME=${PACKAGE_DIR}-SNAPSHOT.jar

if [ -z ${APP_VERSION}="" ] ; then
	PACKAGE_DIR=${APP_NAME}-${DEFAULT_APP_VERSION}
	PACKAGE_NAME=${APP_NAME}-${DEFAULT_APP_VERSION}-SNAPSHOT.jar
else
	PACKAGE_DIR=${APP_NAME}-${APP_VERSION}
	PACKAGE_NAME=${APP_NAME}-${APP_VERSION}-SNAPSHOT.jar
fi

DEFAULT_PACKAGE_NAME=${APP_NAME}-${DEFAULT_APP_VERSION}-SNAPSHOT.jar

DAY=$(date +%Y-%m-%d)

function app_kill(){
	PID=""
	PID=$( ps -ef |egrep  ${APP_NAME}-.*jar-.* |grep -v $$ | grep -v grep | awk '{print $2}' )
	echo $PID
	if [ -n "${PID}" ];then
		echo "The pid: server $PID  will be killed...."
		kill -9 ${PID}
	fi
}

if [ ! -d "/home/ebs/release-temp/${PACKAGE_DIR}" ];then
	mkdir   /home/ebs/release-temp/${PACKAGE_DIR}
fi
if [ ! -d "/home/ebs/release/${PACKAGE_DIR}" ];then
	mkdir   /home/ebs/release/${PACKAGE_DIR}
fi
if [ -f "/home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}" ];then
	if [ -f "/home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}.old" ];then
		rm  -f  /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}.old
	fi
	mv   /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}  /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}.old
fi


cd /home/ebs/data/workspace/${APP_NAME}  
#mvn clean install -Dmaven.test.skip=true | tee  /home/ebs/logs/mvn-package.log  ||  exit 1
mvn clean install -Dmaven.test.skip=true ||  exit 1

[ -z  ${APP_PORT} ] && exit 0

if [[ ! -d target ]];then
cp /home/ebs/data/workspace/${APP_NAME}/${APP_NAME}/target/${DEFAULT_PACKAGE_NAME}   /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}
else
cp /home/ebs/data/workspace/${APP_NAME}/target/${DEFAULT_PACKAGE_NAME}   /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}
fi

echo "copy /home/ebs/data/workspace/${APP_NAME}/${APP_NAME}/target/${PACKAGE_NAME}  to  /home/ebs/release-temp/${PACKAGE_NAME}-${DAY}"
rm -f /home/ebs/release/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}
if [[ ${APP_PORT} -eq "" ]];then exit 0 ;fi
cp   /home/ebs/release-temp/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}  /home/ebs/release/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}
app_kill && echo "The pid: server ${APP_NAME}  ${PID} stop,new server  will be start" 
nohup java  -jar -Xms512m -Xmx512m -Dspring.profiles.active=dev   /home/ebs/release/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}  >   /home/ebs/logs/${APP_NAME}.log  2>&1  &

#方便开发查看当前启动的jar包 
test -e /home/ebs/logs/package  || mkdir /home/ebs/logs/package 
test -e /home/ebs/logs/package/${APP_NAME}*  && rm -f  /home/ebs/logs/package/${APP_NAME}* 
chmod 777 /home/ebs/package
cp -r /home/ebs/release/${PACKAGE_DIR}/${PACKAGE_NAME}-${DAY}  /home/ebs/logs/package/

#检测进程
sleep 2
PID=$( ps -ef |grep    ${PACKAGE_NAME}-${DAY}| grep -v grep | awk '{print $2}' )
echo "new server name:${PACKAGE_NAME}-${DAY}  pid num : ${PID} "
[ -z  ${PID} ] && exit 1
echo "The  server  ${PACKAGE_NAME}-${DAY} ${PID} started"


#等待程序启动
sleep   30

#检测端口
function  PORT_CHECK(){
	result=`echo -e "\n" | telnet $1 $2 2>/dev/null | grep Connected | wc -l`
	[ $result -eq 1 ] && PORT_RESULT=1 || PORT_RESULT=0
}

PORT_CHECK 172.16.0.64 ${APP_PORT}
echo "检测端口PORT_CHEK 172.16.0.64 ${APP_PORT}"
if [ $PORT_RESULT -eq 1 ];then
	echo "num 1  ${PACKAGE_NAME}-${DAY} start  success"
	# nginx_switch1  &&  grep conf /home/ebs/soft/nginx/conf/nginx.conf
else
	echo "num 1 ${PACKAGE_NAME}-${DAY} start  failure"
	exit 1
fi


cd /home/ebs/scripts
if [ $PORT_RESULT -eq 1 ];then
	echo "num 1  ${PACKAGE_NAME}-${DAY} start  success"

	# echo "${PACKAGE_NAME}-${DAY}发布成功"  | mail -s  "测试环境发布通知"   995637339@qq.com,zouguoyin@shbihu.com
	# cat home/ebs/logs/mvn-package.log   |	mail -s  "${PACKAGE_NAME}-${DAY}项目测试环境发布成功日志"   995637339@qq.com   
	# python3 -c 'import mail;mail.mailzou("'${PACKAGE_NAME}-${DAY}测试环境发布成功日志'")'
	# nginx_switch  &&  grep conf /home/ebs/soft/nginx/conf/nginx.conf

else
    echo "num 1 ${PACKAGE_NAME}-${DAY} start  failure"
	# #mail -s  "${PACKAGE_NAME}-${DAY}项目测试环境发布失败日志"   995637339@qq.com   <  /home/ebs/logs/mvn-package.log
    # python3 -c 'import mail;mail.mailzou("'${PACKAGE_NAME}-${DAY}测试环境发布失败日志'")'
	exit 1
fi



