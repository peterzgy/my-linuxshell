#!/usr/bin/env python
# coding=utf-8

txt_path = r'C:\Users\Super\Desktop'
f = open(txt_path + "\\ip文件.txt", "r")
lines = f.readlines()  # 读取全部内容
ip_number_list = []  # 将IP写在数组中
for line in lines:
    ip_number_list.append(line.rstrip('\n'))
f.close
# print(ip_number)

# 指定putty、key、linux脚本路径
putty_path = r'C:\Users\Super\Desktop\PuTTY.exe'
key_path = r'C:\Users\\Super\\Desktop\new.ppk'
linux_shell_path = r'C:\Users\Super\Desktop\test.sh'

from subprocess import Popen
for ip_number in ip_number_list:
    print('root@'+ip_number)
    args = putty_path, 'root@'+ip_number, '-i', key_path, '-m', linux_shell_path
    Popen(args)
