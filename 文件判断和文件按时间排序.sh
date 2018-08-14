#!/bin/bash
#判断文件是否存在，不存在创建，以公网Ip命名。
#检查来源文件，如果只有一个文件，则不移动，如果有多个文件，则保留最近生成的文件，其它的移动到其他地方
publicip=`nc ns1.dnspod.net 6666`
if [ ! -d "/root/$publicip" ];then
mkdir /root/$publicip
fi
sourcepath=/data/test  
if [ ! `ls $sourcepath | wc -l` -eq 1 ];then
for filename in `ls -t $sourcepath | sed '1d'`
do
echo $filename
mv $sourcepath/$filename /root/$publicip
done
fi