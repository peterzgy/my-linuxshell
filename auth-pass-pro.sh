#########################################################################
# File Name: auth-pass-pro.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2021年1月20日 星期五 13时35分54秒
#########################################################################
#!/bin/bash
set -euox pipefail
#!/bin/bash
IPLIST="
192.168.22.131
192.168.22.132
192.168.22.133
"
rpm -q sshpass &> /dev/null || yum -y install sshpass  
#[ -f /root/.ssh/id_rsa ] || ssh-keygen -f /root/.ssh/id_rsa  -P ''
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa  -C "zouguoyin@shbihu.com"
export SSHPASS=centos***abc   ##服务器密码，需要免密登陆
for IP in ${IPLIST};do
   sshpass -e ssh-copy-id -o StrictHostKeyChecking=no ${IP}
done