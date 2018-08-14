#/bin/bash
#判断进程是否存在
isprocess=`ps aux | grep "ps aux" | grep -v grep | wc -l`
if [ $isprocess -ge 1 ];then
echo 存在
else
echo 不存在
fi