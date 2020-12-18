#########################################################################
# File Name: auth-pass.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月18日 星期五 14时20分19秒
#########################################################################
#!/bin/bash
set -euox pipefail
host_list="10.0.0.230 10.0.0.220"
user=ebs
SSH_PASSWD='******'
#sshpass -p ${SSH_PASSWD} ssh root@"$host" -o StrictHostKeyChecking=no  <cmd>
#centos6中：ssh-copy-id -i ~/.ssh/id_rsa.pub "root@10.0.0.100 -p 22"
#centos7中：ssh-copy-id -i ~/.ssh/id_rsa.pub  root@10.0.0.100 -p 22"
#cat ~/.ssh/id_rsa.pub | ssh -p 22 root@10.0.0.100 "umask 077;mkdir -p ~/.ssh;cat - >> ~/.ssh/authorized_keys"

for host in ${host_list};do
	echo "开始对${host}添加密匙认证"
	remote_hostname=""
	cat ~/.ssh/id_rsa.pub | sshpass -p ${SSH_PASSWD} ssh ${user}@${host}  -o StrictHostKeyChecking=no "umask 077;mkdir -p ~/.ssh;cat - >> ~/.ssh/authorized_keys"
	remote_hostname=$(ssh  ${user}@${host}  hostname)
	[[ -n ${remote_hostname} ]] &&  echo "${host}密匙添加成功,节点计算机名是${remote_hostname}" || echo "${host}密匙添加失败"
done
