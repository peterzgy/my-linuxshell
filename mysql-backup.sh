#########################################################################
# File Name: mysql-backup.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月21日 星期一 15时42分10秒
# 用途：MYSQL备份模板
#########################################################################

#!/bin/bash
script_path=$(cd $(dirname $0) && pwd -P)
#定义
db_host=localhost
db_port=3306
db_name=mysql_prod 
db_name=ebs
db_user=root
db_pwd=password
backup_path="${script_path}/backup"

# view,function,procedure,event,trigger
output_type='view,function,procedure,event,trigger' 
today=`date +"%Y%m%d-%H%M%S"`
data_file=$backup_path/$db_name$today.sql
object_file="${backup_path}/obj_${db_name}$today.sql"
#log_file="/home/scripts/mysql_backup.log"
log_file="${script_path}/mysql_backup.log"
mysql_cmd="mysql -u${db_user} -p${db_pwd} -h${db_host} -P${db_port} "
mysqldump_cmd="mysqldump -u${db_user} -p${db_pwd} -h${db_host} -P${db_port} $db_name "


#调用函数库
[ -f /etc/init.d/functions ] && source /etc/init.d/functions
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

#Require root to run this script.
[ $(id -u) -gt 0 ] && echo "请用root用户执行此脚本！" && exit 1


[ -d $backup_path ] || mkdir -p $backup_path


#[ ! -n "$5" ] && echo -e "\033[31m Usage: $0 IP 端口 实例名 用户名 '密码'  \033[0m" && exit 1


