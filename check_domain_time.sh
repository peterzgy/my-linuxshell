#!/bin/bash
#author:zouguoyin
#date:2020-1-13
#描述：通过域名获取证书过期时间

#加载环境变量
. /etc/profile
. ~/.bash_profile
. /etc/bashrc

#脚本所在目录（即脚本名称）
script_dir=$(cd "$(dirname "$0")" && pwd)
script_name=$(basename ${0})

readfile="${script_dir}/domain_ssl.info"

readfile="${script_dir}/domain_ssl.info"
grep -v '^#' ${readfile} | while read line;do #读取存储了需要监测的域名的文件
    # echo "${line}"
    get_domain=$(echo "${line}" | awk -F':' '{print $1}')
    get_port=$(echo "${line}" | awk -F':' '{print $2}')

    # echo ${get_domain}
    # echo "${get_port}"
    # echo "======"

    end_time=$(echo | openssl s_client -servername ${get_domain}  -connect ${get_domain}:${get_port} 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )
    #使用openssl获取域名的证书情况，然后获取其中的到期时间
    end_time1=$(date +%s -d "$end_time") #将日期转化为时间戳
   #now_time=$(date +%s -d "$(date | awk -F' +'  '{print $2,$3,$6}')") #将目前的日期也转化为时间戳
    now_time=$(date +%s -d "$(date "+%Y-%m-%d %H:%M:%S")") #将目前的日期也转化为时间戳

    rst=$(($(($end_time1-$now_time))/(60*60*24))) # 到期时间减去目前时间再转化为天数

    echo "${get_domain}证书有效天数剩余：${rst}"

#    if [ $rst -lt 5 ];then
#        echo "$get_domain https 证书有效期少于5天，存在风险"
#    else
#        echo "$get_domain https 证书有效期在5天以上，放心使用"
#    fi
done

