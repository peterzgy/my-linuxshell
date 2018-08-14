#/bin/bash
#移动文件并且改名
publicip=`nc ns1.dnspod.net 6666`
wjj=$publicip-`date +%Y%m%d-%H:%M:%S`
echo $wjj
mkdir ./$wjj
#[ ! -d ./dwj ] && mkdir ./dwj
for a in `ls ./swj`
do
time=`date +%Y%m%d-%H:%M:%S`
filename=$publicip-$time+".txt"
#mv ./swj/`echo $a` ./dwj/`echo $filename`
mv ./swj/`echo $a` ./$wjj/`echo $filename`
echo 移动$a
echo $filename	
sleep 1
done
tar -zcvf  ./tarzip/$wjj ./$wjj
