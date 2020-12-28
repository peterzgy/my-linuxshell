#########################################################################
# File Name: jcli.sh
# Author: zouguoyin
# mail: 995637339@qq.com
# Created Time: 2020年12月28日 星期一 14时22分38秒
#########################################################################
#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-u] [-h] [-b]  -e param_value arg1 [arg2...]
Script description here.
Available options:
-u, --usage     Print this help and exit
-h, --help      所有其他参数
-b, --build     构建项目
-l, --list-jobs 所有可构建项目的名字
-e, --exec      执行-h所列出的所有参数    
EOF
  exit
}
#jenkins的安装位置为/home/ebs/alldata/soft/apache-tomcat/
jenkins_cli_path="/home/ebs/alldata/soft/apache-tomcat/webapps/jenkins/WEB-INF/jenkins-cli.jar"
jenkins_url="http://127.0.0.1:8080/jenkins/"
jenkins_user="admin"
jenkins_pwd="Jenkins@ebs#123"
jenkins_cmd="java -jar  ${jenkins_cli_path}  -s ${jenkins_url} -auth ${jenkins_user}:${jenkins_pwd}"  


help_detail(){
    ${jenkins_cmd}  
}
list_jobs(){
    ${jenkins_cmd}  list-jobs
}
build_jenkins(){
#${jenkins_cmd}  $@
${jenkins_cmd} build -v -f  ${param}
}


msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}


parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :;do
	case "${1-}" in
	-h | --help) help_detail ;;
	-l | --job-list) list_jobs ;;
	-e | --job-list) shift && ${jenkins_cmd} $* && exit 0 ;;
	-b | --ecec) 
	  param="${2-}"
	  shift ;;
	-?*) die "Unknown option: $1" ;;
	*) break ;;
  esac
  shift
  done

  args=("$@")
  # check required params and arguments
  # [[ -z "${param-}" ]] && die "Missing required parameter: param"
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}
parse_params "$@"	

[[ -n "${param-}" ]] && build_jenkins

