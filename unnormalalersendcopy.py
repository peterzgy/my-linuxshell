#!/usr/bin/env python
# coding=utf-8

# rend ping alert
txt_path = r'/home/super-zou/Desktop/读取IP后测试端口'
with open(txt_path + '/xh.txt') as f:
    lines = f.readlines()  # 读取全部内容
host_list = []
for line in lines:
    host_list.append(line.rstrip())

import threading,subprocess
from time import ctime,sleep,time
import Queue
alert_ip = []
normal_ip = []
queue = Queue.Queue()


class ThreadUrl(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):

        while True:
            host = self.queue.get()
            # ret=subprocess.call('ping -c 1 '+host,shell=True,stdout=open('C:\Users\Super\Desktop\ping的结果.txt','w'))
            ret = subprocess.call('ping -c 1 -w 1 ' + host, shell=True)
            if ret:
                print(" %s is down\n" % host)
                alert_ip.append(host)
                # print(alert_ip)
            else:
                print(' %s is up\n' % host)
                normal_ip.append(host)
                # print(normal_ip)
            self.queue.task_done()


def main():

    for i in range(100):
        t = ThreadUrl(queue)  # 调用多线程类
        # join：如在一个线程B中调用threada.join()，则threada结束后，线程B才会接着threada.join()
        # 往后运行。
        # setDaemon：主线程A启动了子线程B，调用b.setDaemaon(True)，则主线程结束时，会把子线程B也杀死，与C / C + +中得默认效果是一样的。
        t.setDaemon(True)
        t.start()
    for host in host_list:
        queue.put(host)
    queue.join()


start = time()
main()
print("Elasped Time:%s" % (time()-start))


# send email
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr

my_sender = '******yin@qq.com'  # 发件人邮箱账号
my_pass = '*******eoqmbchj'  # 发件人邮箱密码
my_user = '********@qq.com'  # 收件人邮箱账号

alert_ip_message ='    ;    '.join(alert_ip)


def mail():
    ret = True
    try:

        msg = MIMEText(alert_ip_message, 'plain', 'utf-8')
        msg['From'] = formataddr(["peter", my_sender])  # 括号里的对应发件人邮箱昵称、发件人邮箱账号
        msg['To'] = formataddr(["peter", my_user])  # 括号里的对应收件人邮箱昵称、收件人邮箱账号
        msg['Subject'] = "remote server alert"  # 邮件的主题，也可以说是标题

        server = smtplib.SMTP_SSL("smtp.qq.com", 465)  # 发件人邮箱中的SMTP服务器，端口是25
        server.login(my_sender, my_pass)  # 括号中对应的是发件人邮箱账号、邮箱密码
        server.sendmail(my_sender, [my_user, ], msg.as_string())  # 括号中对应的是发件人邮箱账号、收件人邮箱账号、发送邮件
        server.quit()  # 关闭连接
    except Exception:  # 如果 try 中的语句没有执行，则会执行下面的 ret=False
        ret = False
    return ret


ret = mail()
if ret:
    print("邮件发送成功")
else:
    print("邮件发送失败")
