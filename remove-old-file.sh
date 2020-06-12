#!/usr/bin/bash
#author:zouguoyin
#describe:保留最新的2个文件，其他的老文件删除
function keep_some_newest_files(){
    num_save=2
#   files_ops="/home/ebs/release/ebs-producer-1.0.2/"
   files_ops=$1
    num_files=$(find ${files_ops} -type f -printf "%C@ %p\n" | sort -n | wc -l)
    if test ${num_files} -gt ${num_save};then
        echo "total number of files is $num_files."
        num_ops=$(expr ${num_files} - ${num_save})
        echo "$num_ops files are going to be handled."
        list_ops=$(find ${files_ops} -type f -printf "%C@ %p\n" | sort -n | head -n ${num_ops} | awk -F '[ ]+' '{print $2}')

        # IFS=' '$'\t'$'\n', If IFS is unset, or its value is exactly <space><tab><newline>
        old_IFS=$IFS
        IFS=" "
	echo   list_ops的值${list_ops}
        IFS="$old_IFS"

        for file_ops in ${list_ops};do
            echo "$file_ops"
#           test -d ${file_ops} && rm -rf ${file_ops}
            test -e ${file_ops} && echo  "${file_ops}将删除"
            test -f ${file_ops} && rm -f  ${file_ops}
	    echo   zou
        done
    else
        echo "total number of files is $num_files."
        echo "0 files are going to be handled, skipping."
    fi
}

my_dir=$(find /home/ebs/release-temp/ -name "*jar*"  | grep -Ev  "seata" |xargs -i dirname {} | uniq)
echo ${my_dir}
for dir in ${my_dir};do
    keep_some_newest_files ${dir}/
done