function mysql_backup() 
{
  echo ""
  echo -e "\033[33m***********************************************mysql数据库备份****************************************************\033[0m" 
  
  echo -e "\033[36m**************备份数据库数据到$data_file**************\033[0m"
  #A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events
  $mysqldump_cmd --single_transaction -R -E --flush-logs --master-data=2 --set-gtid-purged=OFF > $data_file
  
  if [ $? -eq 0 ];then
    action "[$today]>>>完成数据库${db_name}数据备份" /bin/true
  echo "[$today]>>>完成数据库${db_name}数据备份" >> ${log_file}
  else 
    action "[$today]>>>数据库${db_name}备份失败，请检查相关配置！" /bin/false
  echo "[$today]>>>数据库${db_name}备份失败，请检查相关配置！" >> ${log_file}
  exit 1
  fi
  
  
  echo -e "\033[36m*******备份${db_name}函数、视图等定义到$object_file***********\033[0m"
  cat > $object_file<<EOF
ouput object‘s definition for database "$db_name"
ouput time: $(date "+%Y-%m-%d %H:%M:%S")
ouput object type: $output_type
EOF
  echo "">> $object_file
  echo "">> $object_file
 
  # 视图
  if [[ $output_type == *"view"* ]]
  then
  echo "-- ------------------------------------------------------------" >> $object_file
  echo "-- views" >> $object_file
  echo "-- ------------------------------------------------------------" >> $object_file
  #让 MySQL不输出列名 可以用-N 或者--skip-column-names参数
  $mysql_cmd  --skip-column-names \
  -e "select concat('SHOW CREATE VIEW ',table_schema,'.',table_name,';') from information_schema.views where table_schema='$db_name'" |\
  sed 's/;/\\G/g' | $mysql_cmd $db_name |\
  sed 's/Create View: /kk_begin\n/g' | sed 's/[ ]*character_set_client:/;\nkk_end/g' |\
  sed -n '/kk_begin/{:a;N;/kk_end/!ba;s/.*kk_begin\|kk_end.*//g;p}'  >> $object_file
  fi
 
  # 函数
  if [[ $output_type == *"function"* ]]
  then
  echo "-- ------------------------------------------------------------" >> $object_file
  echo "-- function" >> $object_file
  echo "-- ------------------------------------------------------------" >> $object_file
  $mysql_cmd --skip-column-names \
  -e "select concat('SHOW CREATE FUNCTION ',routine_schema,'.',routine_name,';') from information_schema.routines where routine_schema='$db_name' and ROUTINE_TYPE='FUNCTION'" |\
  sed 's/;/\\G/g' | $mysql_cmd $db_name |\
  sed 's/Create Function: /kk_begin\ndelimiter $$\n/g' | sed 's/[ ]*character_set_client:/$$ \ndelimiter ;\nkk_end/g' |\
  sed -n '/kk_begin/{:a;N;/kk_end/!ba;s/.*kk_begin\|kk_end.*//g;p}' >> $object_file
  fi
 
  # 存储过程
  if [[ $output_type == *"procedure"* ]]
  then
  echo "-- ------------------------------------------------------------" >> $object_file
  echo "-- procedure" >> $object_file
  echo "-- ------------------------------------------------------------" >> $object_file
  $mysql_cmd --skip-column-names \
  -e "select concat('SHOW CREATE PROCEDURE ',routine_schema,'.',routine_name,';') from information_schema.routines where routine_schema='$db_name' and ROUTINE_TYPE='PROCEDURE'" |\
  sed 's/;/\\G/g' | $mysql_cmd  $db_name |\
  sed 's/Create Procedure: /kk_begin\ndelimiter $$\n/g' | sed 's/[ ]*character_set_client:/$$ \ndelimiter ;\nkk_end/g' |\
  sed -n '/kk_begin/{:a;N;/kk_end/!ba;s/.*kk_begin\|kk_end.*//g;p}' >> $object_file
  fi
 
  # 事件
  if [[ $output_type == *"event"* ]]
  then
  echo "-- ------------------------------------------------------------" >> $object_file
  echo "-- event" >> $object_file
  echo "-- ------------------------------------------------------------" >> $object_file
  $mysql_cmd --skip-column-names \
  -e "select concat('SHOW CREATE EVENT ',EVENT_SCHEMA,'.',EVENT_NAME,';') from information_schema.events where EVENT_SCHEMA='$db_name'" |\
  sed 's/;/\\G/g' | $mysql_cmd |\
  sed 's/Create Event: /kk_begin\ndelimiter $$\n/g' | sed 's/[ ]*character_set_client:/$$ \ndelimiter ;\nkk_end/g' |\
  sed -n '/kk_begin/{:a;N;/kk_end/!ba;s/.*kk_begin\|kk_end.*//g;p}' >> $object_file
  fi
 
  # 触发器
  if [[ $output_type == *"trigger"* ]]
  then
  echo "-- ------------------------------------------------------------" >> $object_file
  echo "-- trigger" >> $object_file
  echo "-- ------------------------------------------------------------" >> $object_file
  $mysql_cmd --skip-column-names \
  -e "select concat('SHOW CREATE TRIGGER ',TRIGGER_SCHEMA,'.',TRIGGER_NAME,';') from information_schema.triggers where TRIGGER_SCHEMA='$db_name';" |\
  sed 's/;/\\G/g' | $mysql_cmd $db_name|\
  sed 's/SQL Original Statement: /kk_begin\ndelimiter $$\n/g' | sed 's/[ ]*character_set_client:/$$ \ndelimiter ;\nkk_end/g' |\
  sed -n '/kk_begin/{:a;N;/kk_end/!ba;s/.*kk_begin\|kk_end.*//g;p}' >> $object_file
  fi
 
  # ^M, you need to type CTRL-V and then CTRL-M
  sed -i "s/\^M//g" $object_file

  #清理过期备份
  find ${backup_path}  -mtime +10  -type f -name '*.sql' -exec rm -f {} \;
  
  if [ $? -eq 0 ];then
    action "[$today]>>>完成数据库${db_name}过期备份清理" /bin/true
  echo "[$today]>>>完成数据库${db_name}过期备份清理" >> ${log_file}
  else 
    action "[$today]>>>数据库${db_name}过期备份清理失败，请检查相关配置！" /bin/false
  echo "[$today]>>>数据库${db_name}过期备份清理失败，请检查相关配置！" >> ${log_file}
  exit 1
  fi
  
  echo -e "\033[33m**********************************************完成${db_name}数据库备份**********************************************\033[0m"
cat > /tmp/mysql_backup.log  << EOF
mysql地址：${db_host}
mysql端口：${db_port}
mysql实例名：${db_name}
数据备份文件：${data_file}
定义备份文件：${object_file}
EOF
  cat /tmp/mysql_backup.log
  echo -e "\e[1;31m 以上信息保存在/tmp/mysql_backup.log文件下 \e[0m"
  echo -e "\033[33m*******************************************************************************************************************\033[0m"
  echo ""
}


mysql_backup
