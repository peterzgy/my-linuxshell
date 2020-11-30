#########################################################################
# File Name: getopts.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年11月30日 星期一 14时22分15秒
#########################################################################
#!/bin/bash
help(){
	echo "Usage:"
	echo "getopts.sh [-u user] [-p passwd]"
	echo "描述：传入语法及作用
	[ -u user ];通过[ -u ]传入用户名
	[ -p passwd ];通过 [ -p ]传入密码"

	exit 1
}
#为执行过程设置一个默认值
status='Flase'
while getopts 'u:p:h' OPT;do
# 'u:p:h' 和 ':u:p:h'的区别是，前面如果加了冒号的话，那么输入不匹配的选项时，脚本不会报错
# u: 表示选项u后面必须接一个选项参数，同理，p:表示选项t后面必须接一个选项参数
# 如果上面的'u:p:h'改成':up:h'，则表示选项u后面不需要选项参数，但是选项p后面必须接一个选项参数，并且输入的参数中若包含不匹配的选项，脚本不会报错''''''''
	case $OPT in
		'u') user_name="$OPTARG"
			echo -e "通过[ -u ]传入了用户名：[ $user_name ]";;
		'p') passwd="$OPTARG"
			echo -e "通过[ -p ]传入了用户名：[ $passwd ]";;
		'h') help
			echo "通过[ -h ]调用了帮助函数：[ help ]";;
		'?') help
			echo "通过[ ? ]调用了帮助函数：[ help ]";;
	esac
done

status='True'
echo -e "传入的用户名：[ $user_name ] \n出入的密码：[ $passwd ]"
if [[ "$status" -eq 'True' ]];then
	echo -e "脚本成功完成最后一步"
fi

