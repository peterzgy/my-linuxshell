#!/bin/bash
#########################################################################
# File Name: rocketmq-start.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年09月03日 星期三 16时27分48秒
#########################################################################
nohup sh mqnamesrv>../logs/mqnamesrv.log  2>&1 &
nohup ./mqbroker -n 172.16.0.64:9876 autoCreateTopicEnable=true -c /home/ebs/soft/rocketmq/distribution/target/rocketmq-4.7.1/rocketmq-4.7.1/conf/broker.conf >../logs/broker.log 2>&1 &
